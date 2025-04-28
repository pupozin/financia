package com.gabriel.financia.backend.respository;

import com.gabriel.financia.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User,Long> {
    Optional<User> findByEmail(String email);
    boolean existsByCpf(String cpf);
}