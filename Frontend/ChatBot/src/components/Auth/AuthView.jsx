import React, { useState } from 'react';
import { useAuthStore } from '../../store/useAuthStore';
export function AuthView() {
  const [isLoginTab, setIsLoginTab] = useState(true);
  const [errorMsg, setErrorMsg] = useState('');
  const [loading, setLoading] = useState(false);

  const login = useAuthStore((state) => state.login);

  // Estado para el formulario de Login (según contrato: identifier y password)
  const [loginData, setLoginData] = useState({
    identifier: '',
    password: '',
  });

  // Estado para el formulario de Registro (campos exactos del contrato)
  const [registerData, setRegisterData] = useState({
    fullName: '',
    username: '',
    email: '',
    password: '',
    phoneNumber: '',
    countryId: 1,
    genderId: 1,
    birthDate: '',
  });

  const handleLoginSubmit = async (e) => {
    e.preventDefault();
    setErrorMsg('');
    setLoading(true);

    try {
      await login(loginData);
    } catch (error) {
      setErrorMsg(error.response?.data?.resultMessage || 'Error al iniciar sesión. Revisa tus credenciales.');
    } finally {
      setLoading(false);
    }
  };

  const handleRegisterSubmit = async (e) => {
    e.preventDefault();
    setErrorMsg('');
    setLoading(true);

    try {
      // Importamos api directamente para registrar
      const { default: api } = await import('../../api/axios');
      const response = await api.post('/auth/register', {
        ...registerData,
        countryId: Number(registerData.countryId),
        genderId: Number(registerData.genderId),
      });

      if (response.data.user) {
        // Al registrarse con éxito, actualizamos el store
        useAuthStore.setState({ user: response.data.user, isAuthenticated: true });
      }
    } catch (error) {
      setErrorMsg(error.response?.data?.resultMessage || 'Error al registrar usuario.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: '400px', margin: '50px auto', padding: '20px', border: '1px solid #ddd', borderRadius: '8px' }}>
      {/* Botones de pestaña */}
      <div style={{ display: 'flex', marginBottom: '20px' }}>
        <button
          onClick={() => { setIsLoginTab(true); setErrorMsg(''); }}
          style={{ flex: 1, padding: '10px', background: isLoginTab ? '#007bff' : '#eee', color: isLoginTab ? '#fff' : '#000', border: 'none', cursor: 'pointer' }}
        >
          Iniciar Sesión
        </button>
        <button
          onClick={() => { setIsLoginTab(false); setErrorMsg(''); }}
          style={{ flex: 1, padding: '10px', background: !isLoginTab ? '#007bff' : '#eee', color: !isLoginTab ? '#fff' : '#000', border: 'none', cursor: 'pointer' }}
        >
          Registrarse
        </button>
      </div>

      {errorMsg && <p style={{ color: 'red', fontSize: '14px' }}>{errorMsg}</p>}

      {/* Formulario de Login */}
      {isLoginTab ? (
        <form onSubmit={handleLoginSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          <h3>Iniciar Sesión</h3>
          <input
            type="text"
            placeholder="Usuario o Correo"
            value={loginData.identifier}
            onChange={(e) => setLoginData({ ...loginData, identifier: e.target.value })}
            required
            style={{ padding: '8px' }}
          />
          <input
            type="password"
            placeholder="Contraseña"
            value={loginData.password}
            onChange={(e) => setLoginData({ ...loginData, password: e.target.value })}
            required
            style={{ padding: '8px' }}
          />
          <button type="submit" disabled={loading} style={{ padding: '10px', background: '#28a745', color: '#fff', border: 'none', cursor: 'pointer' }}>
            {loading ? 'Ingresando...' : 'Entrar'}
          </button>
        </form>
      ) : (
        /* Formulario de Registro */
        <form onSubmit={handleRegisterSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          <h3>Crear Cuenta</h3>
          <input
            type="text"
            placeholder="Nombre Completo"
            value={registerData.fullName}
            onChange={(e) => setRegisterData({ ...registerData, fullName: e.target.value })}
            required
            style={{ padding: '8px' }}
          />
          <input
            type="text"
            placeholder="Nombre de usuario"
            value={registerData.username}
            onChange={(e) => setRegisterData({ ...registerData, username: e.target.value })}
            required
            style={{ padding: '8px' }}
          />
          <input
            type="email"
            placeholder="Correo electrónico"
            value={registerData.email}
            onChange={(e) => setRegisterData({ ...registerData, email: e.target.value })}
            required
            style={{ padding: '8px' }}
          />
          <input
            type="password"
            placeholder="Contraseña"
            value={registerData.password}
            onChange={(e) => setRegisterData({ ...registerData, password: e.target.value })}
            required
            style={{ padding: '8px' }}
          />
          <input
            type="text"
            placeholder="Teléfono"
            value={registerData.phoneNumber}
            onChange={(e) => setRegisterData({ ...registerData, phoneNumber: e.target.value })}
            required
            style={{ padding: '8px' }}
          />
          <input
            type="date"
            value={registerData.birthDate}
            onChange={(e) => setRegisterData({ ...registerData, birthDate: e.target.value })}
            required
            style={{ padding: '8px' }}
          />
          <button type="submit" disabled={loading} style={{ padding: '10px', background: '#28a745', color: '#fff', border: 'none', cursor: 'pointer' }}>
            {loading ? 'Registrando...' : 'Registrar Cuenta'}
          </button>
        </form>
      )}
    </div>
  );
}