import * as React from 'react';
import Box from '@mui/material/Box';
import CssBaseline from '@mui/material/CssBaseline';
import CustomAppBar from './CustomAppBar';
import CustomDrawer from './CustomDrawer';
import CodeEditor from './CodeEditor'
import { DrawerHeader } from './styles';
import DataGrid from './DataGrid';

export default function MiniDrawer() {
  return (
    <Box sx={{ display: 'flex' }}>
      <CssBaseline />
      <CustomAppBar />
      <CustomDrawer />
      <Box component="main" width="100%">
        <DrawerHeader />
        <CodeEditor />
        <DataGrid />
      </Box>
    </Box>
  );
}
