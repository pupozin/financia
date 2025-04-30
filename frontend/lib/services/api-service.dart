import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
   static final String _host = kIsWeb
    ? 'localhost'
    : '10.0.2.2';

  static final String baseUrl =
    'http://$_host:8080/api/auth';

  Future<bool> signup({required String name, required String cpf, required String email, required String password}) async {
    final url = Uri.parse('$baseUrl/signup');
    final body = jsonEncode({
      'name': name,
      'cpf': cpf,
      'email': email,
      'password': password,
    });
    final resp = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    return resp.statusCode == 200;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final creds = base64Encode(utf8.encode('$email:$password'));
    final url   = Uri.parse('$baseUrl/login');
    final resp  = await http.post(
      url,
      headers: {
        'Authorization': 'Basic $creds',
      },
    );
    return resp.statusCode == 200;
  }
}