package com.example.authentication.jwt_authentication_be.common;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Data;

import java.time.OffsetDateTime;

@Data
@Builder
public class ErrorResponse {
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private OffsetDateTime timestamp;
    private int status;
    private String error; // Reason phrase
    private String code; // Stable application code
    private String message; // Human readable message
    private String path; // Request path
}
