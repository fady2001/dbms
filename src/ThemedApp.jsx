// ThemedApp.js
import * as React from 'react';
import App from './App';
import { ThemeProviderWrapper } from './contexts/ThemeToggle'; 
import { CodeProvider } from './contexts/CodeContext';
import { SnackbarProvider } from './contexts/SnackbarContext';

export default function ThemedApp() {
  return (
  <SnackbarProvider>
    <CodeProvider>
      <ThemeProviderWrapper>
        <App />
      </ThemeProviderWrapper>
    </CodeProvider>
  </SnackbarProvider>
  );
}
