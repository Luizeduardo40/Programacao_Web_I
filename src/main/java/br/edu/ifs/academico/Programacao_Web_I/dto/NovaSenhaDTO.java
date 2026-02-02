package br.edu.ifs.academico.Programacao_Web_I.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class NovaSenhaDTO {
    @NotBlank
    private String token;

    @NotBlank
    @Size(min=6, message="A senha deve ter no mínimo 6 caracteres")
    private String novaSenha;
}