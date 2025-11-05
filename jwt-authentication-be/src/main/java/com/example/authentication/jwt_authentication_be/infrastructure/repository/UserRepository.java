package com.example.authentication.jwt_authentication_be.infrastructure.repository;

import com.example.authentication.jwt_authentication_be.domain.repository.IUserRepository;
import com.example.authentication.jwt_authentication_be.domain.model.User;
import com.example.authentication.jwt_authentication_be.infrastructure.entity.user.UserEntity;
import com.example.authentication.jwt_authentication_be.mapper.UserMapper;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public class UserRepository implements IUserRepository {

    private final UserJpaRepository jpaRepository;
    private final UserMapper mapper;

    public UserRepository(UserJpaRepository jpaRepository, UserMapper mapper) {
        this.jpaRepository = jpaRepository;
        this.mapper = mapper;
    }

    @Override
    public boolean existsByEmail(String email) {
        return jpaRepository.existsByEmail(email);
    }

    @Override
    public User findByEmail(String email) {
        return jpaRepository.findByEmail(email)
                .map(mapper::toDomain)
                .orElse(null);
    }

    @Override
    public User save(User user) {
        UserEntity entity = mapper.toEntity(user);
        UserEntity saved = jpaRepository.save(entity);
        return mapper.toDomain(saved);
    }

    @Override
    public void deleteByEmail(String email) {
        jpaRepository.deleteByEmail(email);
    }

    @Override
    public User findById(Long id) {
        return jpaRepository.findById(id)
                .map(mapper::toDomain)
                .orElse(null);
    }

    @Override
    public void deleteById(Long id) {
        jpaRepository.deleteById(id);
    }

    @Override
    public Iterable<User> findAll() {
        return jpaRepository.findAll().stream()
                .map(mapper::toDomain)
                .toList();
    }

    @Override
    public long count() {
        return jpaRepository.count();
    }
}


