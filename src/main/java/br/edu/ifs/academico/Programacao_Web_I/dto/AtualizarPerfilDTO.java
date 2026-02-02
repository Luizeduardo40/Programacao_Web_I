package br.edu.ifs.academico.Programacao_Web_I.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AtualizarPerfilDTO {
    @Size(min = 3, message = "O nome deve ter no mínimo 3 caracteres")
    private String nome;

    private String telefone;
}