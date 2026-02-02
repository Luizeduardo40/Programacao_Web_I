package br.edu.ifs.academico.Programacao_Web_I.dto;

import br.edu.ifs.academico.Programacao_Web_I.entity.enums.StatusCompra;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Data
public class CompraResponseDTO {
    private UUID id;
    private String descricao;
    private BigDecimal valor;
    private BigDecimal pontos;
    private StatusCompra status;
    private LocalDate dataCompra;
    private LocalDate dataCreditoEsperada;
    private String bandeiraCartao;
}