package com.gabriel.fakebank.fakebank.repository;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.fakebank.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByCpfAndBank(String cpf, Bank bank);
}