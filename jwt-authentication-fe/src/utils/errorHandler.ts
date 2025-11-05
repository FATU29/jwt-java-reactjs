import { AxiosError } from 'axios';
import type { IApiResponse, IErrorResponse } from '../types/auth.types';

export const extractErrorMessage = (
  error: AxiosError<IErrorResponse | IApiResponse<unknown>>
): string => {
  if (error.response?.data) {
    const data = error.response.data;
    // Check if it's ErrorResponse format (has status, code, message)
    if ('status' in data && 'code' in data && 'message' in data) {
      return (data as IErrorResponse).message;
    }
    // Check if it's ApiResponse format (has success, message)
    if ('success' in data && 'message' in data) {
      return (data as IApiResponse<unknown>).message || 'Request failed';
    }
  }
  return error.message || 'Request failed';
};

