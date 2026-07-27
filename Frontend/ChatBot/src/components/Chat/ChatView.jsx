import React, { useEffect, useState } from 'react';
import { useChatStore } from '../../store/useChatStore';

export function ChatView() {
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
  }, []);

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

  return (
    <div style={{ padding: '20px', maxWidth: '600px', margin: '0 auto' }}>
      <h2>Chatbot ({isConnected ? '🟢 Conectado' : '🔴 Desconectado'})</h2>

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
                <p style={{ margin: '4px 0', fontWeight: 'bold' }}>{prod.CurrencyISO} {prod.ProductVariablePrice}</p>
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