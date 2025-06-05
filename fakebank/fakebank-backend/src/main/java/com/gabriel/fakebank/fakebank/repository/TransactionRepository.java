package com.gabriel.fakebank.fakebank.repository;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.enums.PaymentMethod;
import com.gabriel.fakebank.fakebank.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    List<Transaction> findByCpfAndBank(String cpf, Bank bank);

    @Query("SELECT t FROM Transaction t " +
            "WHERE t.cpf = :cpf AND t.bank = :bank " +
            "AND t.method = 'CREDIT' " +
            "AND t.paid = false " +
            "AND t.date BETWEEN :start AND :end")
    List<Transaction> findUnpaidInvoiceForMonth(
            @Param("cpf") String cpf,
            @Param("bank") Bank bank,
            @Param("start") LocalDate start,
            @Param("end") LocalDate end
    );


    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t " +
            "WHERE t.cpf = :cpf AND t.bank = :bank AND t.type = 'INCOME'")
    BigDecimal sumIncomeByCpfAndBank(@Param("cpf") String cpf, @Param("bank") Bank bank);

    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t " +
            "WHERE t.cpf = :cpf AND t.bank = :bank AND t.type = 'EXPENSE' AND t.method = 'DEBIT'")
    BigDecimal sumDebitByCpfAndBank(@Param("cpf") String cpf, @Param("bank") Bank bank);

    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t " +
            "WHERE t.cpf = :cpf AND t.bank = :bank AND t.type = 'EXPENSE'")
    BigDecimal sumExpenseByCpfAndBank(@Param("cpf") String cpf, @Param("bank") Bank bank);

    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t " +
            "WHERE t.cpf = :cpf AND t.bank = :bank AND t.type = 'INCOME' " +
            "AND t.date BETWEEN :start AND :end")
    BigDecimal sumMonthlyIncome(@Param("cpf") String cpf, @Param("bank") Bank bank,
                                @Param("start") LocalDate start, @Param("end") LocalDate end);

    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t " +
            "WHERE t.cpf = :cpf AND t.bank = :bank AND t.type = 'EXPENSE' " +
            "AND t.date BETWEEN :start AND :end")
    BigDecimal sumMonthlyExpense(@Param("cpf") String cpf, @Param("bank") Bank bank,
                                 @Param("start") LocalDate start, @Param("end") LocalDate end);

    @Query("SELECT t FROM Transaction t WHERE t.cpf = :cpf AND t.bank = :bank AND t.method = 'CREDIT' AND t.paid = false ORDER BY t.date ASC")
    List<Transaction> findUnpaidCreditInstallments(@Param("cpf") String cpf, @Param("bank") Bank bank);

    @Query("SELECT t FROM Transaction t WHERE t.cpf = :cpf AND t.bank = :bank AND t.category = 'Fatura' AND t.paid = true")
    List<Transaction> findPaidInvoices(@Param("cpf") String cpf, @Param("bank") Bank bank);

    @Query("SELECT t FROM Transaction t " +
            "WHERE t.cpf = :cpf AND t.bank = :bank " +
            "AND t.method = 'CREDIT' " +
            "AND t.date BETWEEN :start AND :end")
    List<Transaction> findCreditInstallmentsForMonth(
            @Param("cpf") String cpf,
            @Param("bank") Bank bank,
            @Param("start") LocalDate start,
            @Param("end") LocalDate end
    );
}

