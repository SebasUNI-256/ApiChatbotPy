import { useEffect, useState } from 'react';
import {
  createAddress,
  createPaymentMethod,
  getCheckoutOptions,
} from '../../services/checkoutService';

const emptyAddress = {
  zipCode: '',
  description: '',
  isPrincipal: true,
};

const emptyPaymentMethod = {
  paymentMethodTypeId: '',
  cardHolderName: '',
  cardNumber: '',
  expirationDate: '',
  cvv: '',
};

const formatMonth = (date) => (
  `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`
);

const today = new Date();
const minimumExpiration = formatMonth(new Date(today.getFullYear(), today.getMonth() + 1, 1));
const maximumExpiration = formatMonth(new Date(today.getFullYear() + 15, today.getMonth(), 1));

const getErrorMessage = (error, fallback) => (
  error.response?.data?.errors?.[0]?.message
  || error.response?.data?.detail
  || error.response?.data?.resultMessage
  || fallback
);

export function PaymentMethodsView({ onBack }) {
  const [addresses, setAddresses] = useState([]);
  const [paymentMethods, setPaymentMethods] = useState([]);
  const [paymentMethodTypes, setPaymentMethodTypes] = useState([]);
  const [addressForm, setAddressForm] = useState(emptyAddress);
  const [paymentForm, setPaymentForm] = useState(emptyPaymentMethod);
  const [isLoading, setIsLoading] = useState(true);
  const [isSavingAddress, setIsSavingAddress] = useState(false);
  const [isSavingPayment, setIsSavingPayment] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  useEffect(() => {
    let isActive = true;

    getCheckoutOptions()
      .then((data) => {
        if (!isActive) return;

        setAddresses(data.addresses);
        setPaymentMethods(data.paymentMethods);
        setPaymentMethodTypes(data.paymentMethodTypes);
        setPaymentForm((current) => ({
          ...current,
          paymentMethodTypeId: current.paymentMethodTypeId
            || String(data.paymentMethodTypes[0]?.paymentMethodTypeId ?? ''),
        }));
      })
      .catch((requestError) => {
        if (isActive) {
          setError(getErrorMessage(requestError, 'No fue posible cargar los datos de pago.'));
        }
      })
      .finally(() => {
        if (isActive) setIsLoading(false);
      });

    return () => {
      isActive = false;
    };
  }, []);

  const handleAddressSubmit = async (event) => {
    event.preventDefault();
    setError('');
    setSuccess('');
    setIsSavingAddress(true);

    try {
      const address = await createAddress({
        zipCode: Number(addressForm.zipCode),
        description: addressForm.description.trim(),
        isPrincipal: addressForm.isPrincipal,
      });
      setAddresses((current) => [
        ...current.map((item) => (
          address.isPrincipal ? { ...item, isPrincipal: false } : item
        )),
        address,
      ]);
      setAddressForm({ ...emptyAddress, isPrincipal: false });
      setSuccess('Dirección registrada correctamente.');
    } catch (requestError) {
      setError(getErrorMessage(requestError, 'No fue posible registrar la dirección.'));
    } finally {
      setIsSavingAddress(false);
    }
  };

  const handlePaymentSubmit = async (event) => {
    event.preventDefault();
    setError('');
    setSuccess('');
    setIsSavingPayment(true);

    try {
      const paymentMethod = await createPaymentMethod({
        paymentMethodTypeId: Number(paymentForm.paymentMethodTypeId),
        cardHolderName: paymentForm.cardHolderName.trim(),
        cardNumber: paymentForm.cardNumber,
        expirationDate: paymentForm.expirationDate,
        cvv: paymentForm.cvv,
      });
      setPaymentMethods((current) => [...current, paymentMethod]);
      setPaymentForm((current) => ({
        ...emptyPaymentMethod,
        paymentMethodTypeId: current.paymentMethodTypeId,
      }));
      setSuccess('Método de pago registrado correctamente. El CVV no será mostrado nuevamente.');
    } catch (requestError) {
      setError(getErrorMessage(requestError, 'No fue posible registrar el método de pago.'));
    } finally {
      setIsSavingPayment(false);
    }
  };

  return (
    <main style={{ maxWidth: '800px', margin: '24px auto', padding: '20px' }}>
      <button onClick={onBack} style={{ marginBottom: '20px' }}>
        ← Volver al chatbot
      </button>

      <h2>Datos para el pago</h2>
      <p>Administra aquí tus direcciones y métodos de pago. El chatbot solo mostrará opciones guardadas.</p>

      {error && <p role="alert" style={{ color: '#ff6b6b' }}>{error}</p>}
      {success && <p style={{ color: '#45c46a' }}>{success}</p>}
      {isLoading && <p>Cargando datos...</p>}

      {!isLoading && (
        <>
          <section style={{ border: '1px solid #777', borderRadius: '8px', padding: '18px', marginBottom: '24px' }}>
            <h3>Direcciones guardadas</h3>
            {addresses.length === 0 ? (
              <p>No tienes direcciones registradas.</p>
            ) : (
              <ul>
                {addresses.map((address) => (
                  <li key={address.addressId}>
                    {address.description} — C.P. {address.zipCode}
                    {address.isPrincipal ? ' (principal)' : ''}
                  </li>
                ))}
              </ul>
            )}

            <form onSubmit={handleAddressSubmit} style={{ display: 'grid', gap: '10px' }}>
              <h4>Agregar dirección</h4>
              <label>
                Código postal
                <input
                  type="text"
                  inputMode="numeric"
                  pattern="[0-9]{4,9}"
                  minLength="4"
                  maxLength="9"
                  required
                  value={addressForm.zipCode}
                  onChange={(event) => setAddressForm({
                    ...addressForm,
                    zipCode: event.target.value.replace(/\D/g, '').slice(0, 9),
                  })}
                  title="Escribe entre 4 y 9 dígitos."
                  style={{ display: 'block', width: '100%', padding: '8px', boxSizing: 'border-box' }}
                />
              </label>
              <label>
                Dirección de entrega
                <textarea
                  required
                  minLength="10"
                  maxLength="200"
                  value={addressForm.description}
                  onChange={(event) => setAddressForm({ ...addressForm, description: event.target.value })}
                  title="Escribe una dirección de entre 10 y 200 caracteres."
                  style={{ display: 'block', width: '100%', padding: '8px', boxSizing: 'border-box' }}
                />
              </label>
              <label>
                <input
                  type="checkbox"
                  checked={addressForm.isPrincipal}
                  onChange={(event) => setAddressForm({ ...addressForm, isPrincipal: event.target.checked })}
                />{' '}
                Usar como dirección principal
              </label>
              <button type="submit" disabled={isSavingAddress}>
                {isSavingAddress ? 'Guardando...' : 'Guardar dirección'}
              </button>
            </form>
          </section>

          <section style={{ border: '1px solid #777', borderRadius: '8px', padding: '18px' }}>
            <h3>Métodos de pago guardados</h3>
            {paymentMethods.length === 0 ? (
              <p>No tienes métodos de pago registrados.</p>
            ) : (
              <ul>
                {paymentMethods.map((method) => (
                  <li key={method.paymentMethodId}>
                    {method.typeName} •••• {method.lastFour} — {method.cardHolderName} — vence {method.expirationDate}
                  </li>
                ))}
              </ul>
            )}

            <form onSubmit={handlePaymentSubmit} style={{ display: 'grid', gap: '10px' }}>
              <h4>Agregar método de pago</h4>
              <label>
                Tipo
                <select
                  required
                  value={paymentForm.paymentMethodTypeId}
                  onChange={(event) => setPaymentForm({ ...paymentForm, paymentMethodTypeId: event.target.value })}
                  style={{ display: 'block', width: '100%', padding: '8px' }}
                >
                  <option value="">Selecciona un tipo</option>
                  {paymentMethodTypes.map((type) => (
                    <option key={type.paymentMethodTypeId} value={type.paymentMethodTypeId}>
                      {type.name}
                    </option>
                  ))}
                </select>
              </label>
              <label>
                Titular
                <input
                  type="text"
                  autoComplete="cc-name"
                  minLength="3"
                  maxLength="100"
                  required
                  value={paymentForm.cardHolderName}
                  onChange={(event) => setPaymentForm({ ...paymentForm, cardHolderName: event.target.value })}
                  style={{ display: 'block', width: '100%', padding: '8px', boxSizing: 'border-box' }}
                />
              </label>
              <label>
                Número de tarjeta
                <input
                  type="text"
                  inputMode="numeric"
                  autoComplete="cc-number"
                  pattern="[0-9]{13,19}"
                  minLength="13"
                  maxLength="19"
                  required
                  value={paymentForm.cardNumber}
                  onChange={(event) => setPaymentForm({
                    ...paymentForm,
                    cardNumber: event.target.value.replace(/\D/g, ''),
                  })}
                  style={{ display: 'block', width: '100%', padding: '8px', boxSizing: 'border-box' }}
                />
              </label>
              <label>
                Vencimiento
                <input
                  type="month"
                  autoComplete="cc-exp"
                  min={minimumExpiration}
                  max={maximumExpiration}
                  required
                  value={paymentForm.expirationDate}
                  onChange={(event) => setPaymentForm({ ...paymentForm, expirationDate: event.target.value })}
                  style={{ display: 'block', width: '100%', padding: '8px', boxSizing: 'border-box' }}
                />
              </label>
              <label>
                CVV
                <input
                  type="password"
                  inputMode="numeric"
                  autoComplete="cc-csc"
                  pattern="[0-9]{3,4}"
                  minLength="3"
                  maxLength="4"
                  required
                  value={paymentForm.cvv}
                  onChange={(event) => setPaymentForm({
                    ...paymentForm,
                    cvv: event.target.value.replace(/\D/g, ''),
                  })}
                  style={{ display: 'block', width: '100%', padding: '8px', boxSizing: 'border-box' }}
                />
              </label>
              <p style={{ fontSize: '14px' }}>
                El CVV se envía únicamente al guardar y nunca se devuelve ni se muestra en la aplicación.
              </p>
              <button type="submit" disabled={isSavingPayment || paymentMethodTypes.length === 0}>
                {isSavingPayment ? 'Guardando...' : 'Guardar método de pago'}
              </button>
            </form>
          </section>
        </>
      )}
    </main>
  );
}
