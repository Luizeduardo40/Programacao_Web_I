package br.edu.ifs.academico.Programacao_Web_I.controller;

import br.edu.ifs.academico.Programacao_Web_I.dto.ResumoSaldoDTO;
import br.edu.ifs.academico.Programacao_Web_I.service.CompraService;
import br.edu.ifs.academico.Programacao_Web_I.service.ExportService;
import br.edu.ifs.academico.Programacao_Web_I.service.RelatorioService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@RestController
@RequestMapping("/api/relatorios")
@RequiredArgsConstructor
public class RelatorioController {

    private final RelatorioService service;

    private final RelatorioService relatorioService;
    private final CompraService compraService;
    private final ExportService exportService;

    @GetMapping("/resumo")
    public ResponseEntity<ResumoSaldoDTO> obterResumo(Authentication authentication) {
        String email = (String) authentication.getPrincipal();
        return ResponseEntity.ok(service.gerarResumo(email));
    }

    @GetMapping("/compras/pdf")
    public ResponseEntity<InputStreamResource> exportarPdf(Authentication authentication) {
        String email = (String) authentication.getPrincipal();
        var compras = compraService.listarMinhasCompras(email);

        var pdfStream = exportService.gerarPdfCompras(compras);

        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=extrato.pdf");

        return ResponseEntity
                .ok()
                .headers(headers)
                .contentType(MediaType.APPLICATION_PDF)
                .body(new InputStreamResource(pdfStream));
    }

    @GetMapping("/compras/csv")
    public void exportarCsv(Authentication authentication, HttpServletResponse response) throws IOException {
        String email = (String) authentication.getPrincipal();
        var compras = compraService.listarMinhasCompras(email);

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=extrato.csv");

        exportService.gerarCsvCompras(compras, response.getWriter());
    }
}