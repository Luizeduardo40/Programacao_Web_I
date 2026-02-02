package br.edu.ifs.academico.Programacao_Web_I.config;

import br.edu.ifs.academico.Programacao_Web_I.entity.ProgramaPontos;
import br.edu.ifs.academico.Programacao_Web_I.repository.ProgramaPontosRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;

import java.math.BigDecimal;
import java.util.Arrays;

@Configuration
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final ProgramaPontosRepository programaRepository;

    @Override
    public void run(String... args) throws Exception {
        if (programaRepository.count() == 0) {

            System.out.println("--- INICIALIZANDO BANCO DE DADOS COM PROGRAMAS PADRÃO ---");

            ProgramaPontos p1 = new ProgramaPontos(null, "Smiles", "Programa da GOL", new BigDecimal("1.0"));
            ProgramaPontos p2 = new ProgramaPontos(null, "Latam Pass", "Programa da Latam", new BigDecimal("1.0"));
            ProgramaPontos p3 = new ProgramaPontos(null, "TudoAzul", "Programa da Azul", new BigDecimal("1.0"));
            ProgramaPontos p4 = new ProgramaPontos(null, "Livelo", "Programa de recompensas bancário", new BigDecimal("1.0"));

            programaRepository.saveAll(Arrays.asList(p1, p2, p3, p4));

            System.out.println("--- PROGRAMAS CADASTRADOS COM SUCESSO ---");
        }
    }
}