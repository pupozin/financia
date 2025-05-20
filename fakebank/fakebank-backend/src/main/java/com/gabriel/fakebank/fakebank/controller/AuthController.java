package com.gabriel.fakebank.fakebank.controller;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.fakebank.dto.RegisterRequest;
import com.gabriel.fakebank.fakebank.entity.User;
import com.gabriel.fakebank.fakebank.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@Valid @RequestBody RegisterRequest req) {
        try {
            authService.register(req);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(Map.of("message", "User registered!"));
        } catch (RuntimeException ex) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("error", ex.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam("bank") Bank bank
    ) {
        if (authHeader == null || !authHeader.startsWith("Basic ")) {
            return ResponseEntity.badRequest().body("Authorization header missing or malformed");
        }

        String b64 = authHeader.substring("Basic ".length());
        String decoded = new String(Base64.getDecoder().decode(b64), StandardCharsets.UTF_8);
        String[] parts = decoded.split(":", 2);
        if (parts.length != 2) {
            return ResponseEntity.badRequest().body("Invalid Basic auth format");
        }

        String cpf = parts[0];
        String rawPwd = parts[1];

        Optional<User> userOpt = authService.login(cpf, rawPwd, bank);
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials or bank");
        }

        User u = userOpt.get();

        Map<String, Object> body = Map.of(
                "id", u.getId(),
                "name", u.getName(),
                "cpf", u.getCpf(),
                "bank", u.getBank()
        );
        return ResponseEntity.ok(body);
    }
}
