import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class NovaCompraScreen extends StatefulWidget {
  const NovaCompraScreen({super.key});

  @override
  State<NovaCompraScreen> createState() => _NovaCompraScreenState();
}

class _NovaCompraScreenState extends State<NovaCompraScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final _descricaoCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _dataCtrl = TextEditingController(text: DateTime.now().toString().split(' ')[0]);

  List<dynamic> _cartoes = [];
  String? _cartaoSelecionadoId;
  PlatformFile? _arquivoSelecionado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarCartoes();
  }

  void _carregarCartoes() async {
    var lista = await _apiService.getCartoes();
    setState(() => _cartoes = lista);
  }

  Future<void> _selecionarArquivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );
    if (result != null) setState(() => _arquivoSelecionado = result.files.first);
  }

  void _salvarCompra() async {
    if (!_formKey.currentState!.validate() || _cartaoSelecionadoId == null) {
      return;
    }

    if (_arquivoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Anexe um comprovante!")));
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> dadosCompra = {
      "descricao": _descricaoCtrl.text,
      "valor": double.tryParse(_valorCtrl.text.replaceAll(',', '.')) ?? 0.0,
      "dataCompra": _dataCtrl.text,
      "cartaoId": _cartaoSelecionadoId,
    };

    String? idCompraCriada = await _apiService.criarCompra(dadosCompra);

    if (idCompraCriada != null) {
      bool uploadSucesso = await _apiService.uploadComprovante(idCompraCriada, _arquivoSelecionado!);

      setState(() => _isLoading = false);

      if (uploadSucesso) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compra e comprovante salvos!")));
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compra salva, mas erro ao enviar foto.")));
          Navigator.pop(context);
        }
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao registrar a compra.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Compra', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Detalhes da Transação",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                      ),
                      const SizedBox(height: 30),

                      DropdownButtonFormField<String>(
                        value: _cartaoSelecionadoId,
                        items: _cartoes.map((c) => DropdownMenuItem(
                          value: c['id'].toString(),
                          child: Text("${c['bandeira']} (Final ${c['ultimosDigitos']})"),
                        )).toList(),
                        onChanged: (v) => setState(() => _cartaoSelecionadoId = v),
                        decoration: const InputDecoration(labelText: "Cartão Utilizado", prefixIcon: Icon(Icons.credit_card)),
                        validator: (v) => v == null ? "Selecione o cartão" : null,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _descricaoCtrl,
                        decoration: const InputDecoration(labelText: "Descrição", prefixIcon: Icon(Icons.description)),
                        validator: (v) => v!.isEmpty ? "Obrigatório" : null,
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _valorCtrl,
                              decoration: const InputDecoration(labelText: "Valor (R\$)", prefixText: "R\$ ", prefixIcon: Icon(Icons.attach_money)),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) => v!.isEmpty ? "Obrigatório" : null,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: TextFormField(
                              controller: _dataCtrl,
                              decoration: const InputDecoration(labelText: "Data", prefixIcon: Icon(Icons.calendar_month)),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      InkWell(
                        onTap: _selecionarArquivo,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _arquivoSelecionado == null ? Icons.cloud_upload_outlined : Icons.check_circle,
                                size: 40,
                                color: _arquivoSelecionado == null ? Colors.blue : Colors.green,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _arquivoSelecionado == null ? "Clique para anexar comprovante" : _arquivoSelecionado!.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _salvarCompra,
                        child: const Text("REGISTRAR COMPRA"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}