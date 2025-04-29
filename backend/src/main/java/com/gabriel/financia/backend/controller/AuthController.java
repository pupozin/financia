package com.gabriel.financia.backend.controller;

import com.gabriel.financia.backend.dto.RegisterRequest;
import com.gabriel.financia.backend.entity.User;
import com.gabriel.financia.backend.service.AuthService;
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
        authService.register(req);
        return ResponseEntity.ok("User registered");
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        // 1) header check
        if (authHeader == null || !authHeader.startsWith("Basic ")) {
            return ResponseEntity
                    .badRequest()
                    .body("Authorization header missing or malformed");
        }

        // 2) decode Base64 -> "email:password"
        String b64 = authHeader.substring(6);
        String decoded = new String(Base64.getDecoder().decode(b64), StandardCharsets.UTF_8);
        String[] parts = decoded.split(":", 2);
        if (parts.length != 2) {
            return ResponseEntity
                    .badRequest()
                    .body("Invalid Basic auth format");
        }

        String email = parts[0];
        String rawPwd = parts[1];

        // 3) delegate to AuthService.login(...)
        Optional<User> userOpt = authService.login(email, rawPwd);
        if (userOpt.isEmpty()) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body("Invalid credentials");
        }

        User u = userOpt.get();
        // 4) minimal JSON response
        Map<String, Object> body = Map.of(
                "id",   u.getId(),
                "name", u.getName(),
                "email", u.getEmail()
        );
        return ResponseEntity.ok(body);
    }
}