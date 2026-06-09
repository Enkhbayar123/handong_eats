import { useState } from 'react';
import Login from './components/Login';
import Portal from './components/Portal';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(() => {
    // Retain session on hot reload/refresh for premium official convenience
    return localStorage.getItem('handong_eats_auth') === 'true';
  });

  const handleLoginSuccess = () => {
    setIsAuthenticated(true);
    localStorage.setItem('handong_eats_auth', 'true');
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    localStorage.removeItem('handong_eats_auth');
  };

  return (
    <main className="app-container">
      {isAuthenticated ? (
        <Portal onLogout={handleLogout} />
      ) : (
        <Login onLoginSuccess={handleLoginSuccess} />
      )}
    </main>
  );
}

export default App;
