import axiosInstance from '../services/axios';
import type { IApiResponse, ILoginRequest, ILoginResponse, IRefreshTokenRequest, IRefreshTokenResponse, IRegisterRequest } from '../types/auth.types';
import { API_ENDPOINTS } from '../utils/constants/api';
import { extractErrorMessage } from '../utils/errorHandler';
import { AxiosError } from 'axios';

export const login = async (
  credentials: ILoginRequest
): Promise<ILoginResponse> => {
  try {
    const response = await axiosInstance.post<IApiResponse<ILoginResponse>>(
      API_ENDPOINTS.AUTH.LOGIN,
      credentials
    );
    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.message || 'Login failed');
    }
    return response.data.data;
  } catch (error) {
    if (error instanceof AxiosError) {
      throw new Error(extractErrorMessage(error));
    }
    throw error;
  }
};

export const register = async (
  userData: IRegisterRequest
): Promise<ILoginResponse> => {
  try {
    const response = await axiosInstance.post<IApiResponse<ILoginResponse>>(
      API_ENDPOINTS.AUTH.REGISTER,
      userData
    );
    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.message || 'Registration failed');
    }
    return response.data.data;
  } catch (error) {
    if (error instanceof AxiosError) {
      throw new Error(extractErrorMessage(error));
    }
    throw error;
  }
};

export const refreshToken = async (
  refreshToken: string
): Promise<IRefreshTokenResponse> => {
  try {
    const response = await axiosInstance.post<IApiResponse<IRefreshTokenResponse>>(
      API_ENDPOINTS.AUTH.REFRESH,
      { refreshToken } as IRefreshTokenRequest
    );
    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.message || 'Token refresh failed');
    }
    return response.data.data;
  } catch (error) {
    if (error instanceof AxiosError) {
      throw new Error(extractErrorMessage(error));
    }
    throw error;
  }
};

