package com.gabriel.fakebank.fakebank.service;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.enums.PaymentMethod;
import com.gabriel.fakebank.enums.TransactionType;
import com.gabriel.fakebank.fakebank.dto.ConsolidatedDashboardDto;
import com.gabriel.fakebank.fakebank.dto.InstallmentDto;
import com.gabriel.fakebank.fakebank.dto.MonthlySummaryDto;
import com.gabriel.fakebank.fakebank.dto.TransactionDto;
import com.gabriel.fakebank.fakebank.entity.Transaction;
import com.gabriel.fakebank.fakebank.repository.TransactionRepository;
import org.springframework.stereotype.Service;
import com.gabriel.fakebank.fakebank.repository.AuthorizationRepository;
import com.gabriel.fakebank.fakebank.entity.Authorization;


import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;

@Service
public class TransactionService {

    private final TransactionRepository repository;

    private final AuthorizationRepository authorizationRepository;

    public TransactionService(TransactionRepository repository, AuthorizationRepository authorizationRepository) {
        this.repository = repository;
        this.authorizationRepository = authorizationRepository;
    }

    public ConsolidatedDashboardDto getConsolidatedDashboardData(String cpf, int month, int year) {
        List<Bank> authorizedBanks = authorizationRepository.findAllByCpfAndAuthorizedTrue(cpf)
                .stream().map(Authorization::getBank).toList();

        BigDecimal totalIncome = BigDecimal.ZERO;
        BigDecimal totalExpense = BigDecimal.ZERO;
        BigDecimal totalBalance = BigDecimal.ZERO;
        BigDecimal totalInvoice = BigDecimal.ZERO;

        List<Transaction> allTransactions = new java.util.ArrayList<>();
        List<InstallmentDto> allInstallments = new java.util.ArrayList<>();

        for (Bank bank : authorizedBanks) {
            // Income, expense e balance
            MonthlySummaryDto summary = getMonthlySummary(cpf, bank, month, year);
            totalIncome = totalIncome.add(summary.getIncome());
            totalExpense = totalExpense.add(summary.getExpense());
            totalBalance = totalBalance.add(getBalance(cpf, bank));

            // Invoice: somar os valores da lista
            List<Transaction> invoiceList = getInvoice(cpf, bank, month, year);
            BigDecimal invoiceTotal = invoiceList.stream()
                    .map(Transaction::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            totalInvoice = totalInvoice.add(invoiceTotal);

            // Unpaid installments
            List<Transaction> installments = getUnpaidInstallments(cpf, bank);
            for (Transaction t : installments) {
                InstallmentDto dto = new InstallmentDto();
                dto.setId(t.getId());
                dto.setDescription(t.getDescription());
                dto.setAmount(t.getAmount());
                dto.setDueDate(t.getDate());
                allInstallments.add(dto);
            }

            // Histórico
            allTransactions.addAll(listByCpfAndBank(cpf, bank.name()));
        }

        ConsolidatedDashboardDto dto = new ConsolidatedDashboardDto();
        dto.setCpf(cpf);
        dto.setAuthorizedBanks(authorizedBanks);
        dto.setIncome(totalIncome);
        dto.setExpense(totalExpense);
        dto.setBalance(totalBalance);
        dto.setInvoiceTotal(totalInvoice);
        dto.setPendingInstallments(allInstallments);
        dto.setTransactions(allTransactions);

        return dto;
    }


    public void saveTransaction(TransactionDto dto) {
        Transaction t = new Transaction();
        t.setCpf(dto.getCpf());
        t.setBank(dto.getBank());
        t.setDescription(dto.getDescription());
        t.setCategory(dto.getCategory());
        t.setPayer(dto.getPayer());
        t.setAmount(dto.getAmount());
        t.setDate(LocalDate.now());
        t.setType(dto.getType());
        t.setMethod(dto.getMethod());
        t.setInstallments(dto.getInstallments());
        t.setInstallmentNumber(1); // por padrão, será 1 (vamos melhorar na parte de crédito depois)

        repository.save(t);
    }

    public List<Transaction> listByCpfAndBank(String cpf, String bank) {
        return repository.findByCpfAndBank(cpf, Bank.valueOf(bank));
    }

    public void registerIncome(TransactionDto dto) {
        Transaction t = new Transaction();
        t.setCpf(dto.getCpf());
        t.setBank(dto.getBank());
        t.setDescription(dto.getDescription());
        t.setCategory(dto.getCategory());
        t.setPayer(dto.getPayer());
        t.setAmount(dto.getAmount());
        t.setDate(LocalDate.now());
        t.setType(TransactionType.INCOME);
        t.setMethod(PaymentMethod.CASH); // ou dto.getMethod() se quiser permitir selecionar

        repository.save(t);
    }

    public void registerDebit(TransactionDto dto) {
        Transaction t = new Transaction();
        t.setCpf(dto.getCpf());
        t.setBank(dto.getBank());
        t.setDescription(dto.getDescription());
        t.setCategory(dto.getCategory());
        t.setPayer(dto.getPayer());
        t.setAmount(dto.getAmount());
        t.setDate(LocalDate.now());
        t.setType(TransactionType.EXPENSE);
        t.setMethod(PaymentMethod.DEBIT);
        t.setInstallments(1);
        t.setInstallmentNumber(1);

        repository.save(t);
    }

    public void registerCredit(TransactionDto dto) {
        int installments = dto.getInstallments() != null ? dto.getInstallments() : 1;
        BigDecimal installmentValue = dto.getAmount().divide(BigDecimal.valueOf(installments), 2, RoundingMode.HALF_UP);

        for (int i = 0; i < installments; i++) {
            Transaction t = new Transaction();
            t.setCpf(dto.getCpf());
            t.setBank(dto.getBank());
            t.setDescription(dto.getDescription());
            t.setCategory(dto.getCategory());
            t.setPayer(dto.getPayer());
            t.setAmount(installmentValue);
            t.setDate(LocalDate.now().plusMonths(i)); // cada parcela em um mês
            t.setType(TransactionType.EXPENSE);
            t.setMethod(PaymentMethod.CREDIT);
            t.setInstallments(installments);
            t.setInstallmentNumber(i + 1);

            repository.save(t);
        }
    }

    public List<Transaction> getInvoice(String cpf, Bank bank, int month, int year) {
        LocalDate start = LocalDate.of(year, month, 1);
        LocalDate end = YearMonth.of(year, month).atEndOfMonth();
        return repository.findUnpaidInvoiceForMonth(cpf, bank, start, end);
    }


    public BigDecimal getBalance(String cpf, Bank bank) {
        BigDecimal income = repository.sumIncomeByCpfAndBank(cpf, bank);
        BigDecimal debit = repository.sumDebitByCpfAndBank(cpf, bank); // agora só débito
        return income.subtract(debit);
    }

    public MonthlySummaryDto getMonthlySummary(String cpf, Bank bank, int month, int year) {
        LocalDate start = LocalDate.of(year, month, 1);
        LocalDate end = YearMonth.of(year, month).atEndOfMonth();

        BigDecimal income = repository.sumMonthlyIncome(cpf, bank, start, end);
        BigDecimal expense = repository.sumMonthlyExpense(cpf, bank, start, end);
        BigDecimal balance = income.subtract(expense);

        MonthlySummaryDto dto = new MonthlySummaryDto();
        dto.setCpf(cpf);
        dto.setBank(bank);
        dto.setMonth(month);
        dto.setYear(year);
        dto.setIncome(income);
        dto.setExpense(expense);
        dto.setBalance(balance);

        return dto;
    }

    public List<Transaction> getUnpaidInstallments(String cpf, Bank bank) {
        return repository.findUnpaidCreditInstallments(cpf, bank);
    }

    public void payInstallment(Long id) {
        Transaction original = repository.findById(id).orElseThrow();

        if (!original.isPaid()) {
            original.setPaid(true);
            repository.save(original);

            // Registra nova transação como débito
            Transaction payment = new Transaction();
            payment.setCpf(original.getCpf());
            payment.setBank(original.getBank());
            payment.setDescription("Pagamento da fatura: " + original.getDescription());
            payment.setCategory("Fatura");
            payment.setPayer("Sistema");
            payment.setAmount(original.getAmount());
            payment.setDate(LocalDate.now());
            payment.setType(TransactionType.EXPENSE);
            payment.setMethod(PaymentMethod.DEBIT);
            payment.setInstallments(1);
            payment.setInstallmentNumber(1);
            payment.setPaid(true); // já foi paga

            repository.save(payment);
        }
    }


}
