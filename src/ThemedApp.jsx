// ThemedApp.js
import * as React from 'react';
import App from './App';
import { ThemeProviderWrapper } from './contexts/ThemeToggle'; 
import { CodeProvider } from './contexts/CodeContext';

export default function ThemedApp() {
  return (
    <CodeProvider>
      <ThemeProviderWrapper>
        <App />
      </ThemeProviderWrapper>
    </CodeProvider>
  );
}
