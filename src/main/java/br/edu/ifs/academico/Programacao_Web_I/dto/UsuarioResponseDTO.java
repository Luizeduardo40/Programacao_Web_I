package br.edu.ifs.academico.Programacao_Web_I.dto;

import lombok.Data;
import java.util.UUID;

@Data
public class UsuarioResponseDTO {
    private UUID id;
    private String nome;
    private String email;
}