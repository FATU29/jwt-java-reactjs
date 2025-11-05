package com.example.authentication.jwt_authentication_be.config;

import com.example.authentication.jwt_authentication_be.domain.model.User;
import com.example.authentication.jwt_authentication_be.domain.repository.IUserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private final IUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public DataInitializer(IUserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        if (userRepository.count() == 0) {
            User adminUser = User.builder()
                    .firstName("John")
                    .lastName("Doe")
                    .email("admin@example.com")
                    .password(passwordEncoder.encode("password123"))
                    .build();
            userRepository.save(adminUser);
            System.out.println("Default user created: admin@example.com / password123");
        }
    }
}

