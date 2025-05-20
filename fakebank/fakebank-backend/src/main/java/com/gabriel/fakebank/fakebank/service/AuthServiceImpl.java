package com.gabriel.fakebank.fakebank.service;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.fakebank.dto.RegisterRequest;
import com.gabriel.fakebank.fakebank.entity.User;
import com.gabriel.fakebank.fakebank.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;

    public AuthServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public Optional<User> login(String cpf, String password, Bank bank) {
        Optional<User> userOpt = userRepository.findByCpfAndBank(cpf, bank);
        if (userOpt.isPresent() && userOpt.get().getPassword().equals(password)) {
            return userOpt;
        }
        return Optional.empty();
    }

    public void register(RegisterRequest req) {
        boolean exists = userRepository.findByCpfAndBank(req.getCpf(), req.getBank()).isPresent();

        if (exists) {
            throw new RuntimeException("CPF already registered");
        }

        User user = new User();
        user.setName(req.getName());
        user.setCpf(req.getCpf());
        user.setPassword(req.getPassword());
        user.setBank(req.getBank());

        userRepository.save(user);
    }
}
