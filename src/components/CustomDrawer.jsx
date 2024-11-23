import * as React from "react";
import {useTheme } from "@mui/material/styles";
import Divider from "@mui/material/Divider";
import DrawerListItems from "./DrawerListItems";
import { Drawer,DrawerHeader } from "./styles";

export default function CustomDrawer() {
  const theme = useTheme();
  return (
    <Drawer variant="permanent">
      <DrawerHeader>
      </DrawerHeader>
      <Divider />
      <DrawerListItems />
      <Divider />
    </Drawer>
  );
}
