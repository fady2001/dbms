import React, { createContext, useState, useContext } from 'react';

const DialogContext = createContext();

export const DialogProvider = ({ children }) => {
  const [dialogState, setDialogState] = useState({
    open: false,
    title: '',
    content: '',
    inputValue: '',
    onSubmit: () => {}, // Submit handler
  });

  const openDialog = (title, onSubmit) => {
    setDialogState({ open: true, title, inputValue: '', onSubmit });
  };

  const closeDialog = () => {
    setDialogState({ ...dialogState, open: false });
  };

  const setInputValue = (value) => {
    setDialogState({ ...dialogState, inputValue: value });
  };

  return (
    <DialogContext.Provider
      value={{ ...dialogState, openDialog, closeDialog, setInputValue }}
    >
      {children}
    </DialogContext.Provider>
  );
};

export const useDialog = () => useContext(DialogContext);
