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
    isConnected, 
    connectWebSocket, 
    sendMessage 
  } = useChatStore();

  useEffect(() => {
    connectWebSocket();
  }, [connectWebSocket]);

  const handleSend = (e) => {
    e.preventDefault();
    if (!inputText.trim()) return;

    // Se envía únicamente el texto (el store adjunta conversationId automáticamente)
    sendMessage(inputText);
    setInputText('');
  };

  const handleAddToCart = (productVariableId) => {
    // Parámetros exactos según la especificación del Contrato
    sendMessage('agregar al carrito', {
      productVariableId: productVariableId,
      quantity: 1,
    });
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

      {/* Historial de Mensajes */}
      <div 
        style={{ 
          height: '350px', 
          overflowY: 'auto', 
          border: '1px solid #ccc', 
          padding: '10px',
          borderRadius: '8px',
          marginBottom: '15px' 
        }}
      >
        {messages.map((msg, index) => (
          <div 
            key={index} 
            style={{ 
              textAlign: msg.sender === 'user' ? 'right' : 'left',
              margin: '8px 0' 
            }}
          >
            <span 
              style={{
                background: msg.sender === 'user' ? '#007bff' : '#e9ecef',
                color: msg.sender === 'user' ? '#fff' : '#000',
                padding: '8px 12px',
                borderRadius: '12px',
                display: 'inline-block'
              }}
            >
              {msg.text}
            </span>
          </div>
        ))}
      </div>

      {/* Tarjetas de Resultados de Búsqueda (si 'products' contiene items) */}
      {products.length > 0 && (
        <div style={{ marginBottom: '15px' }}>
          <h4>Resultados de Búsqueda</h4>
          <div style={{ display: 'flex', gap: '10px', overflowX: 'auto' }}>
            {products.map((prod) => (
              <div 
                key={prod.ProductVariableID} 
                style={{ border: '1px solid #ddd', padding: '10px', borderRadius: '6px', minWidth: '150px' }}
              >
                <strong>{prod.ProductName}</strong>
                <p style={{ margin: '4px 0' }}>{prod.ProductVariableName}</p>
                {prod.DiscountPercentage ? (
                  <div style={{ margin: '4px 0' }}>
                    {prod.OfferName && (
                      <div style={{ fontSize: '12px', color: '#555' }}>{prod.OfferName}</div>
                    )}
                    <span style={{ color: '#198754', fontWeight: 'bold' }}>
                      -{prod.DiscountPercentage}%
                    </span>
                    <div>
                      <span style={{ textDecoration: 'line-through', color: '#777', marginRight: '6px' }}>
                        {prod.CurrencyISO} {prod.OriginalPrice}
                      </span>
                      <strong>{prod.CurrencyISO} {prod.ProductVariablePrice}</strong>
                    </div>
                  </div>
                ) : (
                  <p style={{ margin: '4px 0', fontWeight: 'bold' }}>{prod.CurrencyISO} {prod.ProductVariablePrice}</p>
                )}
                <button onClick={() => handleAddToCart(prod.ProductVariableID)}>
                  Agregar al carrito
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Formulario de envío */}
      <form onSubmit={handleSend} style={{ display: 'flex', gap: '8px' }}>
        <input
          type="text"
          value={inputText}
          onChange={(e) => setInputText(e.target.value)}
          placeholder="Escribe 'quiero tenis' o 'ver carrito'..."
          style={{ flex: 1, padding: '8px' }}
        />
        <button type="submit" disabled={!isConnected}>Enviar</button>
      </form>
    </div>
  );
}
