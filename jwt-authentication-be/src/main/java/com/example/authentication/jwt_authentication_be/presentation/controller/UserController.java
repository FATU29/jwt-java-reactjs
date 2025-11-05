package com.example.authentication.jwt_authentication_be.presentation.controller;

import com.example.authentication.jwt_authentication_be.application.service.UserService;
import com.example.authentication.jwt_authentication_be.common.ApiResponse;
import com.example.authentication.jwt_authentication_be.presentation.dto.UserDto;
import com.example.authentication.jwt_authentication_be.utils.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.authentication.jwt_authentication_be.common.exception.UnauthorizedException;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;
    private final JwtUtil jwtUtil;

    public UserController(UserService userService, JwtUtil jwtUtil) {
        this.userService = userService;
        this.jwtUtil = jwtUtil;
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserDto>> getCurrentUser(HttpServletRequest request) {
        String token = extractTokenFromRequest(request);
        if (token == null) {
            throw new UnauthorizedException("Missing authorization token");
        }

        String email = jwtUtil.extractUsername(token);
        if (!jwtUtil.validateToken(token, email)) {
            throw new UnauthorizedException("Invalid or expired token");
        }

        UserDto user = userService.getUserByEmail(email);
        return ResponseEntity.ok(new ApiResponse<>(true, user, "User retrieved successfully"));
    }

    private String extractTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
