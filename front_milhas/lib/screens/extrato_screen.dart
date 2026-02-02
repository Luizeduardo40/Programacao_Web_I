import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import '../services/api_service.dart';

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
    if (mounted) {
      setState(() {
        _compras = lista;
        _isLoading = false;
      });
    }
  }

  void _baixarRelatorio(String formato) async {
    setState(() => _isLoading = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gerando $formato... Aguarde."), duration: const Duration(seconds: 2)),
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Download iniciado!"), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao baixar relatório."), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Pontos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Exportar PDF",
            onPressed: _isLoading ? null : () => _baixarRelatorio("pdf"),
          ),
          IconButton(
            icon: const Icon(Icons.table_view),
            tooltip: "Exportar CSV",
            onPressed: _isLoading ? null : () => _baixarRelatorio("csv"),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _compras.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _compras.length,
              itemBuilder: (context, index) {
                final item = _compras[index];
                return _buildExtratoItem(item);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 15),
        const Text(
          "Nenhuma movimentação encontrada.",
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildExtratoItem(dynamic item) {
    final status = item['status'] ?? 'PENDENTE';

    Color corStatus = Colors.orange;
    Color fundoStatus = Colors.orange.shade50;
    IconData iconeStatus = Icons.access_time;

    if (status == 'CREDITADO' || status == 'APROVADO' || status == 'CONCLUIDO') {
      corStatus = Colors.green;
      fundoStatus = Colors.green.shade50;
      iconeStatus = Icons.check_circle;
    } else if (status == 'CANCELADO' || status == 'REJEITADO') {
      corStatus = Colors.red;
      fundoStatus = Colors.red.shade50;
      iconeStatus = Icons.cancel;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_bag_outlined, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['descricao'] ?? 'Compra',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3436)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        "${item['dataCompra']} • ${item['nomeCartao'] ?? 'Cartão'}",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "+ ${item['pontos']} pts",
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF1565C0)
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: fundoStatus,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: corStatus.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(iconeStatus, size: 12, color: corStatus),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(color: corStatus, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}