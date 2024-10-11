import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/board_dto.dart';

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

  // 자유게시판 목록 조회
  Future<List<BoardDTO>> getFreeBoards({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/freeBoard/list?page=$page'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((boardJson) => BoardDTO.fromJson(boardJson)).toList();
    } else {
      throw Exception('자유게시판 목록을 불러오는 데 실패했습니다.');
    }
  }

  // 자유게시판 게시글 상세 조회
  Future<BoardDTO> getFreeBoardDetail(String boardIdx) async {
    final String url = '$baseUrl/api/freeBoard/view/$boardIdx';

    // 요청 URL 로그 출력
    print('API 요청: GET $url');

    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      print('API 응답 데이터: $data');
      return BoardDTO.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('게시글을 찾을 수 없습니다.');
    } else {
      try {
        Map<String, dynamic> errorResponse =
            jsonDecode(utf8.decode(response.bodyBytes));
        String message = errorResponse['message'] ?? '게시글을 불러오는 데 실패했습니다.';
        throw Exception(message);
      } catch (_) {
        throw Exception('게시글을 불러오는 데 실패했습니다.');
      }
    }
  }

  // 기타 API 메서드 추가 가능
}
