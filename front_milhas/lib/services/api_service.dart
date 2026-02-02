import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class ApiService {
  // Android: 'http://10.0.2.2:8080/api'
  // Chrome: 'http://localhost:8080/api'
  static const String baseUrl = 'http://localhost:8080/api';

  Future<String?> criarCompra(Map<String, dynamic> dadosCompra) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/compras');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(dadosCompra),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['id'].toString();
      } else {
        print('Erro ao criar compra: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro de conexão ao criar compra: $e');
      return null;
    }
  }

  Future<bool> uploadComprovante(String compraId, PlatformFile arquivo) async {
    final token = await getToken();
    // Atenção à URL: /api/compras/{id}/anexar-comprovante
    final url = Uri.parse('$baseUrl/compras/$compraId/anexar-comprovante');

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    if (arquivo.bytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'arquivo',
        arquivo.bytes!,
        filename: arquivo.name,
      ));
    } else if (arquivo.path != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'arquivo',
        arquivo.path!,
      ));
    }

    try {
      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao enviar comprovante: $e');
      return false;
    }
  }

  Future<bool> login(String email, String senha) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        return true;
      } else {
        print('Erro Login: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro de conexão: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, dynamic>?> getDadosDashboard() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/relatorios/resumo');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao buscar dashboard: $e');
      return null;
    }
  }

  Future<List<dynamic>> getCartoes() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/cartoes');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print('Erro ao buscar cartões: $e');
      return [];
    }
  }

  Future<List<dynamic>> getProgramas() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/programas');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> cadastrarCartao(Map<String, dynamic> dadosCartao) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/cartoes');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(dadosCartao),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Erro ao cadastrar cartão: $e');
      return false;
    }
  }
}