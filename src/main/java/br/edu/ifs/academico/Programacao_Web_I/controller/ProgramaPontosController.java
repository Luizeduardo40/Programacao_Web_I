package br.edu.ifs.academico.Programacao_Web_I.controller;

import br.edu.ifs.academico.Programacao_Web_I.entity.ProgramaPontos;
import br.edu.ifs.academico.Programacao_Web_I.repository.ProgramaPontosRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/programas")
@RequiredArgsConstructor
public class ProgramaPontosController {

    private final ProgramaPontosRepository repository;

    @GetMapping
    public ResponseEntity<List<ProgramaPontos>> listarProgramas() {
        return ResponseEntity.ok(repository.findAll());
    }
}