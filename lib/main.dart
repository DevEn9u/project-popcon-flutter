import 'package:flutter/material.dart';
import 'screens/mainPage.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';

void main() {
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
