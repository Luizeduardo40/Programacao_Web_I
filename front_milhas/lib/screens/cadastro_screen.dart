import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _isLoading = false;

  void _realizarCadastro() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      bool sucesso = await _apiService.cadastrarUsuario(
        _nomeController.text,
        _emailController.text,
        _senhaController.text,
      );

      setState(() => _isLoading = false);

      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cadastro realizado com sucesso! Faça login.'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao cadastrar. Tente outro e-mail.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
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
            colors: [
              Color(0xFF1565C0),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add_alt_1, size: 60, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  "Criar Conta",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Preencha seus dados",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                            const SizedBox(height: 25),

                            TextFormField(
                              controller: _nomeController,
                              decoration: const InputDecoration(
                                labelText: 'Nome Completo',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (v) => v!.isEmpty ? 'Informe seu nome' : null,
                            ),
                            const SizedBox(height: 20),

                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => !v!.contains('@') ? 'E-mail inválido' : null,
                            ),
                            const SizedBox(height: 20),

                            TextFormField(
                              controller: _senhaController,
                              decoration: const InputDecoration(
                                labelText: 'Senha',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                              validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                            ),
                            const SizedBox(height: 30),

                            _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                              onPressed: _realizarCadastro,
                              child: const Text('FINALIZAR CADASTRO'),
                            ),

                            const SizedBox(height: 20),

                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Já tem uma conta? Voltar"),
                            ),
                          ],
                        ),
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
}