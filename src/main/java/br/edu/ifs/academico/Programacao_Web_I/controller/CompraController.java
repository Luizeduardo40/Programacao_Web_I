package br.edu.ifs.academico.Programacao_Web_I.controller;

import br.edu.ifs.academico.Programacao_Web_I.dto.CompraResponseDTO;
import br.edu.ifs.academico.Programacao_Web_I.dto.CriarCompraDTO;
import br.edu.ifs.academico.Programacao_Web_I.service.CompraService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/compras")
@RequiredArgsConstructor
public class CompraController {

    private final CompraService service;

    @PostMapping
    public ResponseEntity<CompraResponseDTO> registrar(
            @RequestBody @Valid CriarCompraDTO dto,
            Authentication authentication
    ) {
        String emailUsuario = (String) authentication.getPrincipal();
        CompraResponseDTO novaCompra = service.registrarCompra(dto, emailUsuario);
        return ResponseEntity.status(HttpStatus.CREATED).body(novaCompra);
    }

    @GetMapping
    public ResponseEntity<List<CompraResponseDTO>> listar(Authentication authentication) {
        String emailUsuario = (String) authentication.getPrincipal();
        return ResponseEntity.ok(service.listarMinhasCompras(emailUsuario));
    }
}