import React from 'react';
import { useChatStore } from '../../store/useChatStore';

export function CartView() {
  const { cart, sendMessage } = useChatStore();

  const handleRemoveItem = (cartDetailId) => {
    // REGLA CRÍTICA: Se debe usar cartDetailId para eliminar, NUNCA productVariableId
    sendMessage('quitar del carrito', {
      cartDetailId: cartDetailId,
    });
  };

  const handleRefreshCart = () => {
    sendMessage('ver carrito');
  };

  // Cálculo del total local según los ítems devueltos en la lista
  const calculateTotal = () => {
    return cart.reduce((acc, item) => acc + item.total, 0);
  };

  return (
    <div style={{ padding: '20px', maxWidth: '600px', margin: '20px auto', border: '1px solid #ddd', borderRadius: '8px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h3>Tu Carrito de Compras</h3>
        <button onClick={handleRefreshCart}>Actualizar Carrito</button>
      </div>

      {cart.length === 0 ? (
        <p>El carrito está vacío. Consulta en el chat para agregar productos.</p>
      ) : (
        <div>
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
                  <td>${item.unitPrice}</td>
                  <td>${item.total}</td>
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
    </div>
  );
}