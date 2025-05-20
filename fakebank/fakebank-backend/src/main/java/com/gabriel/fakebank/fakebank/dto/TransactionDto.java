package com.gabriel.fakebank.fakebank.dto;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.enums.PaymentMethod;
import com.gabriel.fakebank.enums.TransactionType;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
public class TransactionDto {
    private String cpf;
    private Bank bank;
    private String description;
    private String category;
    private String payer;
    private BigDecimal amount;
    private TransactionType type;
    private PaymentMethod method;
    private Integer installments;
}
