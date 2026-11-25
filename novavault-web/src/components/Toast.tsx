import React, { useState, useEffect } from 'react';

interface ToastState {
  id: number;
  message: string;
}

let toastListener: ((toast: ToastState | null) => void) | null = null;

export function showToast(message: string) {
  if (toastListener) {
    toastListener({ id: Date.now(), message });
  }
}

export function ToastContainer() {
  const [toast, setToast] = useState<ToastState | null>(null);

  useEffect(() => {
    toastListener = setToast;
    return () => {
      toastListener = null;
    };
  }, []);

  useEffect(() => {
    if (!toast) return;
    const timer = setTimeout(() => {
      setToast(null);
    }, 2400);
    return () => clearTimeout(timer);
  }, [toast]);

  if (!toast) return null;

  return (
    <div
      role="status"
      aria-live="polite"
      style={{
        position: 'fixed',
        bottom: 24,
        right: 24,
        zIndex: 9999,
        background: 'var(--card)',
        border: '1px solid var(--card-border)',
        boxShadow: 'var(--shadow)',
        borderRadius: 14,
        padding: '12px 18px',
        color: 'var(--text)',
        fontSize: 13,
        fontWeight: 500,
        display: 'flex',
        alignItems: 'center',
        gap: 10,
        animation: 'slideUp 200ms ease-out',
      }}
    >
      <div
        style={{
          width: 8,
          height: 8,
          borderRadius: '50%',
          background: '#2fb67c',
          boxShadow: '0 0 8px rgba(47, 182, 124, 0.6)',
        }}
      />
      <span>{toast.message}</span>
    </div>
  );
}

export default ToastContainer;
