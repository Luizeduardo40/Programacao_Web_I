import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final _nomeCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmaSenhaCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String? senhaParaEnviar = _senhaCtrl.text.isEmpty ? null : _senhaCtrl.text;

      bool sucesso = await _apiService.atualizarPerfil(_nomeCtrl.text, senhaParaEnviar);

      setState(() => _isLoading = false);

      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil atualizado!")));
          _senhaCtrl.clear();
          _confirmaSenhaCtrl.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao atualizar.")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meu Perfil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(labelText: "Nome Completo", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Informe seu nome" : null,
              ),
              const SizedBox(height: 20),
              const Divider(),
              const Text("Alterar Senha (Opcional)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              TextFormField(
                controller: _senhaCtrl,
                decoration: const InputDecoration(labelText: "Nova Senha", border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmaSenhaCtrl,
                decoration: const InputDecoration(labelText: "Confirmar Nova Senha", border: OutlineInputBorder()),
                obscureText: true,
                validator: (v) {
                  if (_senhaCtrl.text.isNotEmpty && v != _senhaCtrl.text) {
                    return "Senhas não conferem";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text("Salvar Alterações"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}