import { useEffect, useState } from 'react';
import { useChatStore } from '../../store/useChatStore';

export function ChatView() {
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
    0
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


  return (
    <div
      style={{
        minHeight:'100vh',
        background:'#f1f5f9',
        padding:'25px',
        fontFamily:'Inter, Arial, sans-serif',
        color:'#1e293b'
      }}
    >

      <div
        style={{
          maxWidth:'900px',
          margin:'auto'
        }}
      >


        {/* HEADER */}

        <header
          style={{
            background:'#ffffff',
            padding:'20px',
            borderRadius:'18px',
            marginBottom:'20px',
            boxShadow:'0 4px 12px rgba(15,23,42,.08)',
            textAlign:'center'
          }}
        >

          <h2
            style={{
              margin:0,
              fontSize:'24px',
              color:'#0f172a'
            }}
          >
            🤖 Chatbot Ecommerce
          </h2>


          <p
            style={{
              margin:'8px 0 0',
              color:isConnected ? '#16a34a' : '#dc2626',
              fontWeight:'600'
            }}
          >
            {isConnected
              ? '● Conectado'
              : '● Desconectado'}
          </p>


        </header>



        {/* CHAT */}

        <section
          style={{
            height:'400px',
            overflowY:'auto',
            background:'#ffffff',
            padding:'20px',
            borderRadius:'18px',
            boxShadow:'0 4px 12px rgba(15,23,42,.08)'
          }}
        >


          {messages.length === 0 && (

            <p
              style={{
                textAlign:'center',
                color:'#64748b'
              }}
            >
              Escribe un mensaje para comenzar 🛒
            </p>

          )}



          {messages.map((message,index)=>(

            <div
              key={index}
              style={{
                display:'flex',
                justifyContent:
                  message.sender === 'user'
                  ? 'flex-end'
                  : 'flex-start',
                marginBottom:'12px'
              }}
            >

              <div
                style={{
                  maxWidth:'70%',
                  padding:'12px 16px',
                  borderRadius:
                    message.sender === 'user'
                    ? '18px 18px 0 18px'
                    : '18px 18px 18px 0',

                  background:
                    message.sender === 'user'
                    ? '#2563eb'
                    : '#e2e8f0',

                  color:
                    message.sender === 'user'
                    ? '#ffffff'
                    : '#1e293b'
                }}
              >
                {message.text}
              </div>

            </div>

          ))}


        </section>




        {/* PRODUCTOS */}

        {products.length > 0 && (

          <section
            style={{
              marginTop:'25px'
            }}
          >

            <h3>
              🛍️ Productos encontrados
            </h3>


            <div
              style={{
                display:'grid',
                gridTemplateColumns:
                'repeat(auto-fill,minmax(220px,1fr))',
                gap:'18px'
              }}
            >


            {products.map(product=>{


              const id = product.ProductVariableID;

              const stock =
                Number(product.StockAvailable ?? 0);


              const quantity =
                Number(
                  cart.find(
                    item=>item.productVariableId===id
                  )?.quantity ?? 0
                );


              const adding =
                addingProductIds.includes(id);


              const added =
                recentlyAddedProductIds.includes(id);


              const noStock =
                stock <= 0 ||
                unavailableProductIds.includes(id);


              const limit =
                quantity >= stock;



              return (

                <article
                  key={id}
                  style={{
                    background:'#ffffff',
                    padding:'18px',
                    borderRadius:'18px',
                    border:'1px solid #e2e8f0',
                    boxShadow:
                    '0 3px 10px rgba(15,23,42,.06)'
                  }}
                >


                  <h4>
                    {product.ProductName}
                  </h4>


                  <p
                    style={{
                      color:'#64748b'
                    }}
                  >
                    {product.ProductVariableName}
                  </p>


                  <h3
                    style={{
                      color:'#2563eb'
                    }}
                  >
                    {product.CurrencyISO}
                    {' '}
                    {product.ProductVariablePrice}
                  </h3>


                  <small>
                    Stock disponible: {stock}
                  </small>



                  <button
                    onClick={() =>
                      addProductToCart(id)
                    }

                    disabled={
                      !isConnected ||
                      adding ||
                      added ||
                      noStock ||
                      limit
                    }

                    style={{
                      width:'100%',
                      marginTop:'15px',
                      padding:'12px',
                      borderRadius:'12px',
                      border:'none',
                      background:
                        noStock || limit
                        ? '#94a3b8'
                        : '#2563eb',
                      color:'#ffffff',
                      fontWeight:'600',
                      cursor:'pointer'
                    }}
                  >

                  {
                    adding
                    ? 'Agregando...'
                    :
                    added
                    ? '✓ Agregado'
                    :
                    noStock
                    ? 'Sin stock'
                    :
                    limit
                    ? 'Máximo'
                    :
                    'Agregar al carrito'
                  }

                  </button>


                </article>

              );


            })}


            </div>


          </section>

        )}






        {/* CARRITO */}

        {isCartVisible && (

          <section
            style={{
              marginTop:'25px',
              background:'#ffffff',
              padding:'20px',
              borderRadius:'18px',
              boxShadow:
              '0 4px 12px rgba(15,23,42,.08)'
            }}
          >

            <div
              style={{
                display:'flex',
                justifyContent:'space-between',
                alignItems:'center'
              }}
            >

              <h3>
                🛒 Carrito
              </h3>


              <button
                onClick={hideCart}
                style={{
                  border:'none',
                  background:'#fee2e2',
                  color:'#dc2626',
                  padding:'8px 12px',
                  borderRadius:'10px'
                }}
              >
                Ocultar
              </button>


            </div>



            {
              cart.length===0

              ?

              <p>
                El carrito está vacío
              </p>

              :

              <>

              {
                cart.map(item=>(

                  <p key={item.cartDetailId}>

                    <b>
                      {item.productName}
                    </b>

                    {' '}
                    x{item.quantity}

                    {' '}

                    ${Number(item.unitPrice).toFixed(2)}

                  </p>

                ))
              }


              <h3>
                Total:
                {' '}
                ${cartTotal.toFixed(2)}
              </h3>

              </>

            }


          </section>

        )}






        {/* INPUT */}

        <form
          onSubmit={handleSend}
          style={{
            display:'flex',
            gap:'12px',
            marginTop:'25px'
          }}
        >

          <input

            value={inputText}

            onChange={
              e=>setInputText(e.target.value)
            }

            placeholder="Ejemplo: quiero tenis"

            style={{
              flex:1,
              padding:'14px',
              borderRadius:'14px',
              border:'1px solid #cbd5e1',
              background:'#ffffff',
              color:'#1e293b',
              fontSize:'15px'
            }}

          />


          <button
            disabled={!isConnected}

            style={{
              padding:'14px 25px',
              borderRadius:'14px',
              border:'none',
              background:'#16a34a',
              color:'#ffffff',
              fontWeight:'700'
            }}
          >
            Enviar
          </button>


        </form>


      </div>

    </div>
  );
}