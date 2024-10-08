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
