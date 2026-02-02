package br.edu.ifs.academico.Programacao_Web_I.controller;

import br.edu.ifs.academico.Programacao_Web_I.dto.*;
import br.edu.ifs.academico.Programacao_Web_I.service.PasswordResetService;
import br.edu.ifs.academico.Programacao_Web_I.service.UsuarioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UsuarioService service;

    @PostMapping("/registro")
    public ResponseEntity<UsuarioResponseDTO> registrar(@RequestBody @Valid UsuarioCadastroDTO dto) {

        UsuarioResponseDTO novoUsuario = service.cadastrar(dto);

        return ResponseEntity.status(HttpStatus.CREATED).body(novoUsuario);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDTO> login(@RequestBody @Valid UsuarioLoginDTO dto) {
        LoginResponseDTO token = service.login(dto);
        return ResponseEntity.ok(token);
    }

    @PutMapping("/perfil")
    public ResponseEntity<UsuarioResponseDTO> atualizarPerfil(
            @RequestBody @Valid AtualizarPerfilDTO dto,
            Authentication authentication
    ) {
        String email = (String) authentication.getPrincipal();
        return ResponseEntity.ok(service.atualizarPerfil(email, dto));
    }

    private final PasswordResetService passwordResetService;

    @PostMapping("/recuperar-senha")
    public ResponseEntity<Void> solicitarRecuperacao(@RequestParam String email) {
        passwordResetService.solicitarRecuperacao(email);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/resetar-senha")
    public ResponseEntity<Void> resetarSenha(@RequestBody @Valid NovaSenhaDTO dto) {
        passwordResetService.resetarSenha(dto.getToken(), dto.getNovaSenha());
        return ResponseEntity.ok().build();
    }
}