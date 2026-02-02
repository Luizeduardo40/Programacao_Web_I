package br.edu.ifs.academico.Programacao_Web_I.dto;

import br.edu.ifs.academico.Programacao_Web_I.entity.enums.Bandeira;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;
import java.util.UUID;

@Data
public class CriarCartaoDTO {

    @NotNull(message = "A bandeira é obrigatória")
    private Bandeira bandeira;

    @NotBlank(message = "Os últimos dígitos são obrigatórios")
    @Size(min = 4, max = 4, message = "Informe exatamente os 4 últimos dígitos")
    private String ultimosDigitos;

    @NotNull(message = "A data de expiração é obrigatória")
    private LocalDate dataExpiracao;

    @NotNull(message = "O ID do programa de pontos é obrigatório")
    private UUID programaId;
}