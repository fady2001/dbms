import * as React from 'react';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Radio from '@mui/material/Radio';
import StorageIcon from '@mui/icons-material/Storage';

const items1 = ['Inbox', 'Starred', 'Send email', 'Drafts'];

export default function DrawerListItems({ open }) {
  const [selectedValue, setSelectedValue] = React.useState('');

  const handleItemClick = (value) => {
    setSelectedValue(value);
  };

  return (
    <div>
      <List>
        {items1.map((text, index) => (
          <ListItem key={text} disablePadding sx={{ display: 'block' }}>
            <ListItemButton
              sx={{ minHeight: 48, px: 2.5, justifyContent: open ? 'initial' : 'center' }}
              onClick={() => handleItemClick(text)}
            >
              <ListItemIcon sx={{ minWidth: 0, mr: open ? 3 : 'auto', justifyContent: 'center' }}>
                <StorageIcon />
              </ListItemIcon>
              <ListItemText primary={text} sx={{ opacity: open ? 1 : 0 }} />
              <Radio
                checked={selectedValue === text}
                value={text}
                name="list-radio-button"
                inputProps={{ 'aria-label': text }}
              />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </div>
  );
}
