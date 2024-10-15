// lib/screens/popup_board_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_popcon_flutter/widgets/custom_drawer.dart';
import 'package:project_popcon_flutter/widgets/popup_board_widget.dart';
import '../services/api_service.dart';
import '../models/popupboard_dto.dart';

class PopupBoardList extends StatefulWidget {
  const PopupBoardList({Key? key}) : super(key: key);

  @override
  _PopupBoardListState createState() => _PopupBoardListState();
}

class _PopupBoardListState extends State<PopupBoardList> {
  late Future<List<PopupboardDTO>> _popupListFuture;

  @override
  void initState() {
    super.initState();
    _popupListFuture = fetchPopupList();
  }

  // 팝업 리스트를 가져오는 메서드
  Future<List<PopupboardDTO>> fetchPopupList() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return await apiService.getPopupBoardList();
  }

  // 새로고침을 수행하는 메서드
  Future<void> _refreshPopupList() async {
    setState(() {
      _popupListFuture = fetchPopupList();
    });
    await _popupListFuture;
  }

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
      // RefreshIndicator로 SingleChildScrollView 감싸기
      body: RefreshIndicator(
        onRefresh: _refreshPopupList, // 새로고침 시 호출되는 메서드
        child: FutureBuilder<List<PopupboardDTO>>(
          future: _popupListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 로딩 상태
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // 오류 상태
              return Center(child: Text('오류: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // 데이터 없음
              return Center(child: Text('진행중인 팝업이 없습니다.'));
            } else {
              // 성공적으로 데이터 로드
              List<PopupboardDTO> popupList = snapshot.data!;
              return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(), // 항상 스크롤 가능하게 설정
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
                      PopupBoardWidget(popups: popupList),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
