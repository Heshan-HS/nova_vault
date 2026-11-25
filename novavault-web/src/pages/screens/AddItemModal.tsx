import React, { useState } from 'react';
import { X, Lock, CreditCard, FileText, User, Wand2, Star } from 'lucide-react';
import { PrimaryButton } from '../../components/PrimaryButton';
import { showToast } from '../../components/Toast';
import { tokens } from '../../tokens';
import type { VaultListItem } from '../desktop/ListPane';

interface AddItemModalProps {
  onClose: () => void;
  onSave: (item: VaultListItem) => void;
}

export function AddItemModal({ onClose, onSave }: AddItemModalProps) {
  const [category, setCategory] = useState<'login' | 'card' | 'note' | 'identity'>('login');
  const [name, setName] = useState('');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [url, setUrl] = useState('');
  const [folder, setFolder] = useState('Work');
  const [favourite, setFavourite] = useState(false);
  const [notes, setNotes] = useState('');

  const generateQuickPassword = () => {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnopqrstuvwxyz23456789!@#$%^&*()_+';
    const arr = new Uint8Array(18);
    crypto.getRandomValues(arr);
    const generated = Array.from(arr, (b) => chars[b % chars.length]).join('');
    setPassword(generated);
    showToast('Secure password generated');
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) {
      showToast('Please enter an item name');
      return;
    }

    const newItem: VaultListItem = {
      id: Date.now().toString(),
      name: name.trim(),
      category,
      username: username.trim(),
      password: password || '••••••••••••',
      url: url.trim(),
      tags: [folder],
      favourite,
      folder,
      strength: password ? 88 : 70,
      hasTotp: false,
      updatedAt: 'today',
      createdAt: 'Today',
    };

    onSave(newItem);
    showToast('New item added to vault');
    onClose();
  };

  const categories = [
    { key: 'login' as const, label: 'Login', icon: <Lock size={15} strokeWidth={1.8} /> },
    { key: 'card' as const, label: 'Card', icon: <CreditCard size={15} strokeWidth={1.8} /> },
    { key: 'note' as const, label: 'Note', icon: <FileText size={15} strokeWidth={1.8} /> },
    { key: 'identity' as const, label: 'Identity', icon: <User size={15} strokeWidth={1.8} /> },
  ];

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 9999,
        background: 'rgba(5, 16, 38, 0.75)',
        backdropFilter: 'blur(8px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 20,
        boxSizing: 'border-box',
      }}
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div
        style={{
          width: '100%',
          maxWidth: 480,
          background: 'var(--card)',
          border: '1px solid var(--card-border)',
          borderRadius: tokens.radii.card,
          boxShadow: 'var(--shadow)',
          overflow: 'hidden',
          display: 'flex',
          flexDirection: 'column',
        }}
      >
        {/* Header */}
        <div
          style={{
            padding: '18px 22px',
            borderBottom: '1px solid var(--card-border)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <h2 style={{ fontSize: 16, fontWeight: 700, color: 'var(--text)', margin: 0 }}>
            New Vault Item
          </h2>
          <button
            type="button"
            aria-label="Close"
            onClick={onClose}
            style={{
              background: 'transparent',
              border: 'none',
              color: 'var(--muted)',
              cursor: 'pointer',
              display: 'flex',
              padding: 4,
            }}
          >
            <X size={20} />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSave} style={{ padding: 22, display: 'flex', flexDirection: 'column', gap: 14 }}>
          {/* Category Tabs */}
          <div style={{ display: 'flex', gap: 6, background: 'var(--input-bg)', padding: 4, borderRadius: 12, border: '1px solid var(--input-border)' }}>
            {categories.map((cat) => (
              <button
                key={cat.key}
                type="button"
                onClick={() => setCategory(cat.key)}
                style={{
                  flex: 1,
                  padding: '7px 0',
                  borderRadius: 8,
                  fontSize: 12,
                  fontWeight: category === cat.key ? 600 : 500,
                  background: category === cat.key ? tokens.brandGradient : 'transparent',
                  color: category === cat.key ? '#ffffff' : 'var(--muted)',
                  border: 'none',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: 5,
                  cursor: 'pointer',
                }}
              >
                {cat.icon}
                <span>{cat.label}</span>
              </button>
            ))}
          </div>

          {/* Name & Favourite */}
          <div style={{ display: 'flex', gap: 10 }}>
            <div style={{ flex: 1 }}>
              <label style={{ display: 'block', fontSize: 11, fontWeight: 600, color: 'var(--muted)', marginBottom: 4, textTransform: 'uppercase' }}>
                Item Name *
              </label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="e.g. GitHub, AWS, Chase"
                required
                autoFocus
                style={{
                  width: '100%',
                  height: 40,
                  borderRadius: 10,
                  background: 'var(--input-bg)',
                  border: '1px solid var(--input-border)',
                  color: 'var(--text)',
                  fontSize: 13,
                  padding: '0 12px',
                  outline: 'none',
                  boxSizing: 'border-box',
                }}
              />
            </div>

            <div>
              <label style={{ display: 'block', fontSize: 11, fontWeight: 600, color: 'var(--muted)', marginBottom: 4, textTransform: 'uppercase' }}>
                Favorite
              </label>
              <button
                type="button"
                onClick={() => setFavourite(!favourite)}
                style={{
                  width: 40,
                  height: 40,
                  borderRadius: 10,
                  background: favourite ? 'var(--selected-bg)' : 'var(--input-bg)',
                  border: '1px solid var(--input-border)',
                  color: favourite ? '#f5c451' : 'var(--muted)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
              >
                <Star size={18} fill={favourite ? '#f5c451' : 'none'} strokeWidth={1.8} />
              </button>
            </div>
          </div>

          {/* Username / Email */}
          <div>
            <label style={{ display: 'block', fontSize: 11, fontWeight: 600, color: 'var(--muted)', marginBottom: 4, textTransform: 'uppercase' }}>
              Username or Email
            </label>
            <input
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder="e.g. dev@example.com"
              style={{
                width: '100%',
                height: 40,
                borderRadius: 10,
                background: 'var(--input-bg)',
                border: '1px solid var(--input-border)',
                color: 'var(--text)',
                fontSize: 13,
                padding: '0 12px',
                outline: 'none',
                boxSizing: 'border-box',
              }}
            />
          </div>

          {/* Password with inline generator */}
          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 4 }}>
              <label style={{ fontSize: 11, fontWeight: 600, color: 'var(--muted)', textTransform: 'uppercase' }}>
                Password
              </label>
              <button
                type="button"
                onClick={generateQuickPassword}
                style={{
                  background: 'transparent',
                  border: 'none',
                  color: 'var(--accent)',
                  fontSize: 11,
                  fontWeight: 600,
                  display: 'flex',
                  alignItems: 'center',
                  gap: 4,
                  cursor: 'pointer',
                }}
              >
                <Wand2 size={12} />
                <span>Generate Strong</span>
              </button>
            </div>
            <input
              type="text"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Enter or generate password"
              style={{
                width: '100%',
                height: 40,
                borderRadius: 10,
                background: 'var(--input-bg)',
                border: '1px solid var(--input-border)',
                color: 'var(--text)',
                fontSize: 13,
                fontFamily: 'JetBrains Mono, monospace',
                padding: '0 12px',
                outline: 'none',
                boxSizing: 'border-box',
              }}
            />
          </div>

          {/* Website URL */}
          <div>
            <label style={{ display: 'block', fontSize: 11, fontWeight: 600, color: 'var(--muted)', marginBottom: 4, textTransform: 'uppercase' }}>
              Website URL
            </label>
            <input
              type="text"
              value={url}
              onChange={(e) => setUrl(e.target.value)}
              placeholder="e.g. github.com"
              style={{
                width: '100%',
                height: 40,
                borderRadius: 10,
                background: 'var(--input-bg)',
                border: '1px solid var(--input-border)',
                color: 'var(--text)',
                fontSize: 13,
                padding: '0 12px',
                outline: 'none',
                boxSizing: 'border-box',
              }}
            />
          </div>

          {/* Folder Select */}
          <div>
            <label style={{ display: 'block', fontSize: 11, fontWeight: 600, color: 'var(--muted)', marginBottom: 4, textTransform: 'uppercase' }}>
              Folder
            </label>
            <select
              value={folder}
              onChange={(e) => setFolder(e.target.value)}
              style={{
                width: '100%',
                height: 40,
                borderRadius: 10,
                background: 'var(--input-bg)',
                border: '1px solid var(--input-border)',
                color: 'var(--text)',
                fontSize: 13,
                padding: '0 12px',
                outline: 'none',
                boxSizing: 'border-box',
              }}
            >
              <option value="Work">Work</option>
              <option value="Personal">Personal</option>
              <option value="Servers">Servers</option>
            </select>
          </div>

          {/* Action Buttons */}
          <div style={{ display: 'flex', gap: 10, marginTop: 10 }}>
            <button
              type="button"
              onClick={onClose}
              style={{
                flex: 1,
                height: 42,
                borderRadius: 10,
                background: 'transparent',
                border: '1px solid var(--card-border)',
                color: 'var(--muted)',
                fontSize: 13,
                fontWeight: 600,
                cursor: 'pointer',
              }}
            >
              Cancel
            </button>
            <PrimaryButton style={{ flex: 1, height: 42 }} onClick={() => handleSave({ preventDefault: () => {} } as any)}>
              Save Item
            </PrimaryButton>
          </div>
        </form>
      </div>
    </div>
  );
}

export default AddItemModal;
