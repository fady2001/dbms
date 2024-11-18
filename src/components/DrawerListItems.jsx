import * as React from 'react';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Collapse from '@mui/material/Collapse';
import ExpandLess from '@mui/icons-material/ExpandLess';
import ExpandMore from '@mui/icons-material/ExpandMore';
import TableChartIcon from '@mui/icons-material/TableChart';
import darkDB from '../assets/darkDB.png';
import lightDB from '../assets/lightDB.png';
import { useThemeMode } from '../contexts/ThemeToggle';

const items1 = ['DB1', 'DB2', 'DB3', 'DB4'];
const tables = ['Table1', 'Table2', 'Table3', 'Table4'];

export default function DrawerListItems() {
  const { mode } = useThemeMode();
  const [openIndex, setOpenIndex] = React.useState(null);

  const handleCollapseClick = (index) => {
    setOpenIndex((prevIndex) => (prevIndex === index ? null : index));
  };

  return (
    <div>
      <List>
        {items1.map((text, index) => (
          <div key={text}>
            <ListItem disablePadding sx={{ display: 'block' }}>
              <ListItemButton
                sx={{ minHeight: 48, px: 2.5, justifyContent: 'initial' }}
                onClick={() => handleCollapseClick(index)}
              >
                <ListItemIcon sx={{ minWidth: 0, mr: 3, justifyContent: 'center' }}>
                  {mode === 'light' ? <img src={darkDB} width="25px" alt="DB" /> : <img src={lightDB} width="25px" alt="DB" />}
                </ListItemIcon>
                <ListItemText primary={text} sx={{ opacity: 1 }} />
                {openIndex === index ? <ExpandLess /> : <ExpandMore />}
              </ListItemButton>
            </ListItem>
            <Collapse in={openIndex === index} timeout="auto" unmountOnExit>
              <List component="div" disablePadding>
                {tables.map((table) => (
                  <ListItemButton key={table} sx={{ pl: 4 }}>
                    <ListItemIcon>
                      <TableChartIcon />
                    </ListItemIcon>
                    <ListItemText primary={table} />
                  </ListItemButton>
                ))}
              </List>
            </Collapse>
          </div>
        ))}
      </List>
    </div>
  );
}
