package br.edu.ifs.academico.Programacao_Web_I.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@AllArgsConstructor
public class ApiErrorDTO {
    private int status;
    private String mensagem;
    private LocalDateTime timestamp;
}