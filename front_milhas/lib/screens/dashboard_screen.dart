import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';
import 'cartoes_screen.dart';
import 'nova_compra_screen.dart';
import 'extrato_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _saldoTotal = "---";

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    var dados = await _apiService.getDadosDashboard();

    setState(() {
      _isLoading = false;
      if (dados != null) {
        _saldoTotal = dados['saldoTotal']?.toString() ?? "0";
      } else {
        _saldoTotal = "Erro";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Milhas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('Saldo Total de Pontos', style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 10),
                    Text(
                      _saldoTotal,
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text("Ações Rápidas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _botaoAcao(Icons.credit_card, "Meus Cartões", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartoesScreen()));
                  }),
                  _botaoAcao(Icons.shopping_bag, "Nova Compra", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NovaCompraScreen()));
                  }),
                  _botaoAcao(Icons.airplane_ticket, "Programas", () {
                  }),
                  _botaoAcao(Icons.history, "Extrato", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ExtratoScreen()));
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoAcao(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(10),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 10),
          Text(label),
        ],
      ),
    );
  }
}