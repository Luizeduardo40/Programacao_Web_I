package br.edu.ifs.academico.Programacao_Web_I.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProgramaPontos {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(nullable = false)
    private String nome;

    private String descricao;

    @Column(name = "taxa_conversao", nullable = false)
    private BigDecimal taxaConversao = BigDecimal.ONE;
}