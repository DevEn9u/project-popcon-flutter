import 'package:flutter/material.dart';
import 'mainPage.dart';

void main() {
  runApp(MyApp());
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
