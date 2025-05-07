package com.gabriel.financia.backend.service;


import com.gabriel.financia.backend.dto.RegisterRequest;
import com.gabriel.financia.backend.entity.User;

import java.util.Optional;

public interface AuthService {
    void register(RegisterRequest req);
    Optional<User> login(String email, String rawPassword);
    User save(User user);
}