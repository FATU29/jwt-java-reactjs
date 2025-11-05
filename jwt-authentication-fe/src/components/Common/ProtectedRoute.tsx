import { Navigate } from 'react-router-dom';
import { getRefreshToken } from '../../services/axios';

interface ProtectedRouteProps {
  children: React.ReactNode;
}

const ProtectedRoute = ({ children }: ProtectedRouteProps) => {
  const refreshToken = getRefreshToken();

  if (!refreshToken) {
    return <Navigate to="/login" replace />;
  }

  return <>{children}</>;
};

export default ProtectedRoute;

