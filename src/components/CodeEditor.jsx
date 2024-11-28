import React, { useState } from 'react';
import { Controlled as CodeMirror } from 'react-codemirror2';
import 'codemirror/lib/codemirror.css'; // Import core styles
import 'codemirror/theme/duotone-dark.css';  // Theme (optional)
import 'codemirror/theme/duotone-light.css'
import 'codemirror/mode/sql/sql';  // Import SQL mode
import { useThemeMode } from '../contexts/ThemeToggle'; // Adjust path as necessary
import { useCode } from '../contexts/CodeContext'; // Adjust path as necessary


export default function CodeEditor() {
  const { mode } = useThemeMode();
  const { code, updateCode } = useCode(); // Destructure code and updateCode from context

  const handleCodeChange = (editor, data, value) => {
    updateCode(value);
  };

  return (
    <div style={{ border: '1px solid #ddd', borderRadius: '4px', overflow: 'hidden', height:"40%" }}>
      <CodeMirror
        value={code} // Set value of the editor
        options={{
          mode: 'sql',      // Set language mode to SQL
          theme: mode === 'light' ? 'duotone-light' : 'duotone-dark', // Set theme
          lineNumbers: true, // Enable line numbers
          tabSize: 2,         // Set tab size for indentation
          autofocus:true,
        }}
        onBeforeChange={handleCodeChange} // Handle changes in code
      />
    </div>
  );
}
