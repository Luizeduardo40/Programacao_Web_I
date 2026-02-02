package br.edu.ifs.academico.Programacao_Web_I.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Data
public class CriarCompraDTO {

    @NotNull(message = "O cartão é obrigatório")
    private UUID cartaoId;

    @NotNull(message = "O valor é obrigatório")
    @DecimalMin(value = "0.01", message = "O valor deve ser positivo")
    private BigDecimal valor;

    @NotBlank(message = "A descrição é obrigatória")
    private String descricao;

    @NotNull(message = "A data da compra é obrigatória")
    @PastOrPresent(message = "A data não pode ser no futuro")
    private LocalDate dataCompra;
}