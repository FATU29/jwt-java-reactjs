package com.example.authentication.jwt_authentication_be.common;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ApiResponse<T> {
    boolean success;
    T data;
    String message;
}
