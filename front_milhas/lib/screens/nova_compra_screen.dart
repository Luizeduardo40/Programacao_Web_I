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

    if (result != null) {
      setState(() {
        _arquivoSelecionado = result.files.first;
      });
    }
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
      appBar: AppBar(title: const Text('Nova Compra')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _cartaoSelecionadoId,
                items: _cartoes.map((c) => DropdownMenuItem(
                  value: c['id'].toString(),
                  child: Text("${c['bandeira']} (Final ${c['ultimosDigitos']})"),
                )).toList(),
                onChanged: (v) => setState(() => _cartaoSelecionadoId = v),
                decoration: const InputDecoration(labelText: "Selecione o Cartão"),
                validator: (v) => v == null ? "Obrigatório" : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _descricaoCtrl,
                decoration: const InputDecoration(labelText: "Descrição (ex: Supermercado)"),
                validator: (v) => v!.isEmpty ? "Obrigatório" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _valorCtrl,
                decoration: const InputDecoration(labelText: "Valor (R\$)", prefixText: "R\$ "),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? "Obrigatório" : null,
              ),
              const SizedBox(height: 15),

              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                child: ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: Text(_arquivoSelecionado == null ? "Anexar Comprovante (PDF/Img)" : _arquivoSelecionado!.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.cloud_upload),
                    onPressed: _selecionarArquivo,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _salvarCompra,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text("Registrar Compra"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}