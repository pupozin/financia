
class LoginResponse {
  final int id;
  final String name;
  final String email;
  final bool firstAccess;

  LoginResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.firstAccess,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id:          json['id']          as int,
      name:        json['name']        as String,
      email:       json['email']       as String,
      firstAccess: json['firstAccess'] as bool,
    );
  }
}
