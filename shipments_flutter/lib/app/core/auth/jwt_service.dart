import 'package:jwt_decoder/jwt_decoder.dart';

class JwtService {
  String? getRoleFromToken(String token) {
    final decodedToken = JwtDecoder.decode(token);

    const possibleRoleKeys = [
      'role',
      'Role',
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
    ];

    for (final key in possibleRoleKeys) {
      final value = decodedToken[key];

      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }
}