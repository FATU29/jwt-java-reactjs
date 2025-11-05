import {
  Box,
  Button,
  TextField,
  Typography,
  Alert,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogContentText,
  DialogActions,
} from "@mui/material";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useRegister } from "../../hooks/useAuth";
import type { IRegisterRequest } from "../../types/auth.types";
import { useState } from "react";
import { useNavigate } from "react-router-dom";

const registerSchema = z
  .object({
    firstName: z.string().min(1, "First name is required"),
    lastName: z.string().min(1, "Last name is required"),
    email: z
      .string()
      .email("Invalid email address")
      .min(1, "Email is required"),
    password: z.string().min(6, "Password must be at least 6 characters"),
    confirmPassword: z.string().min(1, "Please confirm your password"),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Passwords don't match",
    path: ["confirmPassword"],
  });

type RegisterFormData = z.infer<typeof registerSchema>;

const RegisterForm = () => {
  const { mutate: register, isPending, error } = useRegister();
  const navigate = useNavigate();
  const [showSuccessDialog, setShowSuccessDialog] = useState(false);

  const {
    register: registerField,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm<RegisterFormData>({
    resolver: zodResolver(registerSchema),
  });

  const onSubmit = (data: RegisterFormData, e?: React.BaseSyntheticEvent) => {
    e?.preventDefault();
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { confirmPassword, ...registerData } = data;
    register(registerData as IRegisterRequest, {
      onSuccess: () => {
        setShowSuccessDialog(true);
      },
    });
  };

  const handleCloseDialog = () => {
    setShowSuccessDialog(false);
    reset();
    navigate("/login");
  };

  return (
    <Box
      component="form"
      onSubmit={handleSubmit(onSubmit)}
      sx={{
        display: "flex",
        flexDirection: "column",
        gap: 2,
        width: "100%",
        maxWidth: 400,
      }}
    >
      <Typography variant="h4" component="h1" gutterBottom textAlign="center">
        Register
      </Typography>

      {error && (
        <Alert severity="error">
          {error.message || "Registration failed. Please try again."}
        </Alert>
      )}

      <TextField
        {...registerField("firstName")}
        label="First Name"
        type="text"
        error={!!errors.firstName}
        helperText={errors.firstName?.message}
        fullWidth
        autoComplete="given-name"
      />

      <TextField
        {...registerField("lastName")}
        label="Last Name"
        type="text"
        error={!!errors.lastName}
        helperText={errors.lastName?.message}
        fullWidth
        autoComplete="family-name"
      />

      <TextField
        {...registerField("email")}
        label="Email"
        type="email"
        error={!!errors.email}
        helperText={errors.email?.message}
        fullWidth
        autoComplete="email"
      />

      <TextField
        {...registerField("password")}
        label="Password"
        type="password"
        error={!!errors.password}
        helperText={errors.password?.message}
        fullWidth
        autoComplete="new-password"
      />

      <TextField
        {...registerField("confirmPassword")}
        label="Confirm Password"
        type="password"
        error={!!errors.confirmPassword}
        helperText={errors.confirmPassword?.message}
        fullWidth
        autoComplete="new-password"
      />

      <Button
        type="submit"
        variant="contained"
        size="large"
        disabled={isPending}
        fullWidth
        sx={{ mt: 1 }}
      >
        {isPending ? "Creating Account..." : "Register"}
      </Button>

      <Dialog
        open={showSuccessDialog}
        onClose={handleCloseDialog}
        aria-labelledby="success-dialog-title"
        aria-describedby="success-dialog-description"
      >
        <DialogTitle id="success-dialog-title">Đăng ký thành công!</DialogTitle>
        <DialogContent>
          <DialogContentText id="success-dialog-description">
            Tài khoản của bạn đã được tạo thành công. Vui lòng đăng nhập để tiếp
            tục.
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog} variant="contained" autoFocus>
            Đăng nhập
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default RegisterForm;
