import * as React from 'react';
import {MaterialUISwitch} from './styles';
import { useThemeMode } from '../contexts/ThemeToggle'; // Adjust path as necessary

export default function ModeSwitch() {
  const { toggleTheme } = useThemeMode();

  return (
    <MaterialUISwitch sx={{ m: 1 }} onClick={()=>toggleTheme()}/>
  );
}
