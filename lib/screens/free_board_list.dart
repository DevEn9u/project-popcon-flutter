import 'package:flutter/material.dart';
import '../models/board_dto.dart';
import '../services/api_service.dart';
import 'free_board_view.dart';

class FreeBoardList extends StatefulWidget {
  @override
  _FreeBoardListState createState() => _FreeBoardListState();
}

class _FreeBoardListState extends State<FreeBoardList> {
  late ApiService apiService;
  List<BoardDTO> boards = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  ScrollController _scrollController = ScrollController();
  bool isError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    apiService = ApiService(baseUrl: 'http://10.0.2.2:8080'); // 에뮬레이터용
    fetchBoards();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        fetchBoards();
      }
    });
  }

  Future<void> fetchBoards() async {
    setState(() {
      isLoading = true;
      isError = false;
      errorMessage = '';
    });

    try {
      List<BoardDTO> fetchedBoards =
          await apiService.getFreeBoards(page: currentPage);
      setState(() {
        currentPage++;
        boards.addAll(fetchedBoards);
        if (fetchedBoards.length < 10) {
          hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        isError = true;
        errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글을 불러오는 데 실패했습니다.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refreshBoards() async {
    setState(() {
      boards.clear();
      currentPage = 1;
      hasMore = true;
      isError = false;
      errorMessage = '';
    });
    await fetchBoards();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    // 날짜 포맷을 원하는 대로 수정
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('자유게시판'),
        backgroundColor: Color(0xFF121212),
      ),
      body: RefreshIndicator(
        onRefresh: refreshBoards,
        child: boards.isEmpty
            ? isLoading
                ? Center(child: CircularProgressIndicator())
                : isError
                    ? Center(
                        child: Text('게시글을 불러올 수 없습니다.',
                            style: TextStyle(color: Colors.white)))
                    : Center(
                        child: Text('게시글이 없습니다.',
                            style: TextStyle(color: Colors.white)))
            : ListView.builder(
                controller: _scrollController,
                itemCount: boards.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < boards.length) {
                    BoardDTO board = boards[index];
                    return Card(
                      color: Color(0xFF1e1e1e),
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(
                          board.boardTitle,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${board.writerName} • ${formatDate(board.postDate)} • 조회수: ${board.visitCount}",
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: Colors.white70),
                        onTap: () {
                          // 게시글 클릭 시 boardIdx 로그 출력
                          print('게시글 클릭됨: boardIdx = ${board.boardIdx}');

                          // 상세보기로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FreeBoardView(
                                boardIdx: board.boardIdx,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }
}
