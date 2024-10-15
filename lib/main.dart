import 'dart:io';

import 'package:flutter/material.dart';
import 'screens/mainPage.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 전역 에러 핸들러 설정
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    // 필요한 경우 로그를 서버로 전송하거나 추가 처리를 할 수 있습니다.
  };

  // 환경에 따라 Base URL을 동적으로 설정
  String baseUrl;
  if (Platform.isAndroid) {
    baseUrl = 'http://10.0.2.2:8080'; // Android 에뮬레이터
  } else if (Platform.isIOS) {
    baseUrl = 'http://localhost:8080'; // iOS 시뮬레이터
  } else {
    // 실제 기기나 기타 환경
    baseUrl = 'http://192.168.1.100:8080'; // 호스트 머신의 IP 주소로 변경
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) =>
              ApiService(baseUrl: 'http://10.0.2.2:8080'), // 환경에 맞게 변경
        ),
        // 다른 프로바이더들도 추가 가능
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'project-popcon-flutter',
      home: MainPage(), // MainPage 위젯을 사용
    );
  }
}
