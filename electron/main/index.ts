import { app, BrowserWindow, shell, ipcMain } from 'electron'
import { createRequire } from 'node:module'
import { fileURLToPath } from 'node:url'
import path from 'node:path'
import os from 'node:os'
import { update } from './update'
import { exec } from 'child_process';


const require = createRequire(import.meta.url)
const __dirname = path.dirname(fileURLToPath(import.meta.url))
const script_path = path.join(path.resolve(__dirname, '../..'), 'scripts')
const connectDatabaseName = ""

// The built directory structure
//
// ├─┬ dist-electron
// │ ├─┬ main
// │ │ └── index.js    > Electron-Main
// │ └─┬ preload
// │   └── index.mjs   > Preload-Scripts
// ├─┬ dist
// │ └── index.html    > Electron-Renderer
//
process.env.APP_ROOT = path.join(__dirname, '../..')

export const MAIN_DIST = path.join(process.env.APP_ROOT, 'dist-electron')
export const RENDERER_DIST = path.join(process.env.APP_ROOT, 'dist')
export const VITE_DEV_SERVER_URL = process.env.VITE_DEV_SERVER_URL

process.env.VITE_PUBLIC = VITE_DEV_SERVER_URL
  ? path.join(process.env.APP_ROOT, 'public')
  : RENDERER_DIST

// Disable GPU Acceleration for Windows 7
if (os.release().startsWith('6.1')) app.disableHardwareAcceleration()

// Set application name for Windows 10+ notifications
if (process.platform === 'win32') app.setAppUserModelId(app.getName())

if (!app.requestSingleInstanceLock()) {
  app.quit()
  process.exit(0)
}

let win: BrowserWindow | null = null
const preload = path.join(__dirname, '../preload/index.mjs')
const indexHtml = path.join(RENDERER_DIST, 'index.html')

async function createWindow() {
  win = new BrowserWindow({
    title: 'Main window',
    icon: path.join(process.env.VITE_PUBLIC, 'favicon.ico'),
    webPreferences: {
      preload,
      // Warning: Enable nodeIntegration and disable contextIsolation is not secure in production
      // nodeIntegration: true,

      // Consider using contextBridge.exposeInMainWorld
      // Read more on https://www.electronjs.org/docs/latest/tutorial/context-isolation
      // contextIsolation: false,
    },
  })

  if (VITE_DEV_SERVER_URL) { // #298
    win.loadURL(VITE_DEV_SERVER_URL)
    // Open devTool if the app is not packaged
    win.webContents.openDevTools()
  } else {
    win.loadFile(indexHtml)
  }

  // Test actively push message to the Electron-Renderer
  win.webContents.on('did-finish-load', () => {
    win?.webContents.send('main-process-message', new Date().toLocaleString())
  })

  // Make all links open with the browser, not with the application
  win.webContents.setWindowOpenHandler(({ url }) => {
    if (url.startsWith('https:')) shell.openExternal(url)
    return { action: 'deny' }
  })

  // Auto update
  update(win)
}

app.whenReady().then(createWindow)

app.on('window-all-closed', () => {
  win = null
  if (process.platform !== 'darwin') app.quit()
})

app.on('second-instance', () => {
  if (win) {
    // Focus on the main window if the user tried to open another
    if (win.isMinimized()) win.restore()
    win.focus()
  }
})

app.on('activate', () => {
  const allWindows = BrowserWindow.getAllWindows()
  if (allWindows.length) {
    allWindows[0].focus()
  } else {
    createWindow()
  }
})

// New window example arg: new windows url
ipcMain.handle('open-win', (_, arg) => {
  const childWindow = new BrowserWindow({
    webPreferences: {
      preload,
      nodeIntegration: true,
      contextIsolation: false,
    },
  })

  if (VITE_DEV_SERVER_URL) {
    childWindow.loadURL(`${VITE_DEV_SERVER_URL}#${arg}`)
  } else {
    childWindow.loadFile(indexHtml, { hash: arg })
  }
})

ipcMain.on('get-databases', (event) => {
  // execute the bash script inside scripts folder
  console.log(`${script_path}`);
  // cd into the scripts folder and execute the dbms.sh script
  exec(`cd ${script_path}&&./GUIinterface.sh --listDatabases`, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
      return;
    }
    console.log(`stdout: ${stdout}`);
    // split the output by new line
    const dbs = stdout.split('\n');
    console.log("db",dbs)
    // remove the last empty string
    dbs.pop();
    // trim then split by tab
    const dbList = dbs.map(db => db.trim().split('\t'));
    console.log("dbList",dbList)
    // get array from second element of each array
    const dbNames = dbList.map(db => db[1]);
    let err = stderr.replace(/\x1b\[[0-9;]*m/g, '');
    // remove ANSI color codes
    event.sender.send('databases', { dbNames, err });
  });
})

// create a new ipcMain that will handle the get-tables event
// it takes the event and the database name as arguments
ipcMain.on('get-tables', (event, dbName) => {
  // execute the bash script inside scripts folder
  console.log(`${script_path}`);
  // cd into the scripts folder and execute the dbms.sh script
  console.log(`${dbName}`)
  exec(`cd ${script_path}/${dbName} && ${script_path}/GUIinterface.sh --listTables`, (error, stdout, stderr) => {     
    if (error) {
      console.error(`exec error: ${error}`);
      event.sender.send('tables', { tableNames: [], err: "Error: No permissions" });
      return;
    }
    console.log(`stdout: ${stdout}`);
    // split the output by new line
    const tables = stdout.split('\n');
    console.log("tables",tables)
    // remove the last empty string
    tables.pop();
    // trim then split by tab
    const tableList = tables.map(table => table.trim().split('\t'));
    console.log("tableList",tableList)
    const tableNames = tableList.map(table => table[1]);
    // get array from second element of each array
    let err = stderr.replace(/\x1b\[[0-9;]*m/g, '');
    event.sender.send('tables', { tableNames, err });
  });
})

ipcMain.on('query', (event, dbName, query) => {
  // execute the bash script inside scripts folder
  console.log(`${script_path}`);
  // cd into the scripts folder and execute the dbms.sh script
  exec(`cd ${script_path}/${dbName}&&./dbms.sh --sql "${query}"`, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
      return;
    }
    console.log(`stdout: ${stdout}`);
    // split the output by new line
    const result = stdout.split('\n');
    console.log("result",result)
  });
})



