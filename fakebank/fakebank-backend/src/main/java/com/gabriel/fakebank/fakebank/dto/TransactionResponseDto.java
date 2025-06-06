package com.gabriel.fakebank.fakebank.dto;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.enums.PaymentMethod;
import com.gabriel.fakebank.enums.TransactionType;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

@Data
public class TransactionResponseDto {
    private String description;
    private BigDecimal amount;
    private String category;
    private LocalDate date;
    private LocalTime time;
    private TransactionType type;
    private PaymentMethod method;
    private Bank bank;
    private Boolean paid;
}
