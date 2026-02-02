package br.edu.ifs.academico.Programacao_Web_I.entity;

import br.edu.ifs.academico.Programacao_Web_I.entity.enums.Bandeira;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Cartao {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "usuario_id", nullable = false)
    private User usuario;

    @ManyToOne
    @JoinColumn(name = "programa_pontos_id", nullable = false)
    private ProgramaPontos programaPontos;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Bandeira bandeira;

    @Column(name = "numero_ultimos_digitos", nullable = false, length = 4)
    private String ultimosDigitos;

    @Column(name = "data_expiracao")
    private LocalDate dataExpiracao;

    private Boolean ativo = true;
}