import api from '../api/axios';

export const getCheckoutOptions = async () => {
  const { data } = await api.get('/checkout/options');
  return data;
};

export const createAddress = async (payload) => {
  const { data } = await api.post('/checkout/addresses', payload);
  return data.address;
};

export const createPaymentMethod = async (payload) => {
  const { data } = await api.post('/checkout/payment-methods', payload);
  return data.paymentMethod;
};
