import * as React from 'react';
import Toolbar from '@mui/material/Toolbar';
import Button from '@mui/material/Button';
import ButtonGroup from '@mui/material/ButtonGroup';
import { useDialog } from '../contexts/DialogProvider';
import CustomDialog from './Dialog';

export default function DatabaseButtons() {
  const { openDialog } = useDialog();

  // Ref to the Play button
  const playButtonRef = React.useRef(null);

  // Handle the Ctrl + Enter key press
  React.useEffect(() => {
    const handleKeyDown = (event) => {
      // Check if both Ctrl and Enter are pressed
      if (event.key === 'Enter' && event.ctrlKey) {
        // Trigger the Play button click when Ctrl + Enter is pressed
        if (playButtonRef.current) {
          playButtonRef.current.click();
        }
      }
    };

    window.addEventListener("keydown", handleKeyDown);

    // Cleanup the event listener when the component is unmounted
    return () => {
      window.removeEventListener("keydown", handleKeyDown);
    };
  }, []);

  return (
    <Toolbar sx={{position:"sticky"}}>
      {/* First Group: Database Actions */}
      <ButtonGroup variant="outlined" color="primary" aria-label="database actions group">
        <Button onClick={() => openDialog('Hello Dialog', 'This is a sample dialog content.')}>Create DB</Button>
        <Button onClick={() => console.log('Drop Database')}>Drop DB</Button>
        <Button onClick={() => console.log('Rename Database')}>Rename DB</Button>
      </ButtonGroup>

      {/* Second Group: Table Actions */}
      <ButtonGroup variant="outlined" color="secondary" aria-label="table actions group" sx={{ ml: 2 }}>
        <Button onClick={() => console.log('Create Table')}>Create Table</Button>
        <Button onClick={() => console.log('Drop Table')}>Drop Table</Button>
        <Button onClick={() => console.log('Rename Table')}>Rename Table</Button>
        <Button onClick={() => console.log('Update Table')}>Update Table</Button>
      </ButtonGroup>

      {/* Third Group: Run Query */}
      <Button variant="contained" color="success" sx={{ ml: 2 }} ref={playButtonRef} onClick={() => console.log('Run Query')}>
        Run Query
      </Button>
      <CustomDialog />
    </Toolbar>
  );
}
