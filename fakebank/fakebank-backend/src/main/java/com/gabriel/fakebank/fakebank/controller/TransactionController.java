package com.gabriel.fakebank.fakebank.controller;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.fakebank.dto.*;
import com.gabriel.fakebank.fakebank.entity.Transaction;
import com.gabriel.fakebank.fakebank.service.TransactionService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/transaction")
@CrossOrigin(origins = "*")
public class TransactionController {

    private final TransactionService service;

    public TransactionController(TransactionService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<?> registerTransaction(@RequestBody TransactionDto dto) {
        service.saveTransaction(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body("Transação registrada com sucesso.");
    }

    @PostMapping("/pay-monthly-invoice")
    public ResponseEntity<Void> payMonthlyInvoice(@RequestBody PayInvoiceRequestDto dto) {
        TransactionService.payMonthlyInvoice(dto.getCpf(), dto.getBank(), dto.getMonth(), dto.getYear(), dto.getAmount());
        return ResponseEntity.ok().build();
    }

    @GetMapping("/paid-invoices/months/{cpf}/{bank}")
    public ResponseEntity<List<MonthYearDto>> getInvoiceMonths(
            @PathVariable String cpf,
            @PathVariable Bank bank
    ) {
        List<Transaction> transactions = service.getPaidInvoices(cpf, bank);

        List<MonthYearDto> months = transactions.stream()
                .filter(t -> {
                    var method = t.getMethod().toString().toUpperCase();
                    var category = t.getCategory() != null ? t.getCategory().toLowerCase() : "";
                    return method.equals("CREDIT") || (method.equals("DEBIT") && category.equals("invoice"));
                })
                .map(t -> new MonthYearDto(t.getDate().getMonthValue(), t.getDate().getYear()))
                .distinct()
                .sorted(
                        Comparator.comparing(MonthYearDto::year)
                                .thenComparing(MonthYearDto::month)
                )
                .toList();

        return ResponseEntity.ok(months);
    }

    @GetMapping("/paid-invoices/{cpf}/{bank}/{month}/{year}")
    public ResponseEntity<List<Transaction>> getPaidInvoicesForMonth(
            @PathVariable String cpf,
            @PathVariable Bank bank,
            @PathVariable int month,
            @PathVariable int year
    ) {
        return ResponseEntity.ok(service.getPaidInvoicesForMonth(cpf, bank, month, year));
    }

    @GetMapping("/history/{cpf}/{bank}/{month}/{year}")
    public ResponseEntity<List<Transaction>> getMonthlyHistory(
            @PathVariable String cpf,
            @PathVariable Bank bank,
            @PathVariable int month,
            @PathVariable int year
    ) {
        List<Transaction> history = service.getHistoryForMonth(cpf, bank, month, year);
        return ResponseEntity.ok(history);
    }


    @GetMapping("/{cpf}/{bank}")
    public ResponseEntity<?> listTransactions(@PathVariable String cpf, @PathVariable String bank) {
        return ResponseEntity.ok(service.listByCpfAndBank(cpf, bank));
    }

    @GetMapping("/consolidated/{cpf}/{month}/{year}")
    public ResponseEntity<ConsolidatedDashboardDto> getConsolidatedData(
            @PathVariable String cpf,
            @PathVariable int month,
            @PathVariable int year
    ) {
        return ResponseEntity.ok(service.getConsolidatedDashboardData(cpf, month, year));
    }


    @PostMapping("/income")
    public ResponseEntity<?> addIncome(@RequestBody TransactionDto dto) {
        service.registerIncome(dto); // chama o método da service
        return ResponseEntity.status(HttpStatus.CREATED).body("Income registered.");
    }

    @PostMapping("/debit")
    public ResponseEntity<?> payWithDebit(@RequestBody TransactionDto dto) {
        service.registerDebit(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body("Debit transaction registered.");
    }

    @PostMapping("/credit")
    public ResponseEntity<?> payWithCredit(@RequestBody TransactionDto dto) {
        service.registerCredit(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body("Credit transaction registered in installments.");
    }

    @GetMapping("/invoice/{cpf}/{bank}/{month}/{year}")
    public ResponseEntity<?> getInvoice(
            @PathVariable String cpf,
            @PathVariable Bank bank,
            @PathVariable int month,
            @PathVariable int year
    ) {
        return ResponseEntity.ok(service.getInvoice(cpf, bank, month, year));
    }

    @GetMapping("/balance/{cpf}/{bank}")
    public ResponseEntity<?> getBalance(
            @PathVariable String cpf,
            @PathVariable Bank bank
    ) {
        BigDecimal balance = service.getBalance(cpf, bank);
        return ResponseEntity.ok(Map.of("cpf", cpf, "bank", bank, "balance", balance));
    }

    @GetMapping("/summary/{cpf}/{bank}/{month}/{year}")
    public ResponseEntity<MonthlySummaryDto> getMonthlySummary(
            @PathVariable String cpf,
            @PathVariable Bank bank,
            @PathVariable int month,
            @PathVariable int year
    ) {
        return ResponseEntity.ok(service.getMonthlySummary(cpf, bank, month, year));
    }

    @GetMapping("/unpaid-installments/{cpf}/{bank}")
    public ResponseEntity<List<Transaction>> getUnpaidInstallments(
            @PathVariable String cpf,
            @PathVariable Bank bank
    ) {
        return ResponseEntity.ok(service.getUnpaidInstallments(cpf, bank));
    }

    @PostMapping("/pay-installment/{id}")
    public ResponseEntity<String> payInstallment(@PathVariable Long id) {
        service.payInstallment(id);
        return ResponseEntity.ok("Parcela paga com sucesso!");
    }

    @GetMapping("/paid-invoices/{cpf}/{bank}")
    public ResponseEntity<List<Transaction>> getPaidInvoices(
            @PathVariable String cpf,
            @PathVariable Bank bank
    ) {
        return ResponseEntity.ok(service.getPaidInvoices(cpf, bank));
    }

}
