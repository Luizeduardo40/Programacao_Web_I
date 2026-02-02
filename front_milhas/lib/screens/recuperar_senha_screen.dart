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
    if (_emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Informe seu e-mail.")));
      return;
    }

    setState(() => _isLoading = true);

    bool ok = await _apiService.solicitarRecuperacaoSenha(_emailCtrl.text);

    setState(() => _isLoading = false);

    if (ok) {
      setState(() => _etapa = 2);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Código enviado! Verifique seu e-mail."), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro. Verifique se o e-mail está correto."), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _resetar() async {
    if (_tokenCtrl.text.isEmpty || _novaSenhaCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha todos os campos.")));
      return;
    }

    setState(() => _isLoading = true);

    bool ok = await _apiService.redefinirSenha(_tokenCtrl.text, _novaSenhaCtrl.text);

    setState(() => _isLoading = false);

    if (ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Senha alterada com sucesso!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Token inválido ou expirado."), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_reset, size: 70, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  "Recuperar Senha",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_etapa == 1) _buildEtapa1() else _buildEtapa2(),

                          const SizedBox(height: 20),

                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Voltar para o Login"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEtapa1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Passo 1 de 2",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "Informe seu e-mail cadastrado. Enviaremos um código de verificação para você.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
        ),
        const SizedBox(height: 25),

        TextField(
          controller: _emailCtrl,
          decoration: const InputDecoration(
            labelText: "E-mail",
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 30),

        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
          onPressed: _enviarEmail,
          child: const Text("ENVIAR CÓDIGO"),
        ),
      ],
    );
  }

  Widget _buildEtapa2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Passo 2 de 2",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "Verifique seu e-mail e digite o código recebido abaixo junto com sua nova senha.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
        ),
        const SizedBox(height: 25),

        TextField(
          controller: _tokenCtrl,
          decoration: const InputDecoration(
            labelText: "Código (Token)",
            prefixIcon: Icon(Icons.vpn_key_outlined),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _novaSenhaCtrl,
          decoration: const InputDecoration(
            labelText: "Nova Senha",
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),

        const SizedBox(height: 30),

        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
          onPressed: _resetar,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text("REDEFINIR SENHA"),
        ),
      ],
    );
  }
}