import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_popcon_flutter/models/board_dto.dart';

class BoardService {
  final String baseUrl = 'http://your-api-url/api/boards';

  // 게시글 목록 조회
  Future<List<BoardDTO>> fetchBoards(int page) async {
    final response = await http.get(Uri.parse('$baseUrl?page=$page'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => BoardDTO.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load boards');
    }
  }

  // 게시글 작성
  Future<String> createBoard(BoardDTO board) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(board.toJson()),
    );

    if (response.statusCode == 201) {
      return '게시글이 등록되었습니다.';
    } else {
      throw Exception('Failed to create board');
    }
  }
}