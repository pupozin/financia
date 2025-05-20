package com.gabriel.fakebank.fakebank.service;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.fakebank.dto.TransactionDto;
import com.gabriel.fakebank.fakebank.entity.Transaction;
import com.gabriel.fakebank.fakebank.repository.TransactionRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class TransactionService {

    private final TransactionRepository repository;

    public TransactionService(TransactionRepository repository) {
        this.repository = repository;
    }

    public void saveTransaction(TransactionDto dto) {
        Transaction t = new Transaction();
        t.setCpf(dto.getCpf());
        t.setBank(dto.getBank());
        t.setDescription(dto.getDescription());
        t.setCategory(dto.getCategory());
        t.setPayer(dto.getPayer());
        t.setAmount(dto.getAmount());
        t.setDate(LocalDate.now());
        t.setType(dto.getType());
        t.setMethod(dto.getMethod());
        t.setInstallments(dto.getInstallments());
        t.setInstallmentNumber(1); // por padrão, será 1 (vamos melhorar na parte de crédito depois)

        repository.save(t);
    }

    public List<Transaction> listByCpfAndBank(String cpf, String bank) {
        return repository.findByCpfAndBank(cpf, Bank.valueOf(bank));
    }
}
