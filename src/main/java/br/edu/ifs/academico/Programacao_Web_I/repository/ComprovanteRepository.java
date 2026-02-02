package br.edu.ifs.academico.Programacao_Web_I.repository;

import br.edu.ifs.academico.Programacao_Web_I.entity.Comprovante;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ComprovanteRepository extends JpaRepository<Comprovante, UUID> {
}