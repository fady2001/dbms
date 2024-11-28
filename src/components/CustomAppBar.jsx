import * as React from "react";
import Toolbar from "@mui/material/Toolbar";
import Typography from "@mui/material/Typography";
import { AppBar } from "./styles";
import ModeSwitch from "./ModeSwitch";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import { useCode } from "../contexts/CodeContext";


export default function CustomAppBar() {
  const { code } = useCode();
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
      <Button variant="contained" color="success" sx={{ ml: 2 }} onClick={() => console.log(code)}>
        Run Query
      </Button>
        <ModeSwitch />
      </Box>
    </AppBar>
  );
}
