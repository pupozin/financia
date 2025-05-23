package com.gabriel.fakebank.fakebank.entity;

import com.gabriel.fakebank.enums.Bank;
import jakarta.persistence.*;

@Entity
@Table(name = "\"authorization\"")
public class Authorization {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String cpf;

    @Enumerated(EnumType.STRING)
    private Bank bank;

    private boolean authorized; // true se o usuário deu permissão

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public Bank getBank() {
        return bank;
    }

    public void setBank(Bank bank) {
        this.bank = bank;
    }

    public boolean isAuthorized() {
        return authorized;
    }

    public void setAuthorized(boolean authorized) {
        this.authorized = authorized;
    }
}
