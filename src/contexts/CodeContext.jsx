// CodeContext.js
import React, { createContext, useContext, useState } from 'react';

// Create the context
const CodeContext = createContext();

// Create a provider component
export const CodeProvider = ({ children }) => {
  // Code state with a default value
  const [code, setCode] = useState('-- Write your SQL code here');

  // Handler to update the code
  const updateCode = (newCode) => {
    setCode(newCode);
  };

  return (
    <CodeContext.Provider value={{ code, updateCode }}>
      {children}
    </CodeContext.Provider>
  );
};

// Custom hook to access code context
export const useCode = () => {
  return useContext(CodeContext);
};
