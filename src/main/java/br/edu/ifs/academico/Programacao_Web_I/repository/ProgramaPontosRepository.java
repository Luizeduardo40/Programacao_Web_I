package br.edu.ifs.academico.Programacao_Web_I.repository;

import br.edu.ifs.academico.Programacao_Web_I.entity.ProgramaPontos;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ProgramaPontosRepository extends JpaRepository<ProgramaPontos, UUID> {
    boolean existsByNome(String nome);
}