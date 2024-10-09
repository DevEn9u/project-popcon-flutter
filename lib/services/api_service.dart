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

  // 특정 회원 정보 조회
  Future<Map<String, dynamic>> getMember(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/members/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
    } else if (response.statusCode == 404) {
      throw Exception('Member not found');
    } else {
      throw Exception('Failed to load member');
    }
  }

  // 로그인 요청
  Future<Map<String, dynamic>> login(String id, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/members/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': id,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
    } else if (response.statusCode == 401) {
      // 서버에서 전달한 오류 메시지를 파싱
      final Map<String, dynamic> errorResponse =
          jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(errorResponse['message'] ?? '인증에 실패했습니다.');
    } else if (response.statusCode == 400) {
      final Map<String, dynamic> errorResponse =
          jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(errorResponse['message'] ?? '잘못된 요청입니다.');
    } else {
      throw Exception('로그인에 실패했습니다.');
    }
  }
}
