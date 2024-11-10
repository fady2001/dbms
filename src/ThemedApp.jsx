// ThemedApp.js
import * as React from 'react';
import App from './App';
import { ThemeProviderWrapper } from './contexts/ThemeToggle'; // Adjust path if necessary

export default function ThemedApp() {
  return (
    <ThemeProviderWrapper>
      <App />
    </ThemeProviderWrapper>
  );
}
