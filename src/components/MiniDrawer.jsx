import * as React from 'react';
import Box from '@mui/material/Box';
import CssBaseline from '@mui/material/CssBaseline';
import Typography from '@mui/material/Typography';
import CustomAppBar from './CustomAppBar';
import CustomDrawer from './CustomDrawer';
import CodeEditor from './CodeEditor'
import { DrawerHeader } from './styles';

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
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end' }} />
        <Typography>
          Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor...
        </Typography>
        <Typography>
          Consequat mauris nunc congue nisi vitae suscipit. Fringilla est ullamcorper...
        </Typography>
      </Box>
    </Box>
  );
}
