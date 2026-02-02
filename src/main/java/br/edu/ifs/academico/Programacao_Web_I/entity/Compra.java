package br.edu.ifs.academico.Programacao_Web_I.entity;

import br.edu.ifs.academico.Programacao_Web_I.entity.enums.StatusCompra;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Compra {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "usuario_id", nullable = false)
    private User usuario;

    @ManyToOne
    @JoinColumn(name = "cartao_id", nullable = false)
    private Cartao cartao;

    @Column(name = "valor_compra", nullable = false)
    private BigDecimal valor;

    private String descricao;

    @Column(name = "pontos_estimados")
    private BigDecimal pontosEstimados;

    @Enumerated(EnumType.STRING)
    private StatusCompra status = StatusCompra.PENDENTE;

    @Column(name = "data_compra", nullable = false)
    private LocalDate dataCompra;
}