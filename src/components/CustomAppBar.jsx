import * as React from "react";
import Toolbar from "@mui/material/Toolbar";
import IconButton from "@mui/material/IconButton";
import MenuIcon from "@mui/icons-material/Menu";
import Typography from "@mui/material/Typography";
import { AppBar } from "./styles";
import ModeSwitch from "./ModeSwitch";
import { Box } from "@mui/material";
import PlayCircleFilledIcon from '@mui/icons-material/PlayCircleFilled';

export default function CustomAppBar() {
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
    <AppBar
      position="fixed"
      sx={{
        display: "flex",
        flexDirection: "row",
        justifyContent: "space-between",
        alignItems: "center",
      }}
    >
      <Toolbar>
        <Typography variant="h6" noWrap>
          Mini variant drawer
        </Typography>
      </Toolbar>
      <Box sx={{ display: "flex", flexDirection: "row", alignItems: "center" }}>
        <IconButton
          color="inherit"
          aria-label="play button"
          edge="start"
          sx={{ marginRight: 5 }}
          ref={playButtonRef}
        >
          <PlayCircleFilledIcon color="success" fontSize="large" />
        </IconButton>
        <ModeSwitch />
      </Box>
    </AppBar>
  );
}
