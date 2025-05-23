package com.gabriel.fakebank.fakebank.dto;

import com.gabriel.fakebank.enums.Bank;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
public class MonthlySummaryDto {
    private String cpf;
    private Bank bank;
    private int month;
    private int year;
    private BigDecimal income;
    private BigDecimal expense;
    private BigDecimal balance;
}
