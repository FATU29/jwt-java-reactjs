import { Box, Container, Link, Typography } from "@mui/material";
import { Link as RouterLink, useLocation } from "react-router-dom";
import LoginForm from "../components/Auth/LoginForm";
import RegisterForm from "../components/Auth/RegisterForm";

const LoginContainer = () => {
  const location = useLocation();
  const params = new URLSearchParams(location.search);
  const isRegisterMode = params.get("register") === "1";

  return (
    <Container maxWidth="sm">
      <Box
        sx={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          minHeight: "100vh",
          py: 4,
        }}
      >
        {isRegisterMode ? (
          <>
            <RegisterForm />
            <Box sx={{ mt: 3, textAlign: "center" }}>
              <Typography variant="body2" color="text.secondary">
                Already have an account?{" "}
                <Link component={RouterLink} to="/login" underline="hover">
                  Login here
                </Link>
              </Typography>
            </Box>
          </>
        ) : (
          <>
            <LoginForm />
            <Box sx={{ mt: 3, textAlign: "center" }}>
              <Typography variant="body2" color="text.secondary">
                Don't have an account?{" "}
                <Link
                  component={RouterLink}
                  to="/login?register=1"
                  underline="hover"
                >
                  Register here
                </Link>
              </Typography>
            </Box>
          </>
        )}
      </Box>
    </Container>
  );
};

export default LoginContainer;
