import React from 'react'
import ReactDOM from 'react-dom/client'
import ThemedApp from './ThemedApp'

ReactDOM.createRoot(document.getElementById('root')).render(
    <ThemedApp />
)

postMessage({ payload: 'removeLoading' }, '*')
