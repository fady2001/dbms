import React from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
} from '@mui/material';
import { useDialog } from '../contexts/DialogProvider';

const CustomDialog = () => {
  const { open, title, inputValue, closeDialog, setInputValue, onSubmit } = useDialog();

  const handleSubmit = () => {
    if (onSubmit) onSubmit(inputValue);
    closeDialog();
  };

  return (
    <Dialog open={open} onClose={closeDialog}>
      <DialogTitle>{title}</DialogTitle>
      <DialogContent>
        <TextField
          label="Database Name"
          fullWidth
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          margin="normal"
        />
      </DialogContent>
      <DialogActions>
        <Button onClick={closeDialog} color="error">
          Cancel
        </Button>
        <Button onClick={handleSubmit} color="success">
          Submit
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default CustomDialog;
