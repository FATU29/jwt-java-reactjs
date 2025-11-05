package com.example.authentication.jwt_authentication_be.domain.repository;

import com.example.authentication.jwt_authentication_be.domain.model.User;

public interface IUserRepository {
    boolean existsByEmail(String email);

    User findByEmail(String email);

    User save(User user);

    void deleteByEmail(String email);

    User findById(Long id);

    void deleteById(Long id);

    Iterable<User> findAll();

    long count();

}
