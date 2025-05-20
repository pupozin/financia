package com.gabriel.fakebank.fakebank.controller;

import com.gabriel.fakebank.fakebank.dto.TransactionDto;
import com.gabriel.fakebank.fakebank.service.TransactionService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/transaction")
@CrossOrigin(origins = "*")
public class TransactionController {

    private final TransactionService service;

    public TransactionController(TransactionService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<?> registerTransaction(@RequestBody TransactionDto dto) {
        service.saveTransaction(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body("Transação registrada com sucesso.");
    }

    @GetMapping("/{cpf}/{bank}")
    public ResponseEntity<?> listTransactions(@PathVariable String cpf, @PathVariable String bank) {
        return ResponseEntity.ok(service.listByCpfAndBank(cpf, bank));
    }
}
