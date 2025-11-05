import {
  Button as MuiButton,
  type ButtonProps as MuiButtonProps,
} from "@mui/material";

type Props = MuiButtonProps & {
  children: React.ReactNode;
};

const Button = ({ children, ...props }: Props) => {
  return <MuiButton {...props}>{children}</MuiButton>;
};

export default Button;
