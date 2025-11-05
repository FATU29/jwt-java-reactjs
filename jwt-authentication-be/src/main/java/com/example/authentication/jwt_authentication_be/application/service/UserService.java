package com.example.authentication.jwt_authentication_be.application.service;

import com.example.authentication.jwt_authentication_be.domain.model.User;
import com.example.authentication.jwt_authentication_be.domain.repository.IUserRepository;
import com.example.authentication.jwt_authentication_be.presentation.dto.UserDto;
import org.springframework.stereotype.Service;
import com.example.authentication.jwt_authentication_be.common.exception.NotFoundException;

@Service
public class UserService {

    private final IUserRepository userRepository;

    public UserService(IUserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserDto getUserByEmail(String email) {
        User user = userRepository.findByEmail(email);
        if (user == null) {
            throw new NotFoundException("User not found");
        }

        return UserDto.builder()
                .id(user.getId())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .email(user.getEmail())
                .build();
    }
}
