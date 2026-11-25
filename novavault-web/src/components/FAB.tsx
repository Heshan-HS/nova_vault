import React from 'react';
import { Plus } from 'lucide-react';
import { tokens } from '../tokens';

interface FABProps {
  onClick: () => void;
}

export function FAB({ onClick }: FABProps) {
  return (
    <button
      type="button"
      aria-label="Add new item"
      onClick={onClick}
      style={{
        position: 'fixed',
        bottom: 'calc(80px + env(safe-area-inset-bottom, 0px))',
        right: 20,
        zIndex: 99,
        width: 58,
        height: 58,
        borderRadius: tokens.radii.fab,
        background: tokens.brandGradient,
        boxShadow: '0 12px 30px rgba(11,60,143,.6)',
        color: '#ffffff',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        border: 'none',
        cursor: 'pointer',
        transition: 'transform 150ms ease-out',
      }}
      onMouseDown={(e) => {
        e.currentTarget.style.transform = 'scale(0.98)';
      }}
      onMouseUp={(e) => {
        e.currentTarget.style.transform = 'scale(1)';
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.transform = 'scale(1)';
      }}
    >
      <Plus size={26} strokeWidth={2} />
    </button>
  );
}

export default FAB;
