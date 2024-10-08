import 'package:flutter/material.dart';
import '../models/board_dto.dart';
import '../services/api_service.dart';

class FreeBoardView extends StatelessWidget {
  final String boardIdx;

  FreeBoardView({required this.boardIdx});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('게시글 상세보기')),
      body: FutureBuilder<BoardDTO>(
        future: fetchBoardDetail(boardIdx),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('게시글을 찾을 수 없습니다.'));
          }

          final board = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(board.boardTitle,
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('작성자: ${board.writerName}'),
                SizedBox(height: 8),
                Text('작성 날짜: ${board.postDate.toLocal()}'), // 로컬 시간으로 변환
                SizedBox(height: 16),
                Text(board.contents),
                SizedBox(height: 16),
                // 이미지 표시
                ...board.images
                    .map((image) => Image.network(image.imageUrl))
                    .toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
