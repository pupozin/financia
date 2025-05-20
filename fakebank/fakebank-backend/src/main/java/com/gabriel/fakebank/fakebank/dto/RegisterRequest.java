package com.gabriel.fakebank.fakebank.dto;

import com.gabriel.fakebank.enums.Bank;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.hibernate.validator.constraints.br.CPF;

@Valid
public class RegisterRequest {

    @NotBlank
    private String name;

    @NotBlank
    private String password;

    @NotBlank
    @CPF
    private String cpf;

    @NotNull
    private Bank bank;

    // getters e setters...

    public @NotBlank String getName() {
        return name;
    }

    public void setName(@NotBlank String name) {
        this.name = name;
    }

    public @NotBlank String getPassword() {
        return password;
    }

    public void setPassword(@NotBlank String password) {
        this.password = password;
    }

    public @NotBlank @CPF String getCpf() {
        return cpf;
    }

    public void setCpf(@NotBlank @CPF String cpf) {
        this.cpf = cpf;
    }

    public @NotNull Bank getBank() {
        return bank;
    }

    public void setBank(@NotNull Bank bank) {
        this.bank = bank;
    }
}