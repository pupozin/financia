package com.gabriel.fakebank.fakebank.dto;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.fakebank.entity.Transaction;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class ConsolidatedDashboardDto {
    private String cpf;
    private List<Bank> authorizedBanks;

    private BigDecimal income;
    private BigDecimal expense;
    private BigDecimal balance;
    private BigDecimal invoiceTotal;

    private List<InstallmentDto> pendingInstallments;
    private List<Transaction> transactions; // usa sua própria entidade
}
