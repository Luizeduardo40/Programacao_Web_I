import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MeusCartoesScreen extends StatefulWidget {
  const MeusCartoesScreen({super.key});

  @override
  State<MeusCartoesScreen> createState() => _MeusCartoesScreenState();
}

class _MeusCartoesScreenState extends State<MeusCartoesScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _bandeiraCtrl = TextEditingController();
  final _digitosCtrl = TextEditingController();
  final _validadeCtrl = TextEditingController();
  String? _programaSelecionadoId;

  List<dynamic> _cartoes = [];
  List<dynamic> _programas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    setState(() => _isLoading = true);
    var cartoes = await _apiService.getCartoes();
    var programas = await _apiService.getProgramas();

    if (mounted) {
      setState(() {
        _cartoes = cartoes;
        _programas = programas;
        _isLoading = false;
      });
    }
  }

  void _abrirModalNovoCartao() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 24, left: 24, right: 24
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            const Text("Adicionar Cartão", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _programaSelecionadoId,
                    items: _programas.map((p) => DropdownMenuItem(
                      value: p['id'].toString(),
                      child: Text(p['nome']),
                    )).toList(),
                    onChanged: (v) => setState(() => _programaSelecionadoId = v),
                    decoration: const InputDecoration(labelText: "Programa de Pontos", prefixIcon: Icon(Icons.stars)),
                    validator: (v) => v == null ? "Selecione um programa" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _bandeiraCtrl,
                    decoration: const InputDecoration(labelText: "Bandeira (ex: Visa)", prefixIcon: Icon(Icons.branding_watermark)),
                    validator: (v) => v!.isEmpty ? "Obrigatório" : null,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _digitosCtrl,
                          decoration: const InputDecoration(labelText: "Últimos 4 dígitos", prefixIcon: Icon(Icons.numbers)),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          validator: (v) => v!.length != 4 ? "4 dígitos" : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextFormField(
                          controller: _validadeCtrl,
                          decoration: const InputDecoration(labelText: "Validade", prefixIcon: Icon(Icons.calendar_today)),
                          validator: (v) => v!.isEmpty ? "Obrigatório" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _salvarCartao,
                      child: const Text("SALVAR CARTÃO"),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _salvarCartao() async {
    Navigator.pop(context);
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Cartões", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirModalNovoCartao,
        label: const Text("Novo Cartão"),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFFFCA28),
        foregroundColor: Colors.black87,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _cartoes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _cartoes.length,
            itemBuilder: (context, index) {
              final c = _cartoes[index];
              return _buildCreditCard(c);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.credit_card_off, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 10),
        const Text("Nenhum cartão cadastrado", style: TextStyle(color: Colors.grey, fontSize: 18)),
      ],
    );
  }

  Widget _buildCreditCard(dynamic cartao) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cartao['bandeira']?.toUpperCase() ?? "CARTÃO",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5),
              ),
              const Icon(Icons.contactless, color: Colors.white70),
            ],
          ),
          Row(
            children: [
              const Text("•••• •••• •••• ", style: TextStyle(color: Colors.white70, fontSize: 22, letterSpacing: 2)),
              Text(
                cartao['ultimosDigitos'] ?? "0000",
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("VALIDADE", style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(cartao['validade'] ?? "--/--", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              // Aqui poderia ir o logo da bandeira se tivesse imagem
            ],
          )
        ],
      ),
    );
  }
}