package br.edu.ifs.academico.Programacao_Web_I.dto;

import lombok.Data;

@Data
public class LoginResponseDTO {
    private String nome;
    private String token;
}