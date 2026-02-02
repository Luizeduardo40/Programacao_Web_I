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
    setState(() {
      _programas = lista;
      _isLoading = false;
    });
  }

  void _abrirModalCadastro() {
    showDialog(
      context: context,
      builder: (context) => const CadastroProgramaDialog(),
    ).then((_) => _carregarProgramas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programas de Pontos')),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirModalCadastro,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _programas.isEmpty
          ? const Center(child: Text("Nenhum programa cadastrado."))
          : ListView.builder(
        itemCount: _programas.length,
        itemBuilder: (context, index) {
          final prog = _programas[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.withOpacity(0.1),
                child: Text(prog['nome'][0].toString().toUpperCase()),
              ),
              title: Text(prog['nome']),
              subtitle: Text("Fator de Conversão: ${prog['taxaConversao'] ?? 1.0}"),
            ),
          );
        },
      ),
    );
  }
}

class CadastroProgramaDialog extends StatefulWidget {
  const CadastroProgramaDialog({super.key});

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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(sucesso ? "Programa criado!" : "Erro ao criar.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Novo Programa"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(labelText: "Nome (ex: Smiles)"),
              validator: (v) => v!.isEmpty ? "Obrigatório" : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _fatorCtrl,
              decoration: const InputDecoration(labelText: "Fator de Conversão (1.0 = 1 pra 1)"),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => v!.isEmpty ? "Obrigatório" : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        _saving
            ? const CircularProgressIndicator()
            : ElevatedButton(onPressed: _salvar, child: const Text("Salvar")),
      ],
    );
  }
}