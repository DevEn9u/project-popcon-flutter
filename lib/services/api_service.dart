import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // 백엔드의 /api/test 엔드포인트에 GET 요청을 보내 연결 테스트
  Future<String> testConnection() async {
    final response = await http.get(Uri.parse('$baseUrl/api/test'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to connect to the server. Status Code: ${response.statusCode}');
    }
  }

  // 추후 로그인 기능을 구현할 때 사용할 로그인 메서드 예시
  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // JWT 토큰 등을 반환하는 경우
      final data = jsonDecode(response.body);
      return data['jwt'];
    } else {
      throw Exception('Failed to login. Status Code: ${response.statusCode}');
    }
  }
}
