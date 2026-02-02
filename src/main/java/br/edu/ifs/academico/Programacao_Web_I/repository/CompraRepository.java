package br.edu.ifs.academico.Programacao_Web_I.repository;

import br.edu.ifs.academico.Programacao_Web_I.entity.Compra;
import br.edu.ifs.academico.Programacao_Web_I.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CompraRepository extends JpaRepository<Compra, UUID> {
    List<Compra> findByUsuarioOrderByDataCompraDesc(User usuario);
}