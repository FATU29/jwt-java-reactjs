import { Box, Container, Typography } from "@mui/material";

const HomeContainer = () => {
  return (
    <Container maxWidth="lg">
      <Box
        sx={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          minHeight: "100vh",
          gap: 2,
        }}
      >
        <Typography variant="h3" component="h1" gutterBottom>
          JWT Authentication
        </Typography>
        <Typography variant="body1" color="text.secondary">
          Welcome to the JWT Authentication Frontend
        </Typography>
      </Box>
    </Container>
  );
};

export default HomeContainer;
