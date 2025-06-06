package com.gabriel.fakebank.fakebank.dto;

import com.gabriel.fakebank.enums.Bank;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class PayInvoiceRequestDto {
    private String cpf;
    private Bank bank;
    private int month;
    private int year;
    private BigDecimal amount; // pode ser null ou zero se for pagar tudo
}
