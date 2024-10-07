import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Drawer 아이콘의 색상 변경
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Image.asset(
          'assets/images/logo.png',
          height: 30,
        ),
      ),
      endDrawer: Container(
        width: 500,
        child: Drawer(
          child: Container(
            color: Colors.black,
            child: ListView(
              children: [
                Container(
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white), // DrawerHeader와 본문 경계
                ListTile(
                  leading: const Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                  title: const Text(
                    '홈',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context); // 드로어 닫기
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.my_library_books,
                    color: Colors.white,
                  ),
                  title: const Text('팝업게시판',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context); // 드로어 닫기
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.my_library_books,
                    color: Colors.white,
                  ),
                  title: const Text('자유게시판',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context); // 드로어 닫기
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // 위쪽에 정렬
          children: [
            const Divider(color: Colors.white),
            Card(
              margin: const EdgeInsets.all(16.0), // 카드 간의 간격
              child: Container(
                width: 500,
                height: 200, // 고정된 높이 설정
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/popup_image1.jfif',
                      width: 142,
                      height: 142,
                    ),
                    const SizedBox(width: 16), // 이미지와 텍스트 사이의 간격
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '첫 번째 텍스트',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            '두 번째 텍스트',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(16.0), // 카드 간의 간격
              child: Container(
                width: 500,
                height: 200, // 고정된 높이 설정
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/popup_image1.jfif',
                      width: 142,
                      height: 142,
                    ),
                    const SizedBox(width: 16), // 이미지와 텍스트 사이의 간격
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '세 3번째 텍스트',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            '네 번째 텍스트',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 추가 카드를 더 필요하다면 여기에 계속 추가
          ],
        ),
      ),
    );
  }
}
