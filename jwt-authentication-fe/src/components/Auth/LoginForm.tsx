import { Box, Button, TextField, Typography, Alert } from '@mui/material';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useLogin } from '../../hooks/useAuth';
import type { ILoginRequest } from '../../types/auth.types';

const loginSchema = z.object({
  email: z.string().email('Invalid email address').min(1, 'Email is required'),
  password: z.string().min(1, 'Password is required'),
});

type LoginFormData = z.infer<typeof loginSchema>;

const LoginForm = () => {
  const loginMutation = useLogin();

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: ILoginRequest, e?: React.BaseSyntheticEvent) => {
    e?.preventDefault();
    loginMutation.mutate(data);
  };

  return (
    <Box
      component="form"
      onSubmit={handleSubmit(onSubmit)}
      sx={{
        display: 'flex',
        flexDirection: 'column',
        gap: 2,
        width: '100%',
        maxWidth: 400,
      }}
    >
      <Typography variant="h4" component="h1" gutterBottom>
        Login
      </Typography>

      {loginMutation.isError && (
        <Alert severity="error">
          {loginMutation.error instanceof Error
            ? loginMutation.error.message
            : 'Login failed. Please check your credentials.'}
        </Alert>
      )}

      <TextField
        label="Email"
        type="email"
        fullWidth
        {...register('email')}
        error={!!errors.email}
        helperText={errors.email?.message}
        disabled={loginMutation.isPending}
      />

      <TextField
        label="Password"
        type="password"
        fullWidth
        {...register('password')}
        error={!!errors.password}
        helperText={errors.password?.message}
        disabled={loginMutation.isPending}
      />

      <Button
        type="submit"
        variant="contained"
        fullWidth
        disabled={loginMutation.isPending}
        sx={{ mt: 2 }}
      >
        {loginMutation.isPending ? 'Logging in...' : 'Login'}
      </Button>
    </Box>
  );
};

export default LoginForm;

