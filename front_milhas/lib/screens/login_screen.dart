import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'cadastro_screen.dart';
import 'recuperar_senha_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;

  void _fazerLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      bool sucesso = await _apiService.login(
        _emailController.text,
        _senhaController.text,
      );

      setState(() => _isLoading = false);

      if (sucesso && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login falhou. Verifique seus dados.'),
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
                const Icon(Icons.airplane_ticket, size: 80, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  "Milhas App",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Bem-vindo de volta",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email_outlined)),
                              validator: (v) => v!.isEmpty ? 'Informe o e-mail' : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _senhaController,
                              decoration: const InputDecoration(labelText: 'Senha', prefixIcon: Icon(Icons.lock_outline)),
                              obscureText: true,
                              validator: (v) => v!.isEmpty ? 'Informe a senha' : null,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RecuperarSenhaScreen()));
                                },
                                child: const Text("Esqueceu a senha?"),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                              onPressed: _fazerLogin,
                              child: const Text('ACESSAR CONTA'),
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastroScreen()));
                              },
                              child: const Text("Não tem uma conta? Cadastre-se"),
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