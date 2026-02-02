package br.edu.ifs.academico.Programacao_Web_I.service;

import br.edu.ifs.academico.Programacao_Web_I.dto.ResumoSaldoDTO;
import br.edu.ifs.academico.Programacao_Web_I.entity.Compra;
import br.edu.ifs.academico.Programacao_Web_I.entity.User;
import br.edu.ifs.academico.Programacao_Web_I.entity.enums.StatusCompra;
import br.edu.ifs.academico.Programacao_Web_I.repository.CompraRepository;
import br.edu.ifs.academico.Programacao_Web_I.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RelatorioService {

    private final CompraRepository compraRepository;
    private final UserRepository userRepository;

    public ResumoSaldoDTO gerarResumo(String emailUsuario) {
        User usuario = userRepository.findByEmail(emailUsuario)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        List<Compra> compras = compraRepository.findByUsuarioOrderByDataCompraDesc(usuario);

        BigDecimal totalCreditado = compras.stream()
                .filter(c -> c.getStatus() == StatusCompra.CREDITADO)
                .map(Compra::getPontosEstimados)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalPendente = compras.stream()
                .filter(c -> c.getStatus() == StatusCompra.PENDENTE)
                .map(Compra::getPontosEstimados)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        ResumoSaldoDTO resumo = new ResumoSaldoDTO();
        resumo.setSaldoTotal(totalCreditado);
        resumo.setSaldoPendente(totalPendente);
        resumo.setTotalCompras((long) compras.size());

        return resumo;
    }
}