import 'dart:io';

import 'package:flutter/material.dart';
import 'screens/mainPage.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

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
    baseUrl = 'http://192.168.0.22:8080'; // Android 에뮬레이터
  } else if (Platform.isIOS) {
    baseUrl = 'http://localhost:8080'; // iOS 시뮬레이터
  } else {
    // 실제 기기나 기타 환경
    baseUrl = 'http://192.168.0.22:8080'; // 호스트 머신의 IP 주소로 변경
  }

  // Awesome Notifications 초기화
  AwesomeNotifications().initialize(
    // 아이콘을 설정합니다. Android의 경우 drawable 폴더에 아이콘을 추가해야 합니다.
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Colors.teal,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      )
    ],
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) =>
              ApiService(baseUrl: 'http://192.168.0.22:8080'), // 환경에 맞게 변경
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
