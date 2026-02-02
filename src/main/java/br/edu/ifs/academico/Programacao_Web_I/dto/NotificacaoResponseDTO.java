package br.edu.ifs.academico.Programacao_Web_I.dto;

import br.edu.ifs.academico.Programacao_Web_I.entity.enums.TipoNotificacao;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class NotificacaoResponseDTO {
    private UUID id;
    private TipoNotificacao tipo;
    private String titulo;
    private String mensagem;
    private Boolean lida;
    private LocalDateTime dataCriacao;
    private UUID compraId;
}