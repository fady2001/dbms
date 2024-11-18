import React, { createContext, useState, useContext } from 'react';

const DialogContext = createContext();

export const DialogProvider = ({ children }) => {
  const [dialogState, setDialogState] = useState({
    open: false,
    title: '',
    content: '',
  });

  const openDialog = (title, content) => {
    setDialogState({ open: true, title, content });
  };

  const closeDialog = () => {
    setDialogState({ ...dialogState, open: false });
  };

  return (
    <DialogContext.Provider value={{ ...dialogState, openDialog, closeDialog }}>
      {children}
    </DialogContext.Provider>
  );
};

export const useDialog = () => useContext(DialogContext);
