import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
