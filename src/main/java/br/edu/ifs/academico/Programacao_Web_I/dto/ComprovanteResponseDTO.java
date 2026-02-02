package br.edu.ifs.academico.Programacao_Web_I.dto;

import lombok.Data;
import java.util.UUID;

@Data
public class ComprovanteResponseDTO {
    private UUID id;
    private String nomeArquivo;
    private String tipo;
    private Long tamanho;
}