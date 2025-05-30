// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/login-response.dart';

class ApiService {
  // On Android emulator use 10.0.2.2; on web use localhost
  static final String _host = kIsWeb ? 'localhost' : '10.0.2.2';
  static final String baseUrl = 'http://$_host:8080/api/auth';

  Future<bool> signup({
    required String name,
    required String cpf,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/signup');
    final body = jsonEncode({
      'name': name,
      'cpf': cpf,
      'email': email,
      'password': password,
    });

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    return resp.statusCode == 200;
  }

  Future<LoginResponse?> login({
    required String email,
    required String password,
  }) async {
    final creds = base64Encode(utf8.encode('$email:$password'));
    final url   = Uri.parse('$baseUrl/login');
    final resp  = await http.post(
      url,
      headers: {'Authorization': 'Basic $creds'},
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return LoginResponse.fromJson(data);
    }

    return null;
  }

  Future<List<String>> getAuthorizedBanks(String cpf) async {
  final url = Uri.parse('http://$_host:8081/api/authorization/authorized-banks/$cpf');
  final resp = await http.get(url);

  if (resp.statusCode == 200) {
    final data = jsonDecode(resp.body);
    return List<String>.from(data['banks']);
  }

  return [];
}

Future<void> requestAuthorization(String cpf, String bank) async {
  final url = Uri.parse('http://$_host:8081/api/authorization/grant?cpf=$cpf&bank=$bank');
  await http.post(url); // sem tratamento, só dispara
}

Future<List<String>> getAvailableBanks() async {
  final url = Uri.parse('http://$_host:8081/api/banks');
  final resp = await http.get(url);

  if (resp.statusCode == 200) {
    return List<String>.from(jsonDecode(resp.body));
  }

  return [];
}
}

