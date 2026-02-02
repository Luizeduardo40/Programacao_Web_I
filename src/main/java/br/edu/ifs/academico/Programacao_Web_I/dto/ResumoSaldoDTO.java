package br.edu.ifs.academico.Programacao_Web_I.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class ResumoSaldoDTO {
    private BigDecimal saldoTotal;
    private BigDecimal saldoPendente;
    private Long totalCompras;
}