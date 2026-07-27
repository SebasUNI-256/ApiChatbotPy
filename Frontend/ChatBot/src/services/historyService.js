import api from '../api/axios';

// Obtener todas las conversaciones del usuario autenticado
export const getUserConversations = async (userId) => {
  const { data } = await api.get(`/users/${userId}/conversations`);
  return data;
};

// Leer los mensajes de una conversación específica
export const getConversationMessages = async (conversationId) => {
  const { data } = await api.get(`/conversations/${conversationId}/messages`);
  return data;
};

// Cerrar una conversación
export const closeConversation = async (conversationId) => {
  const { data } = await api.post(`/conversations/${conversationId}/close`);
  return data;
};

// Eliminar una conversación
export const deleteConversation = async (conversationId) => {
  const { data } = await api.delete(`/conversations/${conversationId}`);
  return data;
};