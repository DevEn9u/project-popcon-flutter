// lib/services/api_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../models/board_dto.dart';
import '../models/comment_dto.dart'; // 추가
import '../models/image_dto.dart'; // 필요 시 추가

class ApiService {
  final Dio _dio;
  final String baseUrl;

  ApiService({required this.baseUrl}) : _dio = Dio() {
    // 쿠키 매니저 설정
    _dio.interceptors.add(CookieManager(CookieJar()));
    // 기본 옵션 설정
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 5); // 5초
    _dio.options.receiveTimeout = Duration(seconds: 3); // 3초
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  // 백엔드의 /api/test 엔드포인트에 GET 요청을 보내 연결 테스트
  Future<String> testConnection() async {
    try {
      final response = await _dio.get('/api/test');

      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        throw Exception(
            'Failed to connect to the server. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server. Error: $e');
    }
  }

  // 특정 회원 정보 조회
  Future<Map<String, dynamic>> getMember(String id) async {
    try {
      final response = await _dio.get('/api/members/$id');

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 404) {
        throw Exception('Member not found');
      } else {
        throw Exception('Failed to load member');
      }
    } catch (e) {
      throw Exception('Failed to load member. Error: $e');
    }
  }

  // 로그인 요청
  Future<Map<String, dynamic>> login(String id, String password) async {
    try {
      final response = await _dio.post(
        '/api/members/login',
        data: {
          'id': id,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 401) {
        // 서버에서 전달한 오류 메시지를 파싱
        final Map<String, dynamic> errorResponse = response.data;
        throw Exception(errorResponse['message'] ?? '인증에 실패했습니다.');
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorResponse = response.data;
        throw Exception(errorResponse['message'] ?? '잘못된 요청입니다.');
      } else {
        throw Exception('로그인에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('로그인에 실패했습니다. Error: $e');
    }
  }

  // 자유게시판 목록 조회
  Future<List<BoardDTO>> getFreeBoards({int page = 1}) async {
    try {
      final response = await _dio.get('/api/freeBoard/list?page=$page');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((boardJson) => BoardDTO.fromJson(boardJson)).toList();
      } else {
        throw Exception('자유게시판 목록을 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      throw Exception('자유게시판 목록을 불러오는 데 실패했습니다. Error: $e');
    }
  }

  // 자유게시판 게시글 상세 조회
  Future<BoardDTO> getFreeBoardDetail(String boardIdx) async {
    final String url = '/api/freeBoard/view/$boardIdx';

    // 요청 URL 로그 출력
    print('API 요청: GET $baseUrl$url');

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        print('API 응답 데이터: $data');
        return BoardDTO.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('게시글을 찾을 수 없습니다.');
      } else {
        try {
          Map<String, dynamic> errorResponse = response.data;
          String message = errorResponse['message'] ?? '게시글을 불러오는 데 실패했습니다.';
          throw Exception(message);
        } catch (_) {
          throw Exception('게시글을 불러오는 데 실패했습니다.');
        }
      }
    } catch (e) {
      throw Exception('게시글을 불러오는 데 실패했습니다. Error: $e');
    }
  }

  // 기타 API 메서드 추가 가능
}
