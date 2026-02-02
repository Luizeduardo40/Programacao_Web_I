import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'meus_cartoes_screen.dart';
import 'nova_compra_screen.dart';
import 'programas_screen.dart';
import 'extrato_screen.dart';
import 'perfil_screen.dart';
// import '../widgets/grafico_pontos_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  int _saldoTotal = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    var extrato = await _apiService.getExtrato();
    int total = 0;
    for (var item in extrato) {
      if (item['pontosGanhos'] != null) {
        total += (item['pontosGanhos'] as num).toInt();
      }
    }

    if (mounted) {
      setState(() {
        _saldoTotal = total;
        _isLoading = false;
      });
    }
  }

  void _logout() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Minhas Milhas", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Meu Perfil',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            tooltip: 'Sair',
            onPressed: _logout,
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: RefreshIndicator(
            onRefresh: () async => _carregarDados(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSaldoCard(),

                  const SizedBox(height: 30),

                  const Text(
                    "Acesso Rápido",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                  ),

                  const SizedBox(height: 15),

                  _buildMenuGrid(context),

                  const SizedBox(height: 30),

                  // 3. ESPAÇO PARA GRÁFICO (Se tiver implementado)
                  // const GraficoPontosCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaldoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars, color: Color(0xFFFFCA28), size: 28),
              SizedBox(width: 10),
              Text(
                "Saldo Atual",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
              : Text(
            "$_saldoTotal pts",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Acumulados em todos os cartões",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final menus = [
      {
        "titulo": "Meus Cartões",
        "icon": Icons.credit_card,
        "color": Colors.blue,
        "action": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MeusCartoesScreen()))
      },
      {
        "titulo": "Nova Compra",
        "icon": Icons.add_shopping_cart,
        "color": Colors.green,
        "action": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NovaCompraScreen()))
      },
      {
        "titulo": "Programas",
        "icon": Icons.airplane_ticket,
        "color": Colors.orange,
        "action": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgramasScreen()))
      },
      {
        "titulo": "Extrato",
        "icon": Icons.history,
        "color": Colors.purple,
        "action": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExtratoScreen()))
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int colunas = constraints.maxWidth > 600 ? 4 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: colunas,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: menus.length,
          itemBuilder: (context, index) {
            final item = menus[index];
            return _buildMenuCard(
              item['titulo'] as String,
              item['icon'] as IconData,
              item['color'] as MaterialColor,
              item['action'] as VoidCallback,
            );
          },
        );
      },
    );
  }

  Widget _buildMenuCard(String title, IconData icon, MaterialColor color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF2D3436),
              ),
            ),
          ],
        ),
      ),
    );
  }
}