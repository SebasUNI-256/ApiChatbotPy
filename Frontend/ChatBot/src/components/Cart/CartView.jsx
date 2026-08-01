import { useEffect, useState } from 'react';
import { getCheckoutOptions } from '../../services/checkoutService';
import { useChatStore } from '../../store/useChatStore';

const formatAmount = (value) => Number(value ?? 0).toFixed(2);

const formatDate = (value) => {
  if (!value) return 'No disponible';

  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : date.toLocaleString();
};

const getErrorMessage = (error, fallback) => (
  error.response?.data?.detail
  || error.response?.data?.resultMessage
  || fallback
);

export function CartView({ onManagePaymentMethods }) {
  const [addresses, setAddresses] = useState([]);
  const [paymentMethods, setPaymentMethods] = useState([]);
  const [savedOrders, setSavedOrders] = useState([]);
  const [addressId, setAddressId] = useState('');
  const [paymentMethodId, setPaymentMethodId] = useState('');
  const [isLoadingOptions, setIsLoadingOptions] = useState(true);
  const [optionsError, setOptionsError] = useState('');
  const {
    cart,
    order,
    isConnected,
    isProcessingPayment,
    isConsultingOrder,
    paymentError,
    orderError,
    sendMessage,
    processPayment,
    consultOrder,
  } = useChatStore();
  const currentOrder = order?.order;
  const orderDetails = order?.details ?? [];
  const currentOrderId = currentOrder?.orderId;
  const availableOrders = currentOrderId && !savedOrders.some((item) => item.orderId === currentOrderId)
    ? [currentOrder, ...savedOrders]
    : savedOrders;

  useEffect(() => {
    let isActive = true;

    getCheckoutOptions()
      .then((data) => {
        if (!isActive) return;

        const principalAddress = data.addresses.find((item) => item.isPrincipal);
        setAddresses(data.addresses);
        setPaymentMethods(data.paymentMethods);
        setSavedOrders(data.orders);
        setAddressId(String(principalAddress?.addressId ?? data.addresses[0]?.addressId ?? ''));
        setPaymentMethodId(String(data.paymentMethods[0]?.paymentMethodId ?? ''));
      })
      .catch((requestError) => {
        if (isActive) {
          setOptionsError(getErrorMessage(requestError, 'No fue posible cargar los datos de pago.'));
        }
      })
      .finally(() => {
        if (isActive) setIsLoadingOptions(false);
      });

    return () => {
      isActive = false;
    };
  }, []);

  const handleRemoveItem = (cartDetailId) => {
    sendMessage('quitar del carrito', { cartDetailId });
  };

  const handleRefreshCart = () => {
    sendMessage('ver carrito');
  };

  const handlePayment = (event) => {
    event.preventDefault();
    processPayment(Number(addressId), Number(paymentMethodId));
  };

  const handleConsultOrder = (event) => {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    consultOrder(Number(formData.get('orderId')));
  };

  const calculateTotal = () => cart.reduce((total, item) => total + item.total, 0);

  return (
    <div style={{ padding: '20px', maxWidth: '800px', margin: '20px auto', border: '1px solid #ddd', borderRadius: '8px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '12px' }}>
        <h3>Tu Carrito de Compras</h3>
        <button onClick={handleRefreshCart} disabled={!isConnected}>Actualizar Carrito</button>
      </div>

      {cart.length === 0 ? (
        <p>El carrito está vacío. Consulta en el chat para agregar productos.</p>
      ) : (
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse', marginTop: '10px' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid #ccc' }}>
                <th>Producto</th>
                <th>Variante</th>
                <th>Cant.</th>
                <th>Precio</th>
                <th>Total</th>
                <th>Acción</th>
              </tr>
            </thead>
            <tbody>
              {cart.map((item) => (
                <tr key={item.cartDetailId} style={{ borderBottom: '1px solid #eee' }}>
                  <td>{item.productName}</td>
                  <td>{item.productVariableValue}</td>
                  <td>{item.quantity}</td>
                  <td>
                    {Number(item.discount ?? 0) > 0 && (
                      <span style={{ textDecoration: 'line-through', color: '#777', marginRight: '6px' }}>
                        ${formatAmount(item.originalUnitPrice)}
                      </span>
                    )}
                    ${formatAmount(item.unitPrice)}
                  </td>
                  <td>${formatAmount(item.total)}</td>
                  <td>
                    <button
                      onClick={() => handleRemoveItem(item.cartDetailId)}
                      style={{ color: 'red', cursor: 'pointer' }}
                    >
                      Quitar
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          <div style={{ marginTop: '15px', textAlign: 'right' }}>
            <h4>Total: ${calculateTotal().toFixed(2)}</h4>
          </div>
        </div>
      )}

      <section style={{ marginTop: '24px', paddingTop: '20px', borderTop: '1px solid #ddd' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '12px', flexWrap: 'wrap' }}>
          <h3>Procesar pago</h3>
          <button type="button" onClick={onManagePaymentMethods}>
            Administrar datos de pago
          </button>
        </div>

        {isLoadingOptions && <p>Cargando direcciones y métodos...</p>}
        {optionsError && <p role="alert" style={{ color: '#ff6b6b' }}>{optionsError}</p>}

        {!isLoadingOptions && !optionsError && (
          <form onSubmit={handlePayment} style={{ display: 'flex', gap: '10px', flexWrap: 'wrap', alignItems: 'end' }}>
            <label style={{ display: 'flex', flexDirection: 'column', gap: '4px', minWidth: '240px' }}>
              Dirección de entrega
              <select
                required
                value={addressId}
                onChange={(event) => setAddressId(event.target.value)}
                style={{ padding: '8px' }}
              >
                <option value="">Selecciona una dirección</option>
                {addresses.map((address) => (
                  <option key={address.addressId} value={address.addressId}>
                    {address.description} — C.P. {address.zipCode}
                    {address.isPrincipal ? ' (principal)' : ''}
                  </option>
                ))}
              </select>
            </label>

            <label style={{ display: 'flex', flexDirection: 'column', gap: '4px', minWidth: '240px' }}>
              Método de pago
              <select
                required
                value={paymentMethodId}
                onChange={(event) => setPaymentMethodId(event.target.value)}
                style={{ padding: '8px' }}
              >
                <option value="">Selecciona un método</option>
                {paymentMethods.map((method) => (
                  <option key={method.paymentMethodId} value={method.paymentMethodId}>
                    {method.typeName} •••• {method.lastFour} — {method.cardHolderName}
                  </option>
                ))}
              </select>
            </label>

            <button
              type="submit"
              disabled={
                !isConnected
                || cart.length === 0
                || isProcessingPayment
                || !addressId
                || !paymentMethodId
              }
              style={{ padding: '9px 14px', cursor: 'pointer' }}
            >
              {isProcessingPayment ? 'Procesando...' : 'Procesar pago'}
            </button>
          </form>
        )}

        {!isLoadingOptions && (addresses.length === 0 || paymentMethods.length === 0) && (
          <p>
            Registra los datos que faltan desde “Administrar datos de pago” para habilitar el pago.
          </p>
        )}

        {paymentError && (
          <p role="alert" style={{ color: '#ff6b6b', marginTop: '10px' }}>
            {paymentError}
          </p>
        )}
      </section>

      <section style={{ marginTop: '24px', paddingTop: '20px', borderTop: '1px solid #ddd' }}>
        <h3>Consultar orden pagada</h3>

        {availableOrders.length === 0 ? (
          <p>Todavía no tienes órdenes pagadas.</p>
        ) : (
          <form onSubmit={handleConsultOrder} style={{ display: 'flex', gap: '10px', flexWrap: 'wrap', alignItems: 'end' }}>
            <label style={{ display: 'flex', flexDirection: 'column', gap: '4px', minWidth: '280px' }}>
              Orden
              <select
                key={currentOrderId ?? 'saved-orders'}
                name="orderId"
                required
                defaultValue={currentOrderId ?? ''}
                style={{ padding: '8px' }}
              >
                <option value="">Selecciona una orden</option>
                {availableOrders.map((savedOrder) => (
                  <option key={savedOrder.orderId} value={savedOrder.orderId}>
                    Orden #{savedOrder.orderId} — {savedOrder.status} — {formatAmount(savedOrder.total)}
                  </option>
                ))}
              </select>
            </label>

            <button
              type="submit"
              disabled={!isConnected || isConsultingOrder}
              style={{ padding: '9px 14px', cursor: 'pointer' }}
            >
              {isConsultingOrder ? 'Consultando...' : 'Consultar orden'}
            </button>
          </form>
        )}

        {orderError && (
          <p role="alert" style={{ color: '#ff6b6b', marginTop: '10px' }}>
            {orderError}
          </p>
        )}
      </section>

      {currentOrder && (
        <section style={{ marginTop: '24px', padding: '16px', background: '#f7f7f7', color: '#222', borderRadius: '8px' }}>
          <h3>Orden #{currentOrder.orderId}</h3>
          <p style={{ color: '#146c2e', fontWeight: 'bold' }}>Orden cargada correctamente.</p>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '8px' }}>
            <span><strong>Fecha:</strong> {formatDate(currentOrder.orderCreationDate)}</span>
            <span><strong>Estado:</strong> {currentOrder.status}</span>
            <span><strong>Subtotal:</strong> {formatAmount(currentOrder.subtotal)}</span>
            <span><strong>Descuento:</strong> {formatAmount(currentOrder.discount)}</span>
            <span><strong>Envío:</strong> {formatAmount(currentOrder.shipping)}</span>
            <span><strong>Impuesto:</strong> {formatAmount(currentOrder.tax)}</span>
            <span><strong>Total:</strong> {formatAmount(currentOrder.total)}</span>
            <span><strong>Moneda ID:</strong> {currentOrder.currencyId}</span>
          </div>

          <div style={{ overflowX: 'auto', marginTop: '16px' }}>
            <table style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid #ccc' }}>
                  <th>Producto</th>
                  <th>Variante</th>
                  <th>Cant.</th>
                  <th>Precio</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                {orderDetails.map((detail) => (
                  <tr key={detail.orderDetailId} style={{ borderBottom: '1px solid #ddd' }}>
                    <td>{detail.productName}</td>
                    <td>{detail.productVariableValue}</td>
                    <td>{detail.quantity}</td>
                    <td>{formatAmount(detail.unitPrice)}</td>
                    <td>{formatAmount(detail.total)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      )}
    </div>
  );
}
