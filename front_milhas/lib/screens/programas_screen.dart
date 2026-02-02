import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProgramasScreen extends StatefulWidget {
  const ProgramasScreen({super.key});

  @override
  State<ProgramasScreen> createState() => _ProgramasScreenState();
}

class _ProgramasScreenState extends State<ProgramasScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _programas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarProgramas();
  }

  void _carregarProgramas() async {
    var lista = await _apiService.getProgramas();
    if (mounted) {
      setState(() {
        _programas = lista;
        _isLoading = false;
      });
    }
  }

  void _abrirModalCadastro() {
    showDialog(
      context: context,
      builder: (context) => CadastroProgramaDialog(
        onSalvo: _carregarProgramas,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programas de Fidelidade', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirModalCadastro,
        backgroundColor: const Color(0xFFFFCA28),
        icon: const Icon(Icons.add, color: Colors.black87),
        label: const Text("Novo Programa", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _programas.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _programas.length,
              itemBuilder: (context, index) {
                final prog = _programas[index];
                return _buildProgramaCard(prog);
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
        Icon(Icons.airplane_ticket_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 15),
        const Text(
          "Nenhum programa cadastrado",
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildProgramaCard(dynamic prog) {
    String inicial = prog['nome'] != null && prog['nome'].toString().isNotEmpty
        ? prog['nome'].toString()[0].toUpperCase()
        : "?";

    final corBase = Colors.primaries[prog['nome'].toString().length % Colors.primaries.length];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: corBase.withOpacity(0.15),
          child: Text(
            inicial,
            style: TextStyle(color: corBase, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        title: Text(
          prog['nome'] ?? 'Sem Nome',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3436)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              const Icon(Icons.swap_horiz, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text("Fator de Conversão: ${prog['taxaConversao'] ?? 1.0}"),
            ],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade300),
      ),
    );
  }
}

class CadastroProgramaDialog extends StatefulWidget {
  final VoidCallback onSalvo;

  const CadastroProgramaDialog({super.key, required this.onSalvo});

  @override
  State<CadastroProgramaDialog> createState() => _CadastroProgramaDialogState();
}

class _CadastroProgramaDialogState extends State<CadastroProgramaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _fatorCtrl = TextEditingController(text: "1.0");
  final ApiService _apiService = ApiService();
  bool _saving = false;

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _saving = true);

      double fator = double.tryParse(_fatorCtrl.text.replaceAll(',', '.')) ?? 1.0;

      bool sucesso = await _apiService.cadastrarPrograma(_nomeCtrl.text, fator);

      if (mounted) {
        if (sucesso) {
          widget.onSalvo();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Programa criado com sucesso!"), backgroundColor: Colors.green),
          );
        } else {
          setState(() => _saving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro ao criar programa."), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Novo Programa", style: TextStyle(fontWeight: FontWeight.bold)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                  labelText: "Nome (ex: Smiles)",
                  prefixIcon: Icon(Icons.airplane_ticket),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => v!.isEmpty ? "Nome obrigatório" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fatorCtrl,
                decoration: const InputDecoration(
                  labelText: "Fator (1.0 = 1 pra 1)",
                  prefixIcon: Icon(Icons.exposure),
                  border: OutlineInputBorder(),
                  helperText: "Quantos pontos ganha por ponto do cartão?",
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? "Fator obrigatório" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _salvar,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Salvar"),
        ),
      ],
    );
  }
}