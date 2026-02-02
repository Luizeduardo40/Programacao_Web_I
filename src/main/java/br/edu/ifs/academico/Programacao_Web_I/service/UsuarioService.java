package br.edu.ifs.academico.Programacao_Web_I.service;

import br.edu.ifs.academico.Programacao_Web_I.dto.*;
import br.edu.ifs.academico.Programacao_Web_I.entity.User;
import br.edu.ifs.academico.Programacao_Web_I.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import br.edu.ifs.academico.Programacao_Web_I.exception.RegraNegocioException;
import java.util.Optional; // tirar essa porra

@Service
@RequiredArgsConstructor
public class UsuarioService {

    private final UserRepository repository;
    private final PasswordEncoder passwordEncoder;
    private final TokenService tokenService;

    public UsuarioResponseDTO cadastrar(UsuarioCadastroDTO dto) {
        if (repository.findByEmail(dto.getEmail()).isPresent()) {
            throw new RegraNegocioException("E-mail já cadastrado no sistema.");
        }

        User user = new User();
        user.setNome(dto.getNome());
        user.setEmail(dto.getEmail());
        user.setSenha(passwordEncoder.encode(dto.getSenha()));


        User userSalvo = repository.save(user);

        UsuarioResponseDTO response = new UsuarioResponseDTO();
        response.setId(userSalvo.getId());
        response.setNome(userSalvo.getNome());
        response.setEmail(userSalvo.getEmail());

        return response;
    }

    public LoginResponseDTO login(UsuarioLoginDTO dto) {
        User user = repository.findByEmail(dto.getEmail())
                .orElseThrow(() -> new RegraNegocioException("Usuário não encontrado"));

        if (!passwordEncoder.matches(dto.getSenha(), user.getSenha())) {
            throw new RegraNegocioException("Senha inválida");
        }

        String token = tokenService.gerarToken(user);

        LoginResponseDTO response = new LoginResponseDTO();
        response.setNome(user.getNome());
        response.setToken(token);

        return response;
    }

    public UsuarioResponseDTO atualizarPerfil(String email, AtualizarPerfilDTO dto) {
        User user = repository.findByEmail(email)
                .orElseThrow(() -> new br.edu.ifs.academico.Programacao_Web_I.exception.RegraNegocioException("Usuário não encontrado"));

        if (dto.getNome() != null && !dto.getNome().isBlank()) {
            user.setNome(dto.getNome());
        }
        if (dto.getTelefone() != null) {
            user.setTelefone(dto.getTelefone());
        }

        User userSalvo = repository.save(user);

        UsuarioResponseDTO response = new UsuarioResponseDTO();
        response.setId(userSalvo.getId());
        response.setNome(userSalvo.getNome());
        response.setEmail(userSalvo.getEmail());
        return response;
    }
}