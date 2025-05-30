package com.gabriel.fakebank.fakebank.controller;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.fakebank.entity.Authorization;
import com.gabriel.fakebank.fakebank.repository.AuthorizationRepository;
import jakarta.persistence.Column;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/authorization")

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
        auth.setAuthorized(false); // ⚠️ Aguardando aceite manual
        repository.save(auth);

        return ResponseEntity.ok("Access request saved. Awaiting approval.");
    }

    @GetMapping("/pending/{cpf}/{bank}")
    public ResponseEntity<?> getPendingRequestsByCpfAndBank(@PathVariable String cpf, @PathVariable Bank bank) {
        List<Authorization> pending = repository.findAllByCpfAndBankAndAuthorizedFalse(cpf, bank);
        return ResponseEntity.ok(pending);
    }

    @GetMapping("/authorized-banks/{cpf}")
    public ResponseEntity<?> getAuthorizedBanks(@PathVariable String cpf) {
        List<Bank> banks = repository.findAllByCpfAndAuthorizedTrue(cpf)
                .stream()
                .map(Authorization::getBank)
                .toList();

        return ResponseEntity.ok(Map.of("cpf", cpf, "banks", banks));
    }

    @PatchMapping("/approve/{id}")
    public ResponseEntity<?> approveAccess(@PathVariable Long id) {
        Optional<Authorization> authOpt = repository.findById(id);
        if (authOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Authorization auth = authOpt.get();
        auth.setAuthorized(true);
        repository.save(auth);
        return ResponseEntity.ok("Authorization approved.");
    }


}
