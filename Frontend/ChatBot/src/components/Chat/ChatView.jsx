import { useEffect, useState } from 'react';
import { useChatStore } from '../../store/useChatStore';

export function ChatView() {
  const suggestions = [
    { label: 'Ver ofertas', message: 'ver ofertas' },
    { label: 'Buscar tenis', message: 'quiero tenis' },
    { label: 'Buscar camisetas', message: 'quiero camiseta' },
    { label: 'Ver mi carrito', message: 'ver carrito' },
  ];
  const [inputText, setInputText] = useState('');
  const {
    messages,
    products,
    cart,
    isCartVisible,
    addingProductIds,
    recentlyAddedProductIds,
    unavailableProductIds,
    isConnected,
    connectWebSocket,
    disconnectWebSocket,
    sendMessage,
    addProductToCart,
    hideCart,
  } = useChatStore();

  const cartTotal = cart.reduce(
    (total, item) => total + Number(item.total ?? 0),
    0,
  );

  useEffect(() => {
    connectWebSocket();
    return disconnectWebSocket;
  }, [connectWebSocket, disconnectWebSocket]);

  const handleSend = (event) => {
    event.preventDefault();
    if (!inputText.trim()) return;

    sendMessage(inputText);
    setInputText('');
  };

  const handleSuggestion = (message) => {
    sendMessage(message);
  };

  return (
    <div style={{ padding: '20px', maxWidth: '600px', margin: '0 auto' }}>
      <h2>Chatbot ({isConnected ? '🟢 Conectado' : '🔴 Desconectado'})</h2>

      <div
        aria-label="Sugerencias para el chat"
        style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginBottom: '12px' }}
      >
        {suggestions.map((suggestion) => (
          <button
            key={suggestion.message}
            type="button"
            disabled={!isConnected}
            onClick={() => handleSuggestion(suggestion.message)}
            style={{
              padding: '7px 12px',
              border: '1px solid #007bff',
              borderRadius: '999px',
              background: '#fff',
              color: '#007bff',
              cursor: isConnected ? 'pointer' : 'not-allowed',
            }}
          >
            {suggestion.label}
          </button>
        ))}
      </div>

      <div
        style={{
          height: '350px',
          overflowY: 'auto',
          border: '1px solid #ccc',
          padding: '10px',
          borderRadius: '8px',
          marginBottom: '15px',
        }}
      >
        {messages.map((message, index) => (
          <div
            key={index}
            style={{
              textAlign: message.sender === 'user' ? 'right' : 'left',
              margin: '8px 0',
            }}
          >
            <span
              style={{
                background: message.sender === 'user' ? '#007bff' : '#e9ecef',
                color: message.sender === 'user' ? '#fff' : '#000',
                padding: '8px 12px',
                borderRadius: '12px',
                display: 'inline-block',
              }}
            >
              {message.text}
            </span>
          </div>
        ))}
      </div>

      {products.length > 0 && (
        <section style={{ marginBottom: '15px' }}>
          <h4>Resultados de búsqueda</h4>

          <div style={{ display: 'flex', gap: '10px', overflowX: 'auto' }}>
            {products.map((product) => {
              const productVariableId = product.ProductVariableID;
              const stockAvailable = Number(product.StockAvailable ?? 0);
              const quantityInCart = Number(
                cart.find((item) => item.productVariableId === productVariableId)?.quantity ?? 0,
              );
              const isAdding = addingProductIds.includes(productVariableId);
              const wasRecentlyAdded = recentlyAddedProductIds.includes(productVariableId);
              const wasRejectedForStock = unavailableProductIds.includes(productVariableId);
              const isOutOfStock = stockAvailable <= 0 || wasRejectedForStock;
              const reachedCartLimit = !isOutOfStock && quantityInCart >= stockAvailable;

              return (
                <article
                  key={productVariableId}
                  style={{ border: '1px solid #ddd', padding: '10px', borderRadius: '6px', minWidth: '150px' }}
                >
                  <strong>{product.ProductName}</strong>
                  <p style={{ margin: '4px 0' }}>{product.ProductVariableName}</p>
                  {product.DiscountPercentage ? (
                    <div style={{ margin: '4px 0' }}>
                      {product.OfferName && (
                        <div style={{ fontSize: '12px', color: '#555' }}>{product.OfferName}</div>
                      )}
                      <span style={{ color: '#198754', fontWeight: 'bold' }}>
                        -{product.DiscountPercentage}%
                      </span>
                      <div>
                        <span style={{ textDecoration: 'line-through', color: '#777', marginRight: '6px' }}>
                          {product.CurrencyISO} {product.OriginalPrice}
                        </span>
                        <strong>{product.CurrencyISO} {product.ProductVariablePrice}</strong>
                      </div>
                    </div>
                  ) : (
                    <p style={{ margin: '4px 0', fontWeight: 'bold' }}>
                      {product.CurrencyISO} {product.ProductVariablePrice}
                    </p>
                  )}
                  <p style={{ margin: '4px 0', fontSize: '14px' }}>
                    Stock: {stockAvailable}
                    {quantityInCart > 0 ? ` · En carrito: ${quantityInCart}` : ''}
                  </p>
                  <button
                    type="button"
                    onClick={() => addProductToCart(productVariableId)}
                    disabled={
                      !isConnected
                      || isAdding
                      || wasRecentlyAdded
                      || isOutOfStock
                      || reachedCartLimit
                    }
                    aria-live="polite"
                  >
                    {isAdding
                      ? 'Agregando...'
                      : wasRecentlyAdded
                        ? 'Agregado ✓'
                        : isOutOfStock
                          ? '¡Fuera de stock!'
                          : reachedCartLimit
                            ? 'Stock máximo alcanzado'
                            : 'Agregar al carrito'}
                  </button>
                </article>
              );
            })}
          </div>
        </section>
      )}

      {isCartVisible && (
        <section style={{ marginBottom: '15px', border: '1px solid #ddd', borderRadius: '8px', padding: '12px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '12px' }}>
            <h4 style={{ margin: 0 }}>Tu carrito</h4>
            <button type="button" onClick={hideCart}>Ocultar carrito</button>
          </div>

          {cart.length === 0 ? (
            <p style={{ marginBottom: 0 }}>El carrito está vacío.</p>
          ) : (
            <>
              <ul style={{ paddingLeft: '20px' }}>
                {cart.map((item) => (
                  <li key={item.cartDetailId} style={{ marginBottom: '6px' }}>
                    <strong>{item.productName}</strong>
                    {' — '}
                    {item.productVariableValue}
                    {' · '}
                    {item.quantity} × ${Number(item.unitPrice ?? 0).toFixed(2)}
                  </li>
                ))}
              </ul>
              <strong>Total: ${cartTotal.toFixed(2)}</strong>
              <p style={{ marginBottom: 0, fontSize: '14px' }}>
                Puedes quitar productos o procesar el pago en la sección inferior.
              </p>
            </>
          )}
        </section>
      )}

      <form onSubmit={handleSend} style={{ display: 'flex', gap: '8px' }}>
        <input
          type="text"
          value={inputText}
          onChange={(event) => setInputText(event.target.value)}
          placeholder="Escribe 'quiero tenis' o 'ver carrito'..."
          style={{ flex: 1, padding: '8px' }}
        />
        <button type="submit" disabled={!isConnected}>Enviar</button>
      </form>
    </div>
  );
}
