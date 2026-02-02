package br.edu.ifs.academico.Programacao_Web_I.service;

import br.edu.ifs.academico.Programacao_Web_I.dto.CompraResponseDTO;
import br.edu.ifs.academico.Programacao_Web_I.dto.CriarCompraDTO;
import br.edu.ifs.academico.Programacao_Web_I.entity.Cartao;
import br.edu.ifs.academico.Programacao_Web_I.entity.Compra;
import br.edu.ifs.academico.Programacao_Web_I.entity.User;
import br.edu.ifs.academico.Programacao_Web_I.entity.enums.StatusCompra;
import br.edu.ifs.academico.Programacao_Web_I.repository.CartaoRepository;
import br.edu.ifs.academico.Programacao_Web_I.repository.CompraRepository;
import br.edu.ifs.academico.Programacao_Web_I.repository.UserRepository;
import br.edu.ifs.academico.Programacao_Web_I.exception.RegraNegocioException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class CompraService {

    private final CompraRepository compraRepository;
    private final CartaoRepository cartaoRepository;
    private final UserRepository userRepository;
    private final NotificacaoService notificacaoService;

    public CompraResponseDTO registrarCompra(CriarCompraDTO dto, String emailUsuario) {
        log.info("Iniciando registro de compra para o usuário: {}", emailUsuario);

        User usuario = userRepository.findByEmail(emailUsuario)
                .orElseThrow(() -> new RegraNegocioException("Usuário não encontrado"));

        Cartao cartao = cartaoRepository.findById(dto.getCartaoId())
                .orElseThrow(() -> new RegraNegocioException("Cartão não encontrado"));

        if (!cartao.getUsuario().getId().equals(usuario.getId())) {
            log.warn("Tentativa de uso de cartão de terceiros! Usuário: {}, Cartão: {}", emailUsuario, dto.getCartaoId());
            throw new RegraNegocioException("Este cartão não pertence ao usuário logado!");
        }

        BigDecimal taxa = cartao.getProgramaPontos().getTaxaConversao();
        BigDecimal pontosCalculados = dto.getValor().multiply(taxa);

        Compra compra = new Compra();
        compra.setUsuario(usuario);
        compra.setCartao(cartao);
        compra.setValor(dto.getValor());
        compra.setDescricao(dto.getDescricao());
        compra.setDataCompra(dto.getDataCompra());
        compra.setPontosEstimados(pontosCalculados);
        compra.setStatus(StatusCompra.PENDENTE);

        Compra compraSalva = compraRepository.save(compra);

        log.info("Compra registrada com sucesso! ID: {}, Pontos Estimados: {}", compraSalva.getId(), pontosCalculados);

        notificacaoService.criar(
                usuario,
                "Compra Registrada",
                "Sua compra de R$ " + dto.getValor() + " foi registrada e está aguardando crédito de pontos.",
                br.edu.ifs.academico.Programacao_Web_I.entity.enums.TipoNotificacao.COMPRA_REGISTRADA,
                compraSalva
        );

        return mapToDTO(compraSalva);
    }

    public List<CompraResponseDTO> listarMinhasCompras(String emailUsuario) {
        User usuario = userRepository.findByEmail(emailUsuario)
                .orElseThrow(() -> new RegraNegocioException("Usuário não encontrado"));

        return compraRepository.findByUsuarioOrderByDataCompraDesc(usuario).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    private CompraResponseDTO mapToDTO(Compra compra) {
        CompraResponseDTO dto = new CompraResponseDTO();
        dto.setId(compra.getId());
        dto.setDescricao(compra.getDescricao());
        dto.setValor(compra.getValor());
        dto.setDataCompra(compra.getDataCompra());
        dto.setPontos(compra.getPontosEstimados());
        dto.setStatus(compra.getStatus());

        if (compra.getCartao() != null) {
            dto.setBandeiraCartao(compra.getCartao().getBandeira().toString());
        }

        if (compra.getDataCompra() != null) {
            dto.setDataCreditoEsperada(compra.getDataCompra().plusDays(30));
        }

        return dto;
    }
}