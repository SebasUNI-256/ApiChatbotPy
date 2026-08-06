import { create } from 'zustand';
import api from '../api/axios';

export const useAuthStore = create((set) => ({
  user: null,
  isAuthenticated: false,
  isLoading: true,

  checkSession: async () => {
    try {
      const { data } = await api.get('/auth/session');
      set({ user: data.user, isAuthenticated: true, isLoading: false });
    } catch {
      set({ user: null, isAuthenticated: false, isLoading: false });
    }
  },

  login: async (credentials) => {
    const { data } = await api.post('/auth/login', credentials);
    set({ user: data.user, isAuthenticated: true });
    return data;
  },

  logout: async () => {
    await api.post('/auth/logout');
    set({ user: null, isAuthenticated: false });
  },
}));