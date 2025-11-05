package com.example.authentication.jwt_authentication_be.application.service;

import com.example.authentication.jwt_authentication_be.domain.model.User;
import com.example.authentication.jwt_authentication_be.domain.repository.IUserRepository;
import com.example.authentication.jwt_authentication_be.presentation.dto.LoginRequest;
import com.example.authentication.jwt_authentication_be.presentation.dto.LoginResponse;
import com.example.authentication.jwt_authentication_be.presentation.dto.RefreshTokenRequest;
import com.example.authentication.jwt_authentication_be.presentation.dto.RefreshTokenResponse;
import com.example.authentication.jwt_authentication_be.presentation.dto.RegisterRequest;
import com.example.authentication.jwt_authentication_be.presentation.dto.UserDto;
import com.example.authentication.jwt_authentication_be.utils.JwtUtil;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import com.example.authentication.jwt_authentication_be.infrastructure.repository.RefreshTokenStore;
import com.example.authentication.jwt_authentication_be.common.exception.ConflictException;
import com.example.authentication.jwt_authentication_be.common.exception.UnauthorizedException;
import com.example.authentication.jwt_authentication_be.common.exception.BadRequestException;

@Service
public class AuthenticationService {

    private final IUserRepository userRepository;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;
    private final RefreshTokenStore refreshTokenStore;

    public AuthenticationService(IUserRepository userRepository, JwtUtil jwtUtil, PasswordEncoder passwordEncoder,
            RefreshTokenStore refreshTokenStore) {
        this.userRepository = userRepository;
        this.jwtUtil = jwtUtil;
        this.passwordEncoder = passwordEncoder;
        this.refreshTokenStore = refreshTokenStore;
    }

    public LoginResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail());
        if (user == null || !passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new UnauthorizedException("Invalid email or password");
        }

        String accessToken = jwtUtil.generateAccessToken(user.getEmail());
        String refreshToken = jwtUtil.generateRefreshToken(user.getEmail());
        // Store refresh token in Redis with TTL for rotation and revocation
        refreshTokenStore.store(refreshToken, jwtUtil.getRefreshTokenExpiration());

        UserDto userDto = UserDto.builder()
                .id(user.getId())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .email(user.getEmail())
                .build();

        return LoginResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .user(userDto)
                .build();
    }

    public RefreshTokenResponse refreshToken(RefreshTokenRequest request) {
        String refreshToken = request.getRefreshToken();

        if (refreshToken == null || refreshToken.isBlank()) {
            throw new BadRequestException("Refresh token is required");
        }

        if (!jwtUtil.isRefreshToken(refreshToken)) {
            throw new UnauthorizedException("Invalid refresh token");
        }

        String username = jwtUtil.extractUsername(refreshToken);
        if (!jwtUtil.validateToken(refreshToken, username)) {
            throw new UnauthorizedException("Refresh token expired or invalid");
        }

        // Check token existence (rotation - reject reused tokens)
        if (!refreshTokenStore.exists(refreshToken)) {
            throw new UnauthorizedException("Refresh token invalid or already used");
        }

        // Rotate refresh token: invalidate old, issue new, and store
        refreshTokenStore.delete(refreshToken);

        String newAccessToken = jwtUtil.generateAccessToken(username);
        String newRefreshToken = jwtUtil.generateRefreshToken(username);
        refreshTokenStore.store(newRefreshToken, jwtUtil.getRefreshTokenExpiration());

        return RefreshTokenResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .build();
    }

    public LoginResponse register(RegisterRequest request) {
        // Check if email already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ConflictException("Email already exists");
        }

        // Create new user
        User newUser = User.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .build();

        User savedUser = userRepository.save(newUser);

        // Generate tokens
        String accessToken = jwtUtil.generateAccessToken(savedUser.getEmail());
        String refreshToken = jwtUtil.generateRefreshToken(savedUser.getEmail());
        refreshTokenStore.store(refreshToken, jwtUtil.getRefreshTokenExpiration());

        UserDto userDto = UserDto.builder()
                .id(savedUser.getId())
                .firstName(savedUser.getFirstName())
                .lastName(savedUser.getLastName())
                .email(savedUser.getEmail())
                .build();

        return LoginResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .user(userDto)
                .build();
    }
}
