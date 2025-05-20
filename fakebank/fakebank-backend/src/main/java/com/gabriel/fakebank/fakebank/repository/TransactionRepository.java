package com.gabriel.fakebank.fakebank.repository;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.fakebank.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    List<Transaction> findByCpfAndBank(String cpf, Bank bank);
}
