import * as React from "react";
import Toolbar from "@mui/material/Toolbar";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import { AppBar } from "./styles";
import ModeSwitch from "./ModeSwitch";
import { Box } from "@mui/material";
import PlayCircleFilledIcon from '@mui/icons-material/PlayCircleFilled';

export default function CustomAppBar() {
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
        <ModeSwitch />
    </AppBar>
  );
}
