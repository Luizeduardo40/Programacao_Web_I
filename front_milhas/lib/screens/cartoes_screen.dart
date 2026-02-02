import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartoesScreen extends StatefulWidget {
  const CartoesScreen({super.key});

  @override
  State<CartoesScreen> createState() => _CartoesScreenState();
}

class _CartoesScreenState extends State<CartoesScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _cartoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarCartoes();
  }

  void _carregarCartoes() async {
    var lista = await _apiService.getCartoes();
    setState(() {
      _cartoes = lista;
      _isLoading = false;
    });
  }

  void _abrirFormularioCadastro() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CadastroCartaoModal(onSuccess: _carregarCartoes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Cartões')),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormularioCadastro,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartoes.isEmpty
          ? const Center(child: Text("Nenhum cartão cadastrado."))
          : ListView.builder(
        itemCount: _cartoes.length,
        itemBuilder: (context, index) {
          final cartao = _cartoes[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.credit_card, size: 40, color: Colors.blue),
              title: Text("${cartao['bandeira']} **** ${cartao['ultimosDigitos']}"),
              subtitle: Text("Validade: ${cartao['dataExpiracao'] ?? '--/--'}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}

class CadastroCartaoModal extends StatefulWidget {
  final VoidCallback onSuccess;
  const CadastroCartaoModal({required this.onSuccess, super.key});

  @override
  State<CadastroCartaoModal> createState() => _CadastroCartaoModalState();
}

class _CadastroCartaoModalState extends State<CadastroCartaoModal> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String? _bandeiraSelecionada;
  String? _programaSelecionadoId;
  final _ultimosDigitosCtrl = TextEditingController();
  final _dataValidadeCtrl = TextEditingController();

  List<dynamic> _programasDisponiveis = [];
  final List<String> _bandeiras = ['VISA', 'MASTERCARD', 'ELO', 'AMEX'];

  @override
  void initState() {
    super.initState();
    _carregarProgramas();
  }

  void _carregarProgramas() async {
    var lista = await _apiService.getProgramas();
    setState(() => _programasDisponiveis = lista);
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> dados = {
        "bandeira": _bandeiraSelecionada,
        "ultimosDigitos": _ultimosDigitosCtrl.text,
        "dataExpiracao": "${_dataValidadeCtrl.text}-01",
        "programaId": _programaSelecionadoId
      };

      bool sucesso = await _apiService.cadastrarCartao(dados);
      if (sucesso && mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cartão Salvo!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao salvar.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 16
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Novo Cartão", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: _bandeiraSelecionada,
              items: _bandeiras.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (v) => setState(() => _bandeiraSelecionada = v),
              decoration: const InputDecoration(labelText: "Bandeira"),
              validator: (v) => v == null ? "Selecione a bandeira" : null,
            ),

            DropdownButtonFormField<String>(
              value: _programaSelecionadoId,
              items: _programasDisponiveis.map((p) => DropdownMenuItem(
                value: p['id'].toString(),
                child: Text(p['nome']),
              )).toList(),
              onChanged: (v) => setState(() => _programaSelecionadoId = v),
              decoration: const InputDecoration(labelText: "Programa de Pontos"),
              hint: const Text("Selecione o programa (ex: Livelo)"),
              validator: (v) => v == null ? "Selecione um programa" : null,
            ),

            TextFormField(
              controller: _ultimosDigitosCtrl,
              decoration: const InputDecoration(labelText: "Últimos 4 dígitos"),
              keyboardType: TextInputType.number,
              maxLength: 4,
              validator: (v) => (v == null || v.length < 4) ? "Inválido" : null,
            ),

            TextFormField(
              controller: _dataValidadeCtrl,
              decoration: const InputDecoration(labelText: "Validade (AAAA-MM)", hintText: "2028-12"),
              validator: (v) => v!.isEmpty ? "Informe a validade" : null,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text("Salvar Cartão")
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}