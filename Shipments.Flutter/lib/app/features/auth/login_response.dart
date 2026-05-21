class LoginResponse {
  final String token;
  final bool mustChangePassword;

  LoginResponse({
    required this.token,
    required this.mustChangePassword,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token']?.toString() ?? '',
      mustChangePassword: json['mustChangePassword'] == true,
    );
  }
}