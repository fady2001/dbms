import React, { useState } from 'react';
import { Controlled as CodeMirror } from 'react-codemirror2';
import 'codemirror/lib/codemirror.css'; // Import core styles
import 'codemirror/theme/dracula.css';  // Theme (optional)
import 'codemirror/mode/sql/sql';  // Import SQL mode

export default function CodeEditor() {
  const [code, setCode] = useState('-- Write your SQL code here');

  const handleCodeChange = (editor, data, value) => {
    setCode(value);
  };

  return (
    <div style={{ border: '1px solid #ddd', borderRadius: '4px', overflow: 'hidden' }}>
      <CodeMirror
        value={code} // Set value of the editor
        options={{
          mode: 'sql',      // Set language mode to SQL
          theme: 'dracula', // Set theme
          lineNumbers: true, // Enable line numbers
          tabSize: 2,         // Set tab size for indentation
          autofocus:true,
        }}
        onBeforeChange={handleCodeChange} // Handle changes in code
      />
    </div>
  );
}
