package com.gabriel.financia.backend.service;

import com.gabriel.financia.backend.dto.RegisterRequest;
import com.gabriel.financia.backend.entity.User;
import com.gabriel.financia.backend.respository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AuthServiceImpl implements AuthService {
    private final UserRepository repo;
    private final PasswordEncoder encoder;

    public AuthServiceImpl(UserRepository repo, PasswordEncoder encoder) {
        this.repo = repo; this.encoder = encoder;
    }

    @Override
    public void register(RegisterRequest req) {
        if (repo.findByEmail(req.getEmail()).isPresent())
            throw new RuntimeException("Email already in use");
        if (repo.existsByCpf(req.getCpf()))
            throw new RuntimeException("CPF already registered");

        User u = new User(
                req.getName(),
                req.getEmail(),
                encoder.encode(req.getPassword()),
                req.getCpf()
        );
        repo.save(u);
    }

    @Override
    public Optional<User> login(String email, String rawPassword) {
        return repo.findByEmail(email)
                .filter(u -> encoder.matches(rawPassword, u.getPassword()));
    }

    @Override
    public User save(User user) {
        return repo.save(user);
    }
}