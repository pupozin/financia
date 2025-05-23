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
    List<Transaction> findByCpfAndBankAndMethodAndDateBetween(
            String cpf,
            Bank bank,
            PaymentMethod method,
            LocalDate start,
            LocalDate end
    );

    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t " +
            "WHERE t.cpf = :cpf AND t.bank = :bank AND t.type = 'INCOME'")
    BigDecimal sumIncomeByCpfAndBank(@Param("cpf") String cpf, @Param("bank") Bank bank);

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

}
