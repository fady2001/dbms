import * as React from 'react';
import Box from '@mui/material/Box';
import CssBaseline from '@mui/material/CssBaseline';
import CustomAppBar from './CustomAppBar';
import CustomDrawer from './CustomDrawer';
import CodeEditor from './CodeEditor'
import { DrawerHeader } from './styles';
import DataGrid from './DataGrid';

export default function MiniDrawer() {
  const [open, setOpen] = React.useState(false);

  const handleDrawerOpen = () => {
    setOpen(true);
  };

  const handleDrawerClose = () => {
    setOpen(false);
  };

  return (
    <Box sx={{ display: 'flex' }}>
      <CssBaseline />
      <CustomAppBar open={open} handleDrawerOpen={handleDrawerOpen} />
      <CustomDrawer open={open} handleDrawerClose={handleDrawerClose} />
      <Box component="main" width="100%">
        <DrawerHeader />
        <CodeEditor />
        <DataGrid />
      </Box>
    </Box>
  );
}
