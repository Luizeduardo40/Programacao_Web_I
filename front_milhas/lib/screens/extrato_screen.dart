import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:html' as html;
import 'dart:typed_data';

class ExtratoScreen extends StatefulWidget {
  const ExtratoScreen({super.key});

  @override
  State<ExtratoScreen> createState() => _ExtratoScreenState();
}

class _ExtratoScreenState extends State<ExtratoScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _compras = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarExtrato();
  }

  void _carregarExtrato() async {
    var lista = await _apiService.getExtrato();
    setState(() {
      _compras = lista;
      _isLoading = false;
    });
  }

  void _baixarRelatorio(String formato) async {
    setState(() => _isLoading = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gerando $formato... Aguarde.")),
    );

    Uint8List? arquivoBytes = await _apiService.downloadRelatorio(formato);

    setState(() => _isLoading = false);

    if (arquivoBytes != null) {
      final blob = html.Blob([arquivoBytes]);

      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "extrato_milhas.$formato")
        ..click();

      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download iniciado!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text("Erro ao baixar relatório.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Pontos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Exportar PDF",
            onPressed: () => _baixarRelatorio("pdf"),
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: "Exportar CSV",
            onPressed: () => _baixarRelatorio("csv"),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _compras.isEmpty
          ? const Center(child: Text("Nenhuma movimentação encontrada."))
          : ListView.builder(
        itemCount: _compras.length,
        itemBuilder: (context, index) {
          final item = _compras[index];
          final status = item['status'] ?? 'PENDENTE';

          Color corStatus = Colors.grey;
          if (status == 'CREDITADO') corStatus = Colors.green;
          if (status == 'CANCELADO') corStatus = Colors.red;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                child: const Icon(Icons.shopping_bag, color: Colors.blueAccent),
              ),
              title: Text(item['descricao'] ?? 'Compra'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Data: ${item['dataCompra'] ?? '--'}"),
                  Text("Cartão: ${item['bandeiraCartao'] ?? 'Crédito'}"),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "+ ${item['pontos']} pts",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: corStatus.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: corStatus, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}