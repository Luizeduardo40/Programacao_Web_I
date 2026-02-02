package br.edu.ifs.academico.Programacao_Web_I.service;

import br.edu.ifs.academico.Programacao_Web_I.dto.CartaoResponseDTO;
import br.edu.ifs.academico.Programacao_Web_I.dto.CriarCartaoDTO;
import br.edu.ifs.academico.Programacao_Web_I.entity.Cartao;
import br.edu.ifs.academico.Programacao_Web_I.entity.ProgramaPontos;
import br.edu.ifs.academico.Programacao_Web_I.entity.User;
import br.edu.ifs.academico.Programacao_Web_I.repository.CartaoRepository;
import br.edu.ifs.academico.Programacao_Web_I.repository.ProgramaPontosRepository;
import br.edu.ifs.academico.Programacao_Web_I.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CartaoService {

    private final CartaoRepository cartaoRepository;
    private final UserRepository userRepository;
    private final ProgramaPontosRepository programaRepository;

    public CartaoResponseDTO criarCartao(CriarCartaoDTO dto, String emailUsuarioLogado) {
        User usuario = userRepository.findByEmail(emailUsuarioLogado)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        ProgramaPontos programa = programaRepository.findById(dto.getProgramaId())
                .orElseThrow(() -> new RuntimeException("Programa de pontos não encontrado"));

        Cartao cartao = new Cartao();
        cartao.setUsuario(usuario);
        cartao.setProgramaPontos(programa);
        cartao.setBandeira(dto.getBandeira());
        cartao.setUltimosDigitos(dto.getUltimosDigitos());
        cartao.setDataExpiracao(dto.getDataExpiracao());

        Cartao cartaoSalvo = cartaoRepository.save(cartao);

        return mapToDTO(cartaoSalvo);
    }

    public List<CartaoResponseDTO> listarCartoes(String emailUsuarioLogado) {
        User usuario = userRepository.findByEmail(emailUsuarioLogado)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        return cartaoRepository.findByUsuario(usuario).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    // Método para converter Entidade -> DTO
    private CartaoResponseDTO mapToDTO(Cartao cartao) {
        CartaoResponseDTO dto = new CartaoResponseDTO();
        dto.setId(cartao.getId());
        dto.setBandeira(cartao.getBandeira());
        dto.setUltimosDigitos(cartao.getUltimosDigitos());
        dto.setNomePrograma(cartao.getProgramaPontos().getNome());
        return dto;
    }
}