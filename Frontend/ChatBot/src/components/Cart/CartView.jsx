import { useEffect, useState } from 'react';
import { getCheckoutOptions } from '../../services/checkoutService';
import { useChatStore } from '../../store/useChatStore';

const formatAmount = (value) =>
  Number(value ?? 0).toFixed(2);

const formatDate = (value) => {
  if (!value) return 'No disponible';

  const date = new Date(value);

  return Number.isNaN(date.getTime())
    ? value
    : date.toLocaleString();
};

const getErrorMessage = (error, fallback) =>
  error.response?.data?.detail ||
  error.response?.data?.resultMessage ||
  fallback;


export function CartView({ onManagePaymentMethods }) {


  const [addresses,setAddresses] = useState([]);
  const [paymentMethods,setPaymentMethods] = useState([]);
  const [savedOrders,setSavedOrders] = useState([]);

  const [addressId,setAddressId] = useState('');
  const [paymentMethodId,setPaymentMethodId] = useState('');

  const [isLoadingOptions,setIsLoadingOptions] = useState(true);
  const [optionsError,setOptionsError] = useState('');


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
    consultOrder

  } = useChatStore();



  const currentOrder = order?.order;
  const orderDetails = order?.details ?? [];

  const currentOrderId = currentOrder?.orderId;


  const availableOrders =
    currentOrderId &&
    !savedOrders.some(
      item=>item.orderId===currentOrderId
    )
    ?
    [
      currentOrder,
      ...savedOrders
    ]
    :
    savedOrders;



  const cartTotal = cart.reduce(
    (total,item)=>
      total + Number(item.total ?? 0),
    0
  );



  useEffect(()=>{


    let active=true;


    getCheckoutOptions()

    .then(data=>{

      if(!active)return;


      const principal =
        data.addresses.find(
          item=>item.isPrincipal
        );


      setAddresses(data.addresses);

      setPaymentMethods(
        data.paymentMethods
      );

      setSavedOrders(
        data.orders
      );


      setAddressId(
        String(
          principal?.addressId ??
          data.addresses[0]?.addressId ??
          ''
        )
      );


      setPaymentMethodId(
        String(
          data.paymentMethods[0]
          ?.paymentMethodId ?? ''
        )
      );


    })


    .catch(error=>{

      if(active)
      {
        setOptionsError(
          getErrorMessage(
            error,
            'No fue posible cargar los datos.'
          )
        );
      }

    })


    .finally(()=>{

      if(active)
        setIsLoadingOptions(false);

    });



    return ()=> active=false;


  },[]);





  const removeItem=(cartDetailId)=>{

    sendMessage(
      'quitar del carrito',
      {
        cartDetailId
      }
    );

  };





  const refreshCart=()=>{

    sendMessage(
      'ver carrito'
    );

  };





  const handlePayment=(e)=>{

    e.preventDefault();

    processPayment(
      Number(addressId),
      Number(paymentMethodId)
    );

  };





  const handleConsultOrder=(e)=>{

    e.preventDefault();


    const data =
      new FormData(
        e.currentTarget
      );


    consultOrder(
      Number(
        data.get('orderId')
      )
    );

  };






