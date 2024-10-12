// lib/screens/free_board_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/image_dto.dart';
import '../models/comment_dto.dart'; // 추가
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
      backgroundColor: Color(0xFF121212), // Scaffold 배경색 설정
      appBar: AppBar(
        title: Text(
          '게시글 상세보기',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF121212), // AppBar 배경색 설정
        iconTheme: IconThemeData(color: Colors.white), // AppBar 아이콘 색상 설정
      ),
      body: FutureBuilder<BoardDTO>(
        future: _boardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 로딩 상태
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // 오류 상태
            return Center(
              child: Text(
                '오류: ${snapshot.error}',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData) {
            // 데이터 없음
            return Center(
              child: Text(
                '게시글을 찾을 수 없습니다.',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            // 성공적으로 데이터 로드
            BoardDTO board = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 게시글 제목
                  Text(
                    board.boardTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // 텍스트 색상 설정
                    ),
                  ),
                  SizedBox(height: 8),
                  // 작성자 정보 및 조회수
                  Text(
                    '작성자: ${board.writerName} | 작성일: ${board.postDate.toLocal().toString().split(' ')[0]} | 조회수: ${board.visitCount}',
                    style: TextStyle(
                      color: Colors.grey, // 텍스트 색상 설정
                    ),
                  ),
                  SizedBox(height: 16),
                  // 게시글 내용
                  Text(
                    board.contents,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // 텍스트 색상 설정
                    ),
                  ),
                  SizedBox(height: 16),
                  // 이미지 섹션
                  board.images.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '관련 이미지',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // 텍스트 색상 설정
                              ),
                            ),
                            SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: board.images.length,
                              itemBuilder: (context, index) {
                                ImageDTO image = board.images[index];
                                String imageUrl = '$baseUrl${image.imageUrl}';
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    width: double.infinity,
                                    height: 200, // 원하는 높이로 조정
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.white70),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(height: 16),
                  // 댓글 섹션
                  board.comments.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '댓글',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // 텍스트 색상 설정
                              ),
                            ),
                            SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: board.comments.length,
                              itemBuilder: (context, index) {
                                CommentDTO comment = board.comments[index];
                                return Card(
                                  color: Color(0xFF1e1e1e), // 카드 배경색 설정
                                  margin: EdgeInsets.symmetric(vertical: 4.0),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 댓글 작성자 및 작성일
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              comment.comWriterName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Colors.white, // 텍스트 색상 설정
                                              ),
                                            ),
                                            Text(
                                              comment.getFormattedPostDate(),
                                              style: TextStyle(
                                                color: Colors.grey, // 텍스트 색상 설정
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        // 댓글 이미지 (있을 경우)
                                        comment.comImg.isNotEmpty
                                            ? Column(
                                                children:
                                                    comment.comImg.map((image) {
                                                  String imageUrl =
                                                      '$baseUrl${image.imageUrl}';
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 4.0),
                                                    child: CachedNetworkImage(
                                                      imageUrl: imageUrl,
                                                      width: double.infinity,
                                                      height: 150,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context,
                                                              url) =>
                                                          Center(
                                                              child:
                                                                  CircularProgressIndicator()),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(
                                                        Icons.broken_image,
                                                        size: 50,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              )
                                            : SizedBox(),
                                        SizedBox(height: 4),
                                        // 댓글 내용
                                        Text(
                                          comment.comContents,
                                          style: TextStyle(
                                            color: Colors.white, // 텍스트 색상 설정
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : Text(
                          '댓글이 없습니다.',
                          style: TextStyle(color: Colors.white), // 텍스트 색상 설정
                        ),
                  SizedBox(height: 16),
                  // 댓글 작성 기능은 생략
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
