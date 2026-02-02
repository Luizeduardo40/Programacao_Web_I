package br.edu.ifs.academico.Programacao_Web_I.service;

import br.edu.ifs.academico.Programacao_Web_I.entity.Compra;
import br.edu.ifs.academico.Programacao_Web_I.entity.Comprovante;
import br.edu.ifs.academico.Programacao_Web_I.repository.CompraRepository;
import br.edu.ifs.academico.Programacao_Web_I.repository.ComprovanteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ArquivoService {

    private final ComprovanteRepository comprovanteRepository;
    private final CompraRepository compraRepository;

    private final Path diretorioUploads = Paths.get("uploads");

    public Comprovante salvarComprovante(UUID compraId, MultipartFile arquivo) throws IOException {
        Compra compra = compraRepository.findById(compraId)
                .orElseThrow(() -> new RuntimeException("Compra não encontrada"));

        if (!Files.exists(diretorioUploads)) {
            Files.createDirectories(diretorioUploads);
        }

        String nomeArquivo = UUID.randomUUID().toString() + "_" + arquivo.getOriginalFilename();
        Path caminhoDestino = diretorioUploads.resolve(nomeArquivo);

        Files.copy(arquivo.getInputStream(), caminhoDestino, StandardCopyOption.REPLACE_EXISTING);

        Comprovante comprovante = new Comprovante();
        comprovante.setCompra(compra);
        comprovante.setCaminhoArquivo(caminhoDestino.toString());
        comprovante.setTipoArquivo(arquivo.getContentType());
        comprovante.setTamanhoBytes(arquivo.getSize());

        return comprovanteRepository.save(comprovante);
    }
}