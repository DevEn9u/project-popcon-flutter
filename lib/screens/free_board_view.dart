// lib/screens/free_board_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/image_dto.dart';
import '../services/api_service.dart';
import '../models/board_dto.dart';

class FreeBoardView extends StatefulWidget {
  final String boardIdx;

  FreeBoardView({required this.boardIdx});

  @override
  _FreeBoardViewState createState() => _FreeBoardViewState();
}

class _FreeBoardViewState extends State<FreeBoardView> {
  late Future<BoardDTO> _boardFuture;

  @override
  void initState() {
    super.initState();
    _boardFuture = fetchBoardDetail();
  }

  Future<BoardDTO> fetchBoardDetail() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return await apiService.getFreeBoardDetail(widget.boardIdx);
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final String baseUrl = apiService.baseUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 상세보기'),
      ),
      body: FutureBuilder<BoardDTO>(
        future: _boardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 로딩 상태
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // 오류 상태
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            // 데이터 없음
            return Center(child: Text('게시글을 찾을 수 없습니다.'));
          } else {
            // 성공적으로 데이터 로드
            BoardDTO board = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    board.boardTitle,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '작성자: ${board.writerName} | 작성일: ${board.postDate.toLocal().toString().split(' ')[0]} | 조회수: ${board.visitCount}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  Text(
                    board.contents,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  // 이미지 리스트 표시
                  board.images.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '관련 이미지',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: board.images.length,
                                itemBuilder: (context, index) {
                                  ImageDTO image = board.images[index];
                                  // 이미지의 절대 URL을 구성
                                  String imageUrl = '$baseUrl${image.imageUrl}';
                                  return Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    // 이미지 가져오는 부분
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.broken_image, size: 50),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(height: 16),
                  // 댓글 섹션 (추후 구현)
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
