package br.edu.ifs.academico.Programacao_Web_I.service;

import br.edu.ifs.academico.Programacao_Web_I.dto.CompraResponseDTO;
import com.lowagie.text.*;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import org.springframework.stereotype.Service;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.PrintWriter;
import java.util.List;

@Service
public class ExportService {

    public ByteArrayInputStream gerarPdfCompras(List<CompraResponseDTO> compras) {
        Document document = new Document();
        ByteArrayOutputStream out = new ByteArrayOutputStream();

        try {
            PdfWriter.getInstance(document, out);
            document.open();

            Font fontTitulo = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14);
            Paragraph titulo = new Paragraph("Extrato de Compras - Milhas", fontTitulo);
            titulo.setAlignment(Element.ALIGN_CENTER);
            document.add(titulo);
            document.add(Chunk.NEWLINE);

            PdfPTable table = new PdfPTable(4);
            table.setWidthPercentage(100);

            String[] headers = {"Data", "Descrição", "Valor (R$)", "Pontos"};
            for (String header : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(header));
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                cell.setBackgroundColor(java.awt.Color.LIGHT_GRAY);
                table.addCell(cell);
            }

            for (CompraResponseDTO compra : compras) {
                table.addCell(compra.getDataCompra().toString());
                table.addCell(compra.getDescricao());
                table.addCell(compra.getValor().toString());
                table.addCell(compra.getPontos().toString());
            }

            document.add(table);
            document.close();

        } catch (DocumentException e) {
            throw new RuntimeException("Erro ao gerar PDF", e);
        }

        return new ByteArrayInputStream(out.toByteArray());
    }

    public void gerarCsvCompras(List<CompraResponseDTO> compras, PrintWriter writer) {
        writer.write("Data,Descricao,Valor,Pontos\n");

        for (CompraResponseDTO compra : compras) {
            writer.write(String.format("%s,%s,%s,%s\n",
                    compra.getDataCompra(),
                    compra.getDescricao(),
                    compra.getValor(),
                    compra.getPontos()));
        }
    }
}