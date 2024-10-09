import 'package:flutter/material.dart';
import 'package:project_popcon_flutter/screens/free_board_view.dart';
import '../models/board_dto.dart';
import '../services/api_service.dart';

class FreeBoardList extends StatefulWidget {
  @override
  _FreeBoardListState createState() => _FreeBoardListState();
}

class _FreeBoardListState extends State<FreeBoardList> {
  late Future<List<BoardDTO>> futureBoards;

  @override
  void initState() {
    super.initState();
    futureBoards = fetchBoards(1); // 첫 페이지 요청
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('자유게시판')),
      body: FutureBuilder<List<BoardDTO>>(
        future: futureBoards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('게시글이 없습니다.'));
          }

          final boards = snapshot.data!;
          return ListView.builder(
            itemCount: boards.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(boards[index].boardTitle),
                subtitle: Text(boards[index].writerName),
                onTap: () {
                  // 상세보기로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FreeBoardView(
                        boardIdx: boards[index].boardIdx,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
