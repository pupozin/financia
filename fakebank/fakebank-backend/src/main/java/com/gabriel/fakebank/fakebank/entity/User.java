package com.gabriel.fakebank.fakebank.entity;

import com.gabriel.fakebank.enums.Bank;
import jakarta.persistence.*;

@Entity
@Table(name = "\"user\"", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"cpf", "bank"})
})

public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    private String cpf;

    private String password;

    @Enumerated(EnumType.STRING)
    private Bank bank;

    // getters e setters


    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Bank getBank() {
        return bank;
    }

    public void setBank(Bank bank) {
        this.bank = bank;
    }
}