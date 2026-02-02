package br.edu.ifs.academico.Programacao_Web_I.service;

import br.edu.ifs.academico.Programacao_Web_I.dto.UsuarioResponseDTO;
import br.edu.ifs.academico.Programacao_Web_I.entity.PasswordResetToken;
import br.edu.ifs.academico.Programacao_Web_I.entity.User;
import br.edu.ifs.academico.Programacao_Web_I.exception.RegraNegocioException;
import br.edu.ifs.academico.Programacao_Web_I.repository.PasswordResetTokenRepository;
import br.edu.ifs.academico.Programacao_Web_I.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class PasswordResetService {

    private final UserRepository userRepository;
    private final PasswordResetTokenRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;

    public void solicitarRecuperacao(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RegraNegocioException("E-mail não encontrado"));

        String token = UUID.randomUUID().toString();
        PasswordResetToken myToken = new PasswordResetToken(token, user);
        tokenRepository.save(myToken);

        log.info("---------------------------------------------------------");
        log.info("SIMULAÇÃO DE EMAIL DE RECUPERAÇÃO PARA: {}", email);
        log.info("Link para resetar senha: http://localhost:8080/resetar-senha?token={}", token);
        log.info("Token puro: {}", token);
        log.info("---------------------------------------------------------");
    }

    public void resetarSenha(String token, String novaSenha) {
        PasswordResetToken resetToken = tokenRepository.findByToken(token)
                .orElseThrow(() -> new RegraNegocioException("Token inválido"));

        if (resetToken.getDataExpiracao().isBefore(LocalDateTime.now())) {
            throw new RegraNegocioException("Token expirado. Solicite uma nova recuperação.");
        }

        User user = resetToken.getUser();
        user.setSenha(passwordEncoder.encode(novaSenha));
        userRepository.save(user);

        tokenRepository.delete(resetToken);

        log.info("Senha alterada com sucesso para o usuário: {}", user.getEmail());
    }
}