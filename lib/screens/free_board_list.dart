import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_popcon_flutter/widgets/custom_drawer.dart';
import '../services/api_service.dart';
import '../models/board_dto.dart';
import 'free_board_view.dart';

class FreeBoardList extends StatefulWidget {
  const FreeBoardList({Key? key}) : super(key: key);

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
    // Provider를 통해 ApiService를 가져옵니다.
    apiService = Provider.of<ApiService>(context, listen: false);
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
        title: Image.asset(
          'assets/images/logo.png',
          height: 30,
        ),
        backgroundColor: Color(0xFF121212),
      ),
      endDrawer: const CustomDrawer(),
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
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  color: Color(0xFF121212),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: Colors.grey),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            children: const [
                              TextSpan(
                                text: "자유게시판",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: boards.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < boards.length) {
                            BoardDTO board = boards[index];
                            return Card(
                              color: Color(0xFF1e1e1e),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: ListTile(
                                title: Text(
                                  board.boardTitle,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "${board.writerName} • ${formatDate(board.postDate)} • 조회수: ${board.visitCount}",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios,
                                    color: Colors.white70),
                                onTap: () {
                                  // 게시글 클릭 시 boardIdx 로그 출력
                                  print(
                                      '게시글 클릭됨: boardIdx = ${board.boardIdx}');

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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
