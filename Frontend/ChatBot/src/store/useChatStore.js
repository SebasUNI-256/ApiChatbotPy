import { create } from 'zustand';
import { WS_URL } from '../config/urls';

const isPositiveInteger = (value) => Number.isInteger(value) && value > 0;

const updateProductStock = (products, orderDetails) => {
  const purchasedByProduct = new Map();

  orderDetails.forEach((detail) => {
    const productVariableId = Number(detail.productVariableId);
    const quantity = Number(detail.quantity);

    if (isPositiveInteger(productVariableId) && isPositiveInteger(quantity)) {
      purchasedByProduct.set(
        productVariableId,
        (purchasedByProduct.get(productVariableId) ?? 0) + quantity,
      );
    }
  });

  return products.map((product) => {
    const productVariableId = Number(product.ProductVariableID);
    const purchasedQuantity = purchasedByProduct.get(productVariableId);

    if (!purchasedQuantity) return product;

    return {
      ...product,
      StockAvailable: Math.max(
        0,
        Number(product.StockAvailable ?? 0) - purchasedQuantity,
      ),
    };
  });
};

export const useChatStore = create((set, get) => ({
  messages: [],
  conversationId: null,
  cart: [],
  isCartVisible: false,
  products: [],
  addingProductIds: [],
  recentlyAddedProductIds: [],
  unavailableProductIds: [],
  order: null,
  socket: null,
  isConnected: false,
  isProcessingPayment: false,
  isConsultingOrder: false,
  paymentError: null,
  orderError: null,
  pendingActions: [],

  connectWebSocket: () => {
    if (get().socket) return;

    const ws = new WebSocket(WS_URL);

    ws.onopen = () => set({ isConnected: true });

    ws.onmessage = (event) => {
      const response = JSON.parse(event.data);
      const {
        pendingActions,
        addingProductIds,
        recentlyAddedProductIds,
        unavailableProductIds,
        products,
      } = get();
      const [completedAction, ...remainingActions] = pendingActions;
      const completedActionType = typeof completedAction === 'string'
        ? completedAction
        : completedAction?.type;
      const isSuccessful = response.resultCode < 400;
      const hasOrderData = Boolean(
        response.data?.order && Array.isArray(response.data?.details),
      );
      const nextState = { pendingActions: remainingActions };

      if (response.resultCode >= 400) {
        console.error('Error desde el Chatbot:', response.resultMessage);
      }

      if (completedActionType === 'payment') {
        nextState.isProcessingPayment = false;

        if (isSuccessful && hasOrderData) {
          const updatedProducts = updateProductStock(products, response.data.details);
          nextState.order = response.data;
          nextState.cart = [];
          nextState.isCartVisible = false;
          nextState.products = updatedProducts;
          nextState.unavailableProductIds = updatedProducts
            .filter((product) => Number(product.StockAvailable ?? 0) <= 0)
            .map((product) => Number(product.ProductVariableID));
          nextState.paymentError = null;
        } else {
          nextState.paymentError = isSuccessful
            ? 'La respuesta del pago no contiene una orden válida.'
            : response.resultMessage;
        }
      }

      if (completedActionType === 'order') {
        nextState.isConsultingOrder = false;

        if (isSuccessful && hasOrderData) {
          nextState.order = response.data;
          nextState.orderError = null;
        } else {
          nextState.orderError = isSuccessful
            ? 'La respuesta no contiene una orden válida.'
            : response.resultMessage;
        }
      }

      if (completedActionType === 'add-product') {
        const productVariableId = completedAction.productVariableId;
        nextState.addingProductIds = addingProductIds.filter(
          (item) => item !== productVariableId,
        );

        if (isSuccessful && Array.isArray(response.data)) {
          nextState.unavailableProductIds = unavailableProductIds.filter(
            (item) => item !== productVariableId,
          );
          nextState.recentlyAddedProductIds = recentlyAddedProductIds.includes(productVariableId)
            ? recentlyAddedProductIds
            : [...recentlyAddedProductIds, productVariableId];

          setTimeout(() => {
            set((state) => ({
              recentlyAddedProductIds: state.recentlyAddedProductIds.filter(
                (item) => item !== productVariableId,
              ),
            }));
          }, 1500);
        } else if (response.resultCode === 409) {
          nextState.unavailableProductIds = unavailableProductIds.includes(productVariableId)
            ? unavailableProductIds
            : [...unavailableProductIds, productVariableId];
        }
      }

      if (response.conversationId) {
        nextState.conversationId = response.conversationId;
      }

      if (Array.isArray(response.data)) {
        nextState.cart = response.data;

        if (response.rule === 'Consultar Carrito') {
          nextState.isCartVisible = true;
          nextState.products = [];
          nextState.unavailableProductIds = [];
        }
      }

      if (Object.prototype.hasOwnProperty.call(response, 'pageNumber')) {
        nextState.products = response.products;
        nextState.isCartVisible = false;
        nextState.unavailableProductIds = [];
      }

      set(nextState);

      if (response.reply) {
        set((state) => ({
          messages: [...state.messages, { sender: 'bot', text: response.reply }],
        }));
      }
    };

    ws.onclose = (event) => {
      set((state) => ({
        socket: null,
        isConnected: false,
        isProcessingPayment: false,
        isConsultingOrder: false,
        addingProductIds: [],
        pendingActions: [],
        paymentError: state.isProcessingPayment
          ? 'Se perdió la conexión antes de completar el pago.'
          : state.paymentError,
        orderError: state.isConsultingOrder
          ? 'Se perdió la conexión antes de consultar la orden.'
          : state.orderError,
      }));

      if (event.code === 4401) {
        alert('Sesión expirada. Inicia sesión nuevamente.');
      } else if (event.code === 4403) {
        alert('No tienes acceso a esta conversación.');
      }
    };

    set({ socket: ws });
  },

  disconnectWebSocket: () => {
    const { socket } = get();
    if (socket) {
      socket.onclose = null;
      socket.close();
    }
    set({
      socket: null,
      isConnected: false,
      isProcessingPayment: false,
      isConsultingOrder: false,
      addingProductIds: [],
      recentlyAddedProductIds: [],
      unavailableProductIds: [],
      isCartVisible: false,
      pendingActions: [],
    });
  },

  sendMessage: (messageText, parameters = {}, action = 'chat') => {
    const { socket, conversationId } = get();

    if (!socket || socket.readyState !== WebSocket.OPEN) return false;

    const payload = {
      message: messageText,
      conversationId,
      parameters,
    };

    socket.send(JSON.stringify(payload));

    set((state) => ({
      messages: [...state.messages, { sender: 'user', text: messageText }],
      pendingActions: [...state.pendingActions, action],
    }));

    return true;
  },

  addProductToCart: (productVariableId) => {
    if (!isPositiveInteger(productVariableId)) return false;

    const { addingProductIds, unavailableProductIds } = get();
    if (
      addingProductIds.includes(productVariableId)
      || unavailableProductIds.includes(productVariableId)
    ) return false;

    set({ addingProductIds: [...addingProductIds, productVariableId] });
    const wasSent = get().sendMessage(
      'agregar al carrito',
      { productVariableId, quantity: 1 },
      { type: 'add-product', productVariableId },
    );

    if (!wasSent) {
      set((state) => ({
        addingProductIds: state.addingProductIds.filter(
          (item) => item !== productVariableId,
        ),
      }));
    }

    return wasSent;
  },

  hideCart: () => set({ isCartVisible: false }),

  processPayment: (addressId, paymentMethodId) => {
    if (!isPositiveInteger(addressId) || !isPositiveInteger(paymentMethodId)) {
      set({ paymentError: 'La dirección y el método de pago deben ser enteros mayores que cero.' });
      return false;
    }

    set({ isProcessingPayment: true, paymentError: null });
    const wasSent = get().sendMessage(
      'procesar pago',
      { addressId, paymentMethodId },
      'payment',
    );

    if (!wasSent) {
      set({
        isProcessingPayment: false,
        paymentError: 'El WebSocket no está conectado. Intenta nuevamente.',
      });
    }

    return wasSent;
  },

  consultOrder: (orderId) => {
    if (!isPositiveInteger(orderId)) {
      set({ orderError: 'El ID de la orden debe ser un entero mayor que cero.' });
      return false;
    }

    set({ isConsultingOrder: true, orderError: null });
    const wasSent = get().sendMessage(
      'consultar orden',
      { orderId },
      'order',
    );

    if (!wasSent) {
      set({
        isConsultingOrder: false,
        orderError: 'El WebSocket no está conectado. Intenta nuevamente.',
      });
    }

    return wasSent;
  },
}));
