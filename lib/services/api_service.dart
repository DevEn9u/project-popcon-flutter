import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/board_dto.dart';

Future<List<BoardDTO>> fetchBoards(int page) async {
  final response = await http
      .get(Uri.parse('http://10.0.2.2:8080/api/freeBoard/list?page=$page'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((board) => BoardDTO.fromJson(board)).toList();
  } else {
    throw Exception('Failed to load boards');
  }
}

Future<BoardDTO> fetchBoardDetail(String boardIdx) async {
  final response = await http
      .get(Uri.parse('http://10.0.2.2:8080/api/freeBoard/view/$boardIdx'));

  if (response.statusCode == 200) {
    return BoardDTO.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load board');
  }
}

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
