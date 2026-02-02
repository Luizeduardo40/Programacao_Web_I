package br.edu.ifs.academico.Programacao_Web_I.service;

import br.edu.ifs.academico.Programacao_Web_I.dto.NotificacaoResponseDTO;
import br.edu.ifs.academico.Programacao_Web_I.entity.Compra;
import br.edu.ifs.academico.Programacao_Web_I.entity.Notificacao;
import br.edu.ifs.academico.Programacao_Web_I.entity.User;
import br.edu.ifs.academico.Programacao_Web_I.entity.enums.TipoNotificacao;
import br.edu.ifs.academico.Programacao_Web_I.repository.NotificacaoRepository;
import br.edu.ifs.academico.Programacao_Web_I.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificacaoService {

    private final NotificacaoRepository repository;
    private final UserRepository userRepository;

    public void criar(User usuario, String titulo, String mensagem, TipoNotificacao tipo, Compra compra) {
        Notificacao notificacao = new Notificacao();
        notificacao.setUsuario(usuario);
        notificacao.setTitulo(titulo);
        notificacao.setMensagem(mensagem);
        notificacao.setTipo(tipo);
        notificacao.setCompraRelacionada(compra);

        repository.save(notificacao);
    }

    public List<NotificacaoResponseDTO> listarPorUsuario(String emailUsuario) {
        User usuario = userRepository.findByEmail(emailUsuario)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        return repository.findByUsuarioOrderByDataCriacaoDesc(usuario).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public void marcarComoLida(UUID id, String emailUsuario) {
        Notificacao notificacao = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Notificação não encontrada"));

        if (!notificacao.getUsuario().getEmail().equals(emailUsuario)) {
            throw new RuntimeException("Acesso negado a esta notificação");
        }

        notificacao.setLida(true);
        notificacao.setDataLeitura(LocalDateTime.now());
        repository.save(notificacao);
    }

    private NotificacaoResponseDTO mapToDTO(Notificacao entity) {
        NotificacaoResponseDTO dto = new NotificacaoResponseDTO();
        dto.setId(entity.getId());
        dto.setTipo(entity.getTipo());
        dto.setTitulo(entity.getTitulo());
        dto.setMensagem(entity.getMensagem());
        dto.setLida(entity.getLida());
        dto.setDataCriacao(entity.getDataCriacao());
        if (entity.getCompraRelacionada() != null) {
            dto.setCompraId(entity.getCompraRelacionada().getId());
        }
        return dto;
    }
}