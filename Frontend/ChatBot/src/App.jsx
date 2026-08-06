import { useEffect, useState } from "react";
import { useAuthStore } from "./store/useAuthStore.js";
import { AuthView } from "./components/Auth/AuthView.jsx";
import { ChatView } from "./components/Chat/ChatView.jsx";
import { CartView } from "./components/Cart/CartView.jsx";
import { PaymentMethodsView } from "./components/Payment/PaymentMethodsView.jsx";

export default function App() {
  const [currentView, setCurrentView] = useState('chat');
  const { user, isAuthenticated, checkSession, isLoading, logout } = useAuthStore();

  useEffect(() => {
    checkSession();
  }, [checkSession]);

  if (isLoading) return <p style={{ textAlign: 'center', marginTop: '50px' }}>Verificando sesión...</p>;

  if (!isAuthenticated) {
    return <AuthView />;
  }

  return (
    <div>
      <header style={{ padding: '10px 20px', background: '#222', color: '#fff', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <span>Bienvenido, <strong>{user?.fullName}</strong> ({user?.role})</span>
        <button onClick={logout} style={{ background: '#dc3545', color: '#fff', border: 'none', padding: '6px 12px', cursor: 'pointer', borderRadius: '4px' }}>
          Cerrar Sesión
        </button>
      </header>
      
      {currentView === 'payment' ? (
        <PaymentMethodsView onBack={() => setCurrentView('chat')} />
      ) : (
        <main>
          <ChatView />
          <CartView onManagePaymentMethods={() => setCurrentView('payment')} />
        </main>
      )}
    </div>
  );
}
