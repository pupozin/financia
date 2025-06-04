package com.gabriel.fakebank.fakebank.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class InstallmentDto {
    private Long id;
    private String description;
    private BigDecimal amount;
    private LocalDate dueDate;
}
