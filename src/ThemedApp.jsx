import * as React from 'react';
import { ThemeProvider, createTheme, useColorScheme } from '@mui/material/styles';
import App from './App';

const theme = createTheme({
  colorSchemes: {
    dark: true,
  },
});

export default function ThemedApp() {
const { mode, setMode } = useColorScheme();
  if (!mode) {
    return null;
  }
  return (
    <ThemeProvider theme={theme}>
      <App mode={setMode}/>
    </ThemeProvider>
  );
}
