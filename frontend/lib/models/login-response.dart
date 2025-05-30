class LoginResponse {
  final int id;
  final String name;
  final String email;
  final String cpf;
  final bool firstAccess; // 👈 voltou aqui

  LoginResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.cpf,
    required this.firstAccess, // 👈 e aqui
  });

    Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'cpf': cpf,
    'firstAccess': firstAccess,
  };


  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id:           json['id'] as int,
      name:         json['name'] as String,
      email:        json['email'] as String,
      cpf:          json['cpf'] as String,
      firstAccess:  json['firstAccess'] as bool, // 👈 e aqui também
    );
  }
}
