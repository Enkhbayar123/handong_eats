import React, { useState } from 'react';
import { Lock, User, LogIn, AlertCircle, ChefHat } from 'lucide-react';

export default function Login({ onLoginSuccess }) {
  const [studentId, setStudentId] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isShaking, setIsShaking] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = (e) => {
    e.preventDefault();
    setError('');

    if (!studentId || !password) {
      triggerError('Please fill in all fields.');
      return;
    }

    setIsLoading(true);

    // Add brief artificial loading for a premium responsive feel
    setTimeout(() => {
      if (studentId === '22300446' && password === '1234') {
        setIsLoading(false);
        onLoginSuccess();
      } else {
        setIsLoading(false);
        triggerError('Invalid School ID or Password. Please try again.');
      }
    }, 800);
  };

  const triggerError = (msg) => {
    setError(msg);
    setIsShaking(true);
    // Reset shaking animation after duration
    setTimeout(() => setIsShaking(false), 400);
  };

  return (
    <div className="login-container fade-in">
      <div className={`glass-panel login-card ${isShaking ? 'shake-anim' : ''}`}>
        <div className="login-header">
          <div className="logo-badge">
            <ChefHat size={32} className="logo-icon text-red" />
          </div>
          <h1 className="login-title">
            Handong <span className="text-red">Eats</span>
          </h1>
          <p className="login-subtitle">Restaurant Portal Manager</p>
        </div>

        <form onSubmit={handleSubmit} className="login-form">
          {error && (
            <div className="error-banner">
              <AlertCircle size={18} className="error-icon" />
              <span>{error}</span>
            </div>
          )}

          <div className="input-group">
            <label htmlFor="studentId">School ID</label>
            <div className="input-wrapper">
              <User size={18} className="field-icon" />
              <input
                id="studentId"
                type="text"
                placeholder="Enter 22300446"
                value={studentId}
                onChange={(e) => setStudentId(e.target.value)}
                disabled={isLoading}
              />
            </div>
          </div>

          <div className="input-group">
            <label htmlFor="password">Password</label>
            <div className="input-wrapper">
              <Lock size={18} className="field-icon" />
              <input
                id="password"
                type="password"
                placeholder="Enter 1234"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                disabled={isLoading}
              />
            </div>
          </div>

          <button
            type="submit"
            className="btn-primary login-btn"
            disabled={isLoading}
          >
            {isLoading ? (
              <span className="loader-dots">Verifying...</span>
            ) : (
              <>
                <span>Sign In</span>
                <LogIn size={18} />
              </>
            )}
          </button>
        </form>

        <div className="login-footer">
          <p>Authorized access only. Log in with your school official account.</p>
        </div>
      </div>
    </div>
  );
}
