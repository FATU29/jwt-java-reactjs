package com.example.authentication.jwt_authentication_be.presentation.controller;

import com.example.authentication.jwt_authentication_be.application.service.AuthenticationService;
import com.example.authentication.jwt_authentication_be.common.ApiResponse;
import com.example.authentication.jwt_authentication_be.presentation.dto.LoginRequest;
import com.example.authentication.jwt_authentication_be.presentation.dto.LoginResponse;
import com.example.authentication.jwt_authentication_be.presentation.dto.RefreshTokenRequest;
import com.example.authentication.jwt_authentication_be.presentation.dto.RefreshTokenResponse;
import com.example.authentication.jwt_authentication_be.presentation.dto.RegisterRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthenticationController {

    private final AuthenticationService authenticationService;

    public AuthenticationController(AuthenticationService authenticationService) {
        this.authenticationService = authenticationService;
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authenticationService.login(request);
        return ResponseEntity.ok(new ApiResponse<>(true, response, "Login successful"));
    }

    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<RefreshTokenResponse>> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        RefreshTokenResponse response = authenticationService.refreshToken(request);
        return ResponseEntity.ok(new ApiResponse<>(true, response, "Token refreshed successfully"));
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<LoginResponse>> register(@Valid @RequestBody RegisterRequest request) {
        LoginResponse response = authenticationService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new ApiResponse<>(true, response, "Registration successful"));
    }
}
