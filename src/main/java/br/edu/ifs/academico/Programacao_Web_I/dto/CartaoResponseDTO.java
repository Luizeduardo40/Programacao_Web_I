package br.edu.ifs.academico.Programacao_Web_I.dto;

import br.edu.ifs.academico.Programacao_Web_I.entity.enums.Bandeira;
import lombok.Data;

import java.util.UUID;

@Data
public class CartaoResponseDTO {
    private UUID id;
    private Bandeira bandeira;
    private String ultimosDigitos;
    private String nomePrograma;
}