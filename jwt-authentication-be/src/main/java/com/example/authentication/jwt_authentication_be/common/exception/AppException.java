package com.example.authentication.jwt_authentication_be.common.exception;

import org.springframework.http.HttpStatus;

/**
 * Base application exception carrying an HTTP status and an error code.
 * Prefer throwing specific subclasses from the service layer.
 */
public class AppException extends RuntimeException {
    private final HttpStatus status;
    private final String code;

    public AppException(HttpStatus status, String code, String message) {
        super(message);
        this.status = status;
        this.code = code;
    }

    public AppException(HttpStatus status, String code, String message, Throwable cause) {
        super(message, cause);
        this.status = status;
        this.code = code;
    }

    public HttpStatus getStatus() {
        return status;
    }

    public String getCode() {
        return code;
    }
}
