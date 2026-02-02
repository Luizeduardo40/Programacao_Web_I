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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Perfil atualizado com sucesso!"), backgroundColor: Colors.green),
          );
          _senhaCtrl.clear();
          _confirmaSenhaCtrl.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro ao atualizar perfil."), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Meu Perfil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, size: 80, color: Colors.blue.shade700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFCA28),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.black87, size: 20),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Dados Pessoais",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                          ),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _nomeCtrl,
                            decoration: const InputDecoration(
                              labelText: "Nome Completo",
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => v!.isEmpty ? "O campo nome é obrigatório" : null,
                          ),

                          const SizedBox(height: 30),
                          const Divider(),
                          const SizedBox(height: 20),

                          const Text(
                            "Segurança",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Preencha apenas se quiser alterar sua senha.",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _senhaCtrl,
                            decoration: const InputDecoration(
                              labelText: "Nova Senha",
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _confirmaSenhaCtrl,
                            decoration: const InputDecoration(
                              labelText: "Confirmar Nova Senha",
                              prefixIcon: Icon(Icons.lock_reset),
                            ),
                            obscureText: true,
                            validator: (v) {
                              if (_senhaCtrl.text.isNotEmpty && v != _senhaCtrl.text) {
                                return "As senhas não conferem";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 40),

                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                            onPressed: _salvar,
                            child: const Text("SALVAR ALTERAÇÕES"),
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
}