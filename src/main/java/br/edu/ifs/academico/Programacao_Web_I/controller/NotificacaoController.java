package br.edu.ifs.academico.Programacao_Web_I.controller;

import br.edu.ifs.academico.Programacao_Web_I.dto.NotificacaoResponseDTO;
import br.edu.ifs.academico.Programacao_Web_I.service.NotificacaoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/notificacoes")
@RequiredArgsConstructor
public class NotificacaoController {

    private final NotificacaoService service;

    @GetMapping
    public ResponseEntity<List<NotificacaoResponseDTO>> listar(Authentication authentication) {
        String email = (String) authentication.getPrincipal();
        return ResponseEntity.ok(service.listarPorUsuario(email));
    }

    @PutMapping("/{id}/lida")
    public ResponseEntity<Void> marcarComoLida(@PathVariable UUID id, Authentication authentication) {
        String email = (String) authentication.getPrincipal();
        service.marcarComoLida(id, email);
        return ResponseEntity.noContent().build();
    }
}