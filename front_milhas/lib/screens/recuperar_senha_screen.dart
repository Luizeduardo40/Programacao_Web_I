import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecuperarSenhaScreen extends StatefulWidget {
  const RecuperarSenhaScreen({super.key});

  @override
  State<RecuperarSenhaScreen> createState() => _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends State<RecuperarSenhaScreen> {
  final ApiService _apiService = ApiService();
  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _novaSenhaCtrl = TextEditingController();

  int _etapa = 1;
  bool _isLoading = false;

  void _enviarEmail() async {
    if (_emailCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);

    bool ok = await _apiService.solicitarRecuperacaoSenha(_emailCtrl.text);

    setState(() => _isLoading = false);
    if (ok) {
      setState(() => _etapa = 2);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email enviado! Verifique seu código.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro. Verifique o e-mail.")));
    }
  }

  void _resetar() async {
    if (_tokenCtrl.text.isEmpty || _novaSenhaCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);

    bool ok = await _apiService.redefinirSenha(_tokenCtrl.text, _novaSenhaCtrl.text);

    setState(() => _isLoading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Senha alterada com sucesso!")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Token inválido ou erro no sistema.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar Senha")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_etapa == 1) ...[
              const Text("Informe seu e-mail para receber o código de recuperação."),
              const SizedBox(height: 20),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "E-mail", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _enviarEmail,
                child: _isLoading ? const CircularProgressIndicator() : const Text("Enviar Código"),
              ),
            ] else ...[
              const Text("Insira o código recebido e sua nova senha."),
              const SizedBox(height: 20),
              TextField(
                controller: _tokenCtrl,
                decoration: const InputDecoration(labelText: "Código / Token", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _novaSenhaCtrl,
                decoration: const InputDecoration(labelText: "Nova Senha", border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _resetar,
                child: _isLoading ? const CircularProgressIndicator() : const Text("Definir Nova Senha"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}