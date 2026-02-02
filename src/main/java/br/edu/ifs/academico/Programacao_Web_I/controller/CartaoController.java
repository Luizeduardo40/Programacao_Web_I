package br.edu.ifs.academico.Programacao_Web_I.controller;

import br.edu.ifs.academico.Programacao_Web_I.dto.CartaoResponseDTO;
import br.edu.ifs.academico.Programacao_Web_I.dto.CriarCartaoDTO;
import br.edu.ifs.academico.Programacao_Web_I.service.CartaoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cartoes")
@RequiredArgsConstructor
public class CartaoController {

    private final CartaoService service;

    @PostMapping
    public ResponseEntity<CartaoResponseDTO> cadastrar(
            @RequestBody @Valid CriarCartaoDTO dto,
            Authentication authentication
    ) {
        String emailUsuario = (String) authentication.getPrincipal();

        CartaoResponseDTO novoCartao = service.criarCartao(dto, emailUsuario);
        return ResponseEntity.status(HttpStatus.CREATED).body(novoCartao);
    }

    @GetMapping
    public ResponseEntity<List<CartaoResponseDTO>> listarMeusCartoes(Authentication authentication) {
        String emailUsuario = (String) authentication.getPrincipal();
        return ResponseEntity.ok(service.listarCartoes(emailUsuario));
    }
}