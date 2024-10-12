import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:project_popcon_flutter/screens/popup_board_view.dart';
import 'package:project_popcon_flutter/widgets/custom_drawer.dart';
import 'package:project_popcon_flutter/widgets/popup_board_widget.dart';

class PopupBoard extends StatefulWidget {
  const PopupBoard({super.key});

  @override
  State<PopupBoard> createState() => _PopupBoardState();
}

class _PopupBoardState extends State<PopupBoard> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class PopupBoardList extends StatelessWidget {
  const PopupBoardList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Drawer 아이콘의 색상 변경
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF121212),
        title: Image.asset(
          'assets/images/logo.png',
          height: 30,
        ),
      ),
      endDrawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          color: Color(0xFF121212),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // 위쪽에 정렬
            children: [
              const Divider(color: Colors.grey),
              Container(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    children: const [
                      TextSpan(
                        text: "진행중인 팝업",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: " 10월",
                        style: TextStyle(
                          color: Color(0xFFf0002e),
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PopupBoardWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

/* data가 없을 수도 있기 때문에 async, await을 이용해서 콜백데이터가
    넘어올 때까지 대기했다가 파싱해야함 */
void getRequest() async {
  // API 사이트에서 하나의 게시물을 얻어온 후 파싱
  var url = Uri.parse("https://jsonplaceholder.typicode.com/posts/1");
  /* get 방식의 요청을 통해 응답이 올 때까지 기다린 후 콜백데이터 저장 */
  http.Response response = await http.get(
    url,
    headers: {"Accept": "application/json"},
  );

  // 응답 데이터
  var statusCode = response.statusCode;
  var responseBody = utf8.decode(response.bodyBytes);
  // print("statusCode : $statusCode");
  // print("responseBody : $responseBody");

  // 1차 파싱
  var jsonData = jsonDecode(responseBody);
  print('### 1차파싱: $jsonData ###');

  // 각 Key를 이용해서 데이터 인출
  String userId = jsonData['userId'].toString();
  String id = jsonData['id'].toString();
  String title = jsonData['title'].toString();
  String body = jsonData['body'].toString();

  // console에 결과 출력
  print("userId : $userId");
  print("id : $id");
  print("title : $title");
  print("body : $body");
}

void getRequest2() async {
  // API 사이트에서 하나의 게시물을 얻어온 후 파싱
  var url = Uri.parse("https://jsonplaceholder.typicode.com/posts");
  /* get 방식의 요청을 통해 응답이 올 때까지 기다린 후 콜백데이터 저장 */
  http.Response response = await http.get(
    url,
    headers: {"Accept": "application/json"},
  );

  // 응답 데이터
  var statusCode = response.statusCode;
  var responseBody = utf8.decode(response.bodyBytes);
  // print("statusCode : $statusCode");
  // print("responseBody : $responseBody");

  // 1차 파싱
  var jsonData = jsonDecode(responseBody);
  print('### 1차파싱: $jsonData ###');

  // row는 jsonData의 데이터의 각 항목.
  for (var row in jsonData) {
    String userId = row['userId'].toString();
    String id = row['id'].toString();
    String title = row['title'].toString();
    String body = row['body'].toString();

    print("userId : $userId");
    print("id : $id");
    print("title : $title");
    print("body : $body");
    print("======================");
  }
}
