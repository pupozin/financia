package com.gabriel.fakebank.fakebank.controller;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.fakebank.entity.Authorization;
import com.gabriel.fakebank.fakebank.repository.AuthorizationRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/authorization")
@CrossOrigin(origins = "*")
public class AuthorizationController {

    private final AuthorizationRepository repository;

    public AuthorizationController(AuthorizationRepository repository) {
        this.repository = repository;
    }

    @PostMapping("/grant")
    public ResponseEntity<?> grantAccess(@RequestParam String cpf, @RequestParam Bank bank) {
        Authorization auth = repository.findByCpfAndBank(cpf, bank)
                .orElse(new Authorization());

        auth.setCpf(cpf);
        auth.setBank(bank);
        auth.setAuthorized(true);
        repository.save(auth);

        return ResponseEntity.ok("Access granted.");
    }

    @GetMapping("/authorized-banks/{cpf}")
    public ResponseEntity<?> getAuthorizedBanks(@PathVariable String cpf) {
        List<Bank> banks = repository.findAllByCpfAndAuthorizedTrue(cpf)
                .stream()
                .map(Authorization::getBank)
                .toList();

        return ResponseEntity.ok(Map.of("cpf", cpf, "banks", banks));
    }
}
