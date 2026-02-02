package br.edu.ifs.academico.Programacao_Web_I.controller;

import br.edu.ifs.academico.Programacao_Web_I.dto.ComprovanteResponseDTO;
import br.edu.ifs.academico.Programacao_Web_I.entity.Comprovante;
import br.edu.ifs.academico.Programacao_Web_I.service.ArquivoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@RestController
@RequestMapping("/api/compras")
@RequiredArgsConstructor
public class ComprovanteController {

    private final ArquivoService arquivoService;

    @PostMapping("/{compraId}/anexar-comprovante")
    public ResponseEntity<ComprovanteResponseDTO> uploadComprovante(
            @PathVariable UUID compraId,
            @RequestParam("arquivo") MultipartFile arquivo
    ) {
        try {
            Comprovante comprovante = arquivoService.salvarComprovante(compraId, arquivo);

            ComprovanteResponseDTO dto = new ComprovanteResponseDTO();
            dto.setId(comprovante.getId());
            java.nio.file.Path path = java.nio.file.Paths.get(comprovante.getCaminhoArquivo());
            dto.setNomeArquivo(path.getFileName().toString());
            dto.setTipo(comprovante.getTipoArquivo());
            dto.setTamanho(comprovante.getTamanhoBytes());

            return ResponseEntity.ok(dto);

        } catch (IOException e) {
            throw new RuntimeException("Erro ao salvar arquivo: " + e.getMessage());
        }
    }
}