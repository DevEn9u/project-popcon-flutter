import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project_popcon_flutter/models/popupboard_dto.dart';
import '../models/board_dto.dart';
import 'package:http/http.dart' as http;
import '../models/comment_dto.dart'; // 추가
import '../models/image_dto.dart'; // 필요 시 추가

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;
  final String baseUrl = 'http://10.0.2.2:8080'; // 실제 기기 테스트 시 IP 주소로 변경
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String? _token;

  factory ApiService({required String baseUrl}) {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio();

    // 요청/응답 인터셉터 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // JWT 토큰 설정 (JWT 기반 인증용)
          _token = await _secureStorage.read(key: 'jwt_token');
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          print('요청 URL: ${options.uri}');
          print('요청 헤더: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('응답 상태 코드: ${response.statusCode}');
          print('응답 데이터: ${response.data}');
          return handler.next(response);
        },
        onError: (DioError e, handler) {
          print('에러 발생: ${e.message}');
          if (e.response != null) {
            print('에러 응답 데이터: ${e.response?.data}');
            print('에러 상태 코드: ${e.response?.statusCode}');
          }
          return handler.next(e);
        },
      ),
    );

    // 기본 옵션 설정
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 5); // 5초
    _dio.options.receiveTimeout = Duration(seconds: 3); // 3초
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  static ApiService get instance => _instance;

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

  // JWT 기반 로그인 요청
  Future<Map<String, dynamic>> jwtLogin(String id, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'id': id,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        String token = response.data['token'];
        await _secureStorage.write(key: 'jwt_token', value: token);
        print('JWT 로그인 성공: $token');
        return response.data;
      } else if (response.statusCode == 401) {
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

  // 로그아웃 요청 (JWT 기반)
  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
    // 추가적으로 서버 로그아웃 엔드포인트가 있다면 호출
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

  // 팝업 이미지 리스트를 가져오는 메서드
  Future<List<PopupboardDTO>> listPopup() async {
    final url = Uri.parse('$baseUrl/api/popupBoard/list'); // API 경로로 변경

    // 요청 URL 로그 출력
    print('API 요청: GET $baseUrl$url');

    try {
      final response = await http.get(url);
      print('API 응답 데이터: $response');

      if (response.statusCode == 200) {
        // 서버에서 받은 JSON 데이터를 리스트로 변환
        List<dynamic> jsonData = json.decode(response.body);
        print('Data 출력: $jsonData');

        // thumb 필드가 null인 항목을 필터링
        List<PopupboardDTO> popupList = jsonData
            .map((item) => PopupboardDTO.fromJson(item))
            .where((popup) =>
                popup.thumb != null &&
                popup.thumb!.isNotEmpty) // thumb가 null 또는 빈 문자열인 항목을 필터링
            .toList();

        return popupList;
      } else {
        throw Exception('Failed to load popups');
      }
    } catch (e) {
      print('Error fetching popup list: $e');
      throw e;
    }
  }

  // 팝업 게시글 목록 조회
  Future<List<PopupboardDTO>> getPopupBoardList() async {
    final String url = '/api/popupBoard/list';

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data
            .map((popupJson) => PopupboardDTO.fromJson(popupJson))
            .toList();
      } else {
        throw Exception('팝업 게시글 목록을 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      throw Exception('팝업 게시글 목록을 불러오는 데 실패했습니다. Error: $e');
    }
  }

  // 팝업 게시글 상세 조회
  Future<PopupboardDTO> getPopupBoardDetail(String boardIdx) async {
    final String url = '/api/popupBoard/$boardIdx';

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        return PopupboardDTO.fromJson(data);
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

  // 사용자가 좋아요한 팝업 목록을 가져오는 메서드
  Future<List<PopupboardDTO>> getLikedPopups() async {
    try {
      final response = await _dio.get('/api/likes/mypopups');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => PopupboardDTO.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('로그인이 필요합니다.');
      } else {
        throw Exception('좋아요한 팝업을 가져오는 데 실패했습니다.');
      }
    } catch (e) {
      throw Exception('좋아요한 팝업을 가져오는 데 실패했습니다. Error: $e');
    }
  }

  // 기타 API 메서드 추가 가능
}
