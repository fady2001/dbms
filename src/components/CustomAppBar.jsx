import * as React from "react";
import Toolbar from "@mui/material/Toolbar";
import IconButton from "@mui/material/IconButton";
import MenuIcon from "@mui/icons-material/Menu";
import Typography from "@mui/material/Typography";
import { AppBar } from "./styles";
import ModeSwitch from "./ModeSwitch";
import { Box } from "@mui/material";
import PlayCircleFilledIcon from '@mui/icons-material/PlayCircleFilled';

export default function CustomAppBar({ open, handleDrawerOpen }) {
  return (
    <AppBar
      position="fixed"
      open={open}
      sx={{
        display: "flex",
        flexDirection: "row",
        justifyContent: "space-between",
        alignItems: "center",
      }}
    >
      <Toolbar>
        <IconButton
          color="inherit"
          aria-label="open drawer"
          onClick={handleDrawerOpen}
          edge="start"
          sx={{ marginRight: 5, ...(open && { display: "none" }) }}
        >
          <MenuIcon />
        </IconButton>
        <Typography variant="h6" noWrap>
          Mini variant drawer
        </Typography>
      </Toolbar>
      <Box sx={{ display: "flex", flexDirection: "row", alignItems: "center" }}>
        <IconButton
          color="inherit"
          aria-label="open drawer"
          onClick={handleDrawerOpen}
          edge="start"
          sx={{ marginRight: 5, ...(open && { display: "none" }) }}
        >
          <PlayCircleFilledIcon color="success" fontSize="large" />
        </IconButton>
        <ModeSwitch />
      </Box>
    </AppBar>
  );
}
