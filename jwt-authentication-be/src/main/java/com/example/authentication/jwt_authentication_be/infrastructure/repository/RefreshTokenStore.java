package com.example.authentication.jwt_authentication_be.infrastructure.repository;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

@Component
public class RefreshTokenStore {

    private static final String PREFIX = "rt:";
    private final StringRedisTemplate redisTemplate;

    public RefreshTokenStore(StringRedisTemplate redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    public void store(String refreshToken, long ttlMillis) {
        String key = PREFIX + refreshToken;
        redisTemplate.opsForValue().set(key, "1", ttlMillis, TimeUnit.MILLISECONDS);
    }

    public boolean exists(String refreshToken) {
        String key = PREFIX + refreshToken;
        Boolean exists = redisTemplate.hasKey(key);
        return exists != null && exists;
    }

    public void delete(String refreshToken) {
        String key = PREFIX + refreshToken;
        redisTemplate.delete(key);
    }
}
