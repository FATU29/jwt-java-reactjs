import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { login, register } from "../api/auth";
import { getCurrentUser } from "../api/user";
import type { ILoginRequest, IRegisterRequest } from "../types/auth.types";
import {
  clearTokens,
  getRefreshToken,
  setAccessToken,
  setRefreshToken,
} from "../services/axios";

export const useLogin = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (credentials: ILoginRequest) => {
      const response = await login(credentials);
      setAccessToken(response.accessToken);
      setRefreshToken(response.refreshToken);
      return response;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["user"] });
      // Force navigation to ensure tokens are available
      window.location.href = "/dashboard";
    },
  });
};

export const useRegister = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (userData: IRegisterRequest) => {
      const response = await register(userData);
      return response;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["user"] });
      // Return success - let component handle dialog and navigation
      return true;
    },
  });
};

export const useLogout = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async () => {
      clearTokens();
    },
    onSuccess: () => {
      queryClient.clear();
      navigate("/login");
    },
  });
};

export const useCurrentUser = () => {
  const hasRefreshToken = !!getRefreshToken();

  return useQuery({
    queryKey: ["user"],
    queryFn: getCurrentUser,
    retry: false,
    enabled: hasRefreshToken,
  });
};
