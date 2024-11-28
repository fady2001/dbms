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
import { useSnackbar } from '../contexts/SnackbarContext';

const items1 = ['DB1', 'DB2', 'DB3', 'DB4'];
const tables = ['Table1', 'Table2', 'Table3', 'Table4'];
const columns = {'Table1':['id','name'], 'Table2':['id','name'], 'Table3':['id','name'], 'Table4':['id','name']};

export default function DrawerListItems() {
  const { openSnackbar } = useSnackbar();
  const ipcRenderer = window.ipcRenderer;

  const [databases, setDatabases] = React.useState([]);
  const [tables, setTables] = React.useState([]);
  const [columns, setColumns] = React.useState({});
  const { mode } = useThemeMode();
  const [openIndex, setOpenIndex] = React.useState(null);
  const [openTableIndices, setOpenTableIndices] = React.useState([]);

  const handleCollapseClick = (index) => {
    setOpenIndex((prevIndex) => (prevIndex === index ? null : index));
  };

  const handleTableCollapseClick = (index) => {
    setOpenTableIndices((prevIndices) =>
      prevIndices.includes(index)
        ? prevIndices.filter((i) => i !== index)
        : [...prevIndices, index]
    );
  };

  React.useEffect(() => {
    if (openIndex !== null) {
      ipcRenderer.send("get-tables", databases[openIndex]);

      ipcRenderer.on("tables", (event, args) => {
        console.log(args);
        if (args.err.match(/Error/)) {
          openSnackbar(args.err, "error");
          setTables([]);
        }
        else {
          openSnackbar("Tables fetched successfully", "success");
          setTables(args.tableNames);
        }
      });
    }
    return () => {
      ipcRenderer.removeAllListeners("tables");
    };
  }, [openIndex, databases]);

  React.useEffect(() => {
    if (openTableIndices.length > 0) {
      const lastIndex = openTableIndices[openTableIndices.length - 1];
      ipcRenderer.send("get-columns", databases[openIndex] ,tables[lastIndex]);

      ipcRenderer.on("columns", (event, args) => {
        console.log(args);
        if (args.err.match(/Error/)) {
          openSnackbar("there is a problem with metadata", "error");
          setColumns({});
        }
        else {
          openSnackbar("Columns fetched successfully", "success");
          setColumns((prevColumns) => ({
            ...prevColumns,
            [tables[lastIndex]]: args.columnNames
          }));
        }
      });
    }
    return () => {
      ipcRenderer.removeAllListeners("columns");
    };
  }, [openTableIndices, tables]);

  React.useMemo(() => {
    ipcRenderer.send("get-databases");

    ipcRenderer.on("databases", (event, args) => {
      console.log(args);
      if (args.err.match(/Error/)) {
        openSnackbar(args.err, "error");
        return;
      }
      else {
        setDatabases(args.dbNames);
        openSnackbar(args.err, "success");
      }
    });
  }, []);

  return (
    <div>
      <List>
        {databases.map((text, index) => (
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
                {tables.map((table, tableIndex) => (
                  <div key={table}>
                    <ListItemButton sx={{ pl: 4 }} onClick={() => handleTableCollapseClick(tableIndex)}>
                      <ListItemIcon>
                        <TableChartIcon />
                      </ListItemIcon>
                      <ListItemText primary={table} />
                      {openTableIndices.includes(tableIndex) ? <ExpandLess /> : <ExpandMore />}
                    </ListItemButton>
                    <Collapse in={openTableIndices.includes(tableIndex)} timeout="auto" unmountOnExit>
                      <List component="div" disablePadding>
                        {(columns[table] || []).map((column) => (
                          <ListItemButton key={column} sx={{ pl: 8 }}>
                            <ListItemText primary={column} />
                          </ListItemButton>
                        ))}
                      </List>
                    </Collapse>
                  </div>
                ))}
              </List>
            </Collapse>
          </div>
        ))}
      </List>
    </div>
  );
}