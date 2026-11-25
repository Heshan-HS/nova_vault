/**
 * NovaVault Crypto Library
 * AES-256-GCM client-side encryption — zero-knowledge architecture
 * Master password never leaves the device; only encrypted ciphertext syncs.
 */

const PBKDF2_ITERATIONS = 310_000;
const SALT_LENGTH = 16;
const IV_LENGTH = 12;
const KEY_LENGTH = 256;

/** Derive a CryptoKey from master password using PBKDF2 */
export async function deriveKey(masterPassword: string, salt: Uint8Array): Promise<CryptoKey> {
  const enc = new TextEncoder();
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    enc.encode(masterPassword),
    'PBKDF2',
    false,
    ['deriveKey'],
  );
  return crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt: salt.buffer as ArrayBuffer,
      iterations: PBKDF2_ITERATIONS,
      hash: 'SHA-256',
    },
    keyMaterial,
    { name: 'AES-GCM', length: KEY_LENGTH },
    false,
    ['encrypt', 'decrypt'],
  );
}

/** Encrypt plaintext with AES-256-GCM. Returns base64 string: salt|iv|ciphertext */
export async function encrypt(plaintext: string, masterPassword: string): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(SALT_LENGTH));
  const iv   = crypto.getRandomValues(new Uint8Array(IV_LENGTH));
  const key  = await deriveKey(masterPassword, salt);

  const enc = new TextEncoder();
  const ciphertext = await crypto.subtle.encrypt(
    { name: 'AES-GCM', iv },
    key,
    enc.encode(plaintext),
  );

  const combined = new Uint8Array(SALT_LENGTH + IV_LENGTH + ciphertext.byteLength);
  combined.set(salt, 0);
  combined.set(iv, SALT_LENGTH);
  combined.set(new Uint8Array(ciphertext), SALT_LENGTH + IV_LENGTH);

  return btoa(String.fromCharCode(...combined));
}

/** Decrypt base64 ciphertext blob with master password */
export async function decrypt(ciphertextB64: string, masterPassword: string): Promise<string> {
  const combined = Uint8Array.from(atob(ciphertextB64), c => c.charCodeAt(0));
  const salt      = combined.slice(0, SALT_LENGTH);
  const iv        = combined.slice(SALT_LENGTH, SALT_LENGTH + IV_LENGTH);
  const ciphertext = combined.slice(SALT_LENGTH + IV_LENGTH);

  const key = await deriveKey(masterPassword, salt);
  const plaintext = await crypto.subtle.decrypt({ name: 'AES-GCM', iv }, key, ciphertext);

  return new TextDecoder().decode(plaintext);
}

/** Hash master password for local verification (never store plaintext) */
export async function hashMasterPassword(password: string, salt: string): Promise<string> {
  const enc = new TextEncoder();
  const data = enc.encode(password + salt);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  return btoa(String.fromCharCode(...new Uint8Array(hashBuffer)));
}

/** Generate a random secure password */
export function generatePassword(length = 20, options = {
  uppercase: true, lowercase: true, numbers: true, symbols: true,
}): string {
  let chars = '';
  if (options.uppercase) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  if (options.lowercase) chars += 'abcdefghijklmnopqrstuvwxyz';
  if (options.numbers)   chars += '0123456789';
  if (options.symbols)   chars += '!@#$%^&*()_+-=[]{}|;:,.<>?';

  const array = new Uint8Array(length);
  crypto.getRandomValues(array);
  return Array.from(array, byte => chars[byte % chars.length]).join('');
}

/** Check password strength (0-4 score) */
export function checkPasswordStrength(password: string): {
  score: number; label: string; color: string;
} {
  let score = 0;
  if (password.length >= 8)  score++;
  if (password.length >= 16) score++;
  if (/[A-Z]/.test(password) && /[a-z]/.test(password)) score++;
  if (/[0-9]/.test(password)) score++;
  if (/[^A-Za-z0-9]/.test(password)) score++;

  const levels = [
    { label: 'Very Weak', color: '#dc2626' },
    { label: 'Weak',      color: '#ea580c' },
    { label: 'Fair',      color: '#d97706' },
    { label: 'Strong',    color: '#059669' },
    { label: 'Very Strong', color: '#0b3c8f' },
  ];
  return { score, ...levels[Math.min(score, 4)] };
}
