package com.gabriel.fakebank.fakebank.service;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.fakebank.dto.RegisterRequest;
import com.gabriel.fakebank.fakebank.entity.User;

import java.util.Optional;

public interface AuthService {
    Optional<User> login(String cpf, String password, Bank bank);
    void register(RegisterRequest req);
}
