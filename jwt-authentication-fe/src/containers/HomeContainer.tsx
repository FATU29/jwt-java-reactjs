import { Box, Container, Typography, Button, Stack } from "@mui/material";
import { useNavigate } from "react-router-dom";
import LoginIcon from "@mui/icons-material/Login";
import PersonAddIcon from "@mui/icons-material/PersonAdd";

const HomeContainer = () => {
  const navigate = useNavigate();

  const handleNavigateToLogin = () => {
    navigate("/login");
  };

  const handleNavigateToRegister = () => {
    // Use login route with register mode to avoid extra route wiring
    navigate("/login?register=1");
  };

  return (
    <Container maxWidth="md">
      <Box
        sx={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          minHeight: "100vh",
          textAlign: "center",
        }}
      >
        <Typography
          variant="h2"
          component="h1"
          gutterBottom
          sx={{
            fontWeight: 700,
            background: "linear-gradient(45deg, #1976d2 30%, #42a5f5 90%)",
            backgroundClip: "text",
            WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent",
            mb: 2,
          }}
        >
          JWT Authentication System
        </Typography>
        <Typography
          variant="h5"
          color="text.secondary"
          sx={{ mb: 1 }}
        >
          Welcome to Secure Authentication
        </Typography>
        <Typography
          variant="body1"
          color="text.secondary"
          sx={{ mb: 4, maxWidth: 600 }}
        >
          A full-stack JWT authentication system with React frontend and Spring Boot backend.
          Login to your account or create a new one to get started.
        </Typography>
        <Stack direction="row" spacing={2}>
          <Button
            variant="contained"
            size="large"
            startIcon={<LoginIcon />}
            onClick={handleNavigateToLogin}
            sx={{
              minWidth: 200,
              py: 1.5,
              px: 4,
              fontSize: "1.1rem",
              fontWeight: 600,
              borderRadius: 2,
              boxShadow: 3,
              "&:hover": {
                boxShadow: 6,
                transform: "translateY(-2px)",
                transition: "all 0.3s ease-in-out",
              },
            }}
          >
            Login
          </Button>
          <Button
            variant="outlined"
            size="large"
            startIcon={<PersonAddIcon />}
            onClick={handleNavigateToRegister}
            sx={{
              minWidth: 200,
              py: 1.5,
              px: 4,
              fontSize: "1.1rem",
              fontWeight: 600,
              borderRadius: 2,
              "&:hover": {
                transform: "translateY(-2px)",
                transition: "all 0.3s ease-in-out",
              },
            }}
          >
            Register
          </Button>
        </Stack>
      </Box>
    </Container>
  );
};

export default HomeContainer;
