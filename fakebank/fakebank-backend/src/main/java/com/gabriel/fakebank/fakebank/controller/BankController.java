package com.gabriel.fakebank.fakebank.controller;

import com.gabriel.fakebank.enums.Bank;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

// Fakebank - BankController.java
@RestController
@RequestMapping("/api/banks")
@CrossOrigin(origins = "*")
public class BankController {

    @GetMapping
    public ResponseEntity<?> getBanks() {
        return ResponseEntity.ok(Bank.values());
    }
}
