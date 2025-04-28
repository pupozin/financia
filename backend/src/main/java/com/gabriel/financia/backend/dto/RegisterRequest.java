package com.gabriel.financia.backend.dto;

import jakarta.validation.constraints.*;
import org.hibernate.validator.constraints.br.CPF;
import java.time.LocalDate;

public class RegisterRequest {
    @NotBlank
    private String name;

    @Email @NotBlank
    private String email;

    @NotBlank @Size(min = 6)
    private String password;

    @NotNull @Past
    private LocalDate birthDate;

    @NotBlank @CPF
    private String cpf;

    // getters & setters...

    public @NotBlank String getName() {
        return name;
    }

    public void setName(@NotBlank String name) {
        this.name = name;
    }

    public @Email @NotBlank String getEmail() {
        return email;
    }

    public void setEmail(@Email @NotBlank String email) {
        this.email = email;
    }

    public @NotBlank @Size(min = 6) String getPassword() {
        return password;
    }

    public void setPassword(@NotBlank @Size(min = 6) String password) {
        this.password = password;
    }

    public @NotNull @Past LocalDate getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(@NotNull @Past LocalDate birthDate) {
        this.birthDate = birthDate;
    }

    public @NotBlank @CPF String getCpf() {
        return cpf;
    }

    public void setCpf(@NotBlank @CPF String cpf) {
        this.cpf = cpf;
    }
}