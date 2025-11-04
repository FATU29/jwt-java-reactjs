import { ThemeProvider } from "@mui/material/styles";
import CssBaseline from "@mui/material/CssBaseline";
import theme from "./configs/theme";
import HomeContainer from "./containers/HomeContainer";

const App = () => {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <HomeContainer />
    </ThemeProvider>
  );
};

export default App;
