package br.edu.ifs.academico.Programacao_Web_I.entity;

import br.edu.ifs.academico.Programacao_Web_I.entity.enums.TipoNotificacao;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Notificacao {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "usuario_id", nullable = false)
    private User usuario;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoNotificacao tipo;

    @Column(nullable = false)
    private String titulo;

    @Column(nullable = false)
    private String mensagem;

    @ManyToOne
    @JoinColumn(name = "compra_id")
    private Compra compraRelacionada;

    private Boolean lida = false;

    @Column(name = "data_criacao")
    private LocalDateTime dataCriacao;

    @Column(name = "data_leitura")
    private LocalDateTime dataLeitura;

    @PrePersist
    protected void onCreate() {
        this.dataCriacao = LocalDateTime.now();
    }
}