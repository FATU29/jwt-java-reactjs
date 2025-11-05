import axiosInstance from '../services/axios';
import type { IApiResponse, IUser } from '../types/auth.types';
import { API_ENDPOINTS } from '../utils/constants/api';
import { extractErrorMessage } from '../utils/errorHandler';
import { AxiosError } from 'axios';

export const getCurrentUser = async (): Promise<IUser> => {
  try {
    const response = await axiosInstance.get<IApiResponse<IUser>>(
      API_ENDPOINTS.USERS.ME
    );
    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.message || 'Failed to fetch user');
    }
    return response.data.data;
  } catch (error) {
    if (error instanceof AxiosError) {
      throw new Error(extractErrorMessage(error));
    }
    throw error;
  }
};

