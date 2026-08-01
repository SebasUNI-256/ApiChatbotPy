import { create } from 'zustand';

export const useChatStore = create((set, get) => ({
  messages: [],
  conversationId: null,
  cart: [],
  products: [],
  socket: null,
  isConnected: false,

  connectWebSocket: () => {
    const ws = new WebSocket('ws://localhost:8000/ws/chat');

    ws.onopen = () => set({ isConnected: true });

    ws.onmessage = (event) => {
      const response = JSON.parse(event.data);

      // Manejo de errores por resultCode del WS
      if (response.resultCode >= 400) {
        console.error('Error desde el Chatbot:', response.resultMessage);
      }

      // Guardar el conversationId devuelto
      if (response.conversationId) {
        set({ conversationId: response.conversationId });
      }

      // Actualizar datos del carrito si vienen en la respuesta
      if (Array.isArray(response.data)) {
        set({ cart: response.data });
      }

      // Actualizar lista de productos encontrados
      if (response.products) {
        set({ products: response.products });
      }

      // Agregar mensaje del bot a la conversación
      if (response.reply) {
        set((state) => ({
          messages: [...state.messages, { sender: 'bot', text: response.reply }],
        }));
      }
    };

    ws.onclose = (event) => {
      set({ isConnected: false });
      // Códigos de cierre del contrato
      if (event.code === 4401) {
        alert('Sesión expirada. Inicia sesión nuevamente.');
      } else if (event.code === 4403) {
        alert('No tienes acceso a esta conversación.');
      }
    };

    set({ socket: ws });
  },

  sendMessage: (messageText, parameters = {}) => {
    const { socket, conversationId } = get();

    if (!socket || socket.readyState !== WebSocket.OPEN) return;

    const payload = {
      message: messageText,
      conversationId: conversationId,
      parameters: parameters, // Respetar mayúsculas/minúsculas exactas
    };

    socket.send(JSON.stringify(payload));

    // Agregar mensaje del usuario localmente
    set((state) => ({
      messages: [...state.messages, { sender: 'user', text: messageText }],
    }));
  },
}));