return (


<div
style={{
minHeight:'100vh',
background:'#f1f5f9',
padding:'25px',
fontFamily:'Inter,Arial,sans-serif',
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
boxShadow:
'0 4px 12px rgba(15,23,42,.08)',
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
🛒 Carrito Ecommerce
</h2>


<p
style={{
color:
isConnected
?
'#16a34a'
:
'#dc2626',
fontWeight:'600'
}}
>

{
isConnected
?
'● Conectado'
:
'● Desconectado'
}

</p>


</header>





{/* CARRITO */}


<section
style={{
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
🛍️ Productos
</h3>


<button

onClick={refreshCart}

style={{
background:'#dbeafe',
color:'#2563eb',
border:'none',
padding:'10px 14px',
borderRadius:'12px',
fontWeight:'600',
cursor:'pointer'
}}

>
Actualizar
</button>


</div>



{
cart.length===0

?

<p>
El carrito está vacío
</p>


:

cart.map(item=>(


<div
key={item.cartDetailId}
style={{
display:'flex',
justifyContent:'space-between',
alignItems:'center',
padding:'14px',
marginTop:'12px',
background:'#f8fafc',
borderRadius:'14px'
}}
>


<div>

<b>
{item.productName}
</b>

<p
style={{
margin:0,
color:'#64748b'
}}
>
Cantidad: {item.quantity}
</p>

</div>



<div>


<strong>
${formatAmount(item.total)}
</strong>



<button

onClick={()=>
removeItem(
item.cartDetailId
)
}

style={{
marginLeft:'15px',
background:'#fee2e2',
color:'#dc2626',
border:'none',
padding:'8px 12px',
borderRadius:'10px',
cursor:'pointer'
}}

>
Quitar
</button>


</div>


</div>


))

}




<h2
style={{
textAlign:'right',
color:'#2563eb'
}}
>
Total:
${cartTotal.toFixed(2)}
</h2>


</section>







{/* PAGO */}



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
justifyContent:'space-between'
}}
>

<h3>
💳 Procesar pago
</h3>


<button

onClick={onManagePaymentMethods}

style={{
background:'#e2e8f0',
border:'none',
padding:'10px',
borderRadius:'12px',
cursor:'pointer'
}}

>
Administrar pagos
</button>


</div>




{
isLoadingOptions &&
<p>
Cargando datos...
</p>
}



{
optionsError &&
<p style={{color:'#dc2626'}}>
{optionsError}
</p>
}



{
!isLoadingOptions &&
<form
onSubmit={handlePayment}
style={{
display:'grid',
gap:'15px'
}}
>


<select

value={addressId}

onChange={
e=>setAddressId(
e.target.value
)
}

style={{
padding:'12px',
borderRadius:'12px'
}}

>

<option value="">
Dirección
</option>


{
addresses.map(a=>(

<option
key={a.addressId}
value={a.addressId}
>
{a.description}
</option>

))

}


</select>





<select

value={paymentMethodId}

onChange={
e=>setPaymentMethodId(
e.target.value
)
}

style={{
padding:'12px',
borderRadius:'12px'
}}

>


<option value="">
Método de pago
</option>


{
paymentMethods.map(m=>(

<option
key={m.paymentMethodId}
value={m.paymentMethodId}
>

{m.typeName}
••••
{m.lastFour}

</option>

))

}


</select>




<button

disabled={
!isConnected ||
cart.length===0 ||
isProcessingPayment
}

style={{
background:'#16a34a',
color:'#fff',
border:'none',
padding:'14px',
borderRadius:'14px',
fontWeight:'700',
cursor:'pointer'
}}

>

{
isProcessingPayment
?
'Procesando...'
:
'Procesar pago'
}

</button>



</form>
}




{
paymentError &&
<p
style={{
color:'#dc2626'
}}
>
{paymentError}
</p>
}


</section>







{/* CONSULTAR ORDEN */}


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


<h3>
📦 Consultar orden
</h3>



<form
onSubmit={handleConsultOrder}
style={{
display:'flex',
gap:'10px'
}}
>


<select

name="orderId"

style={{
flex:1,
padding:'12px',
borderRadius:'12px'
}}

>

<option value="">
Selecciona orden
</option>


{
availableOrders.map(o=>(

<option
key={o.orderId}
value={o.orderId}
>

Orden #{o.orderId}

</option>

))

}


</select>



<button

disabled={
!isConnected ||
isConsultingOrder
}

style={{
background:'#2563eb',
color:'#fff',
border:'none',
padding:'12px 18px',
borderRadius:'12px'
}}

>

{
isConsultingOrder
?
'Consultando...'
:
'Consultar'
}

</button>



</form>



{
orderError &&
<p style={{color:'#dc2626'}}>
{orderError}
</p>
}



</section>







{/* DETALLE ORDEN */}



{
currentOrder &&


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


<h3>
Orden #{currentOrder.orderId}
</h3>


<p>
Fecha:
{formatDate(
currentOrder.orderCreationDate
)}
</p>


<p>
Estado:
{currentOrder.status}
</p>


<h3
style={{
color:'#2563eb'
}}
>
Total:
${formatAmount(currentOrder.total)}
</h3>



{
orderDetails.map(d=>(

<p
key={d.orderDetailId}
>

{d.productName}
x{d.quantity}

</p>

))

}



</section>

}



</div>

</div>


);


}