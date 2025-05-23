package com.gabriel.fakebank.fakebank.repository;

import com.gabriel.fakebank.enums.Bank;
import com.gabriel.fakebank.fakebank.entity.Authorization;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AuthorizationRepository extends JpaRepository<Authorization, Long> {

    Optional<Authorization> findByCpfAndBank(String cpf, Bank bank);

    List<Authorization> findAllByCpfAndAuthorizedTrue(String cpf);
}
