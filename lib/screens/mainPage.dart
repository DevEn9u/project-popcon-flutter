// lib/screens/mainPage.dart

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:project_popcon_flutter/screens/free_board_list.dart';
import 'package:project_popcon_flutter/widgets/custom_navigation_bar.dart';
import 'package:provider/provider.dart'; // Provider 패키지 추가
import 'package:project_popcon_flutter/services/api_service.dart';
import 'package:project_popcon_flutter/models/popupboard_dto.dart';
import 'package:project_popcon_flutter/widgets/main_slider_widget.dart';
import 'package:project_popcon_flutter/widgets/custom_drawer.dart';
import 'package:project_popcon_flutter/widgets/popup_board_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomNavigationBar(controller: _controller),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<List<PopupboardDTO>> _popupListFuture;

  @override
  void initState() {
    super.initState();
    _popupListFuture = fetchPopupList(); // 팝업 리스트를 가져오는 Future
  }

  // 팝업 리스트를 가져오는 메서드
  Future<List<PopupboardDTO>> fetchPopupList() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return await apiService.getPopupBoardList(); // API에서 팝업 리스트 가져오기
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
    final apiService = Provider.of<ApiService>(context, listen: false);
    final String baseUrl = apiService.baseUrl; // API 베이스 URL

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF121212),
        title: Image.asset('assets/images/logo.png', height: 30),
      ),
      endDrawer: const CustomDrawer(),
      // RefreshIndicator로 SingleChildScrollView 감싸기
      body: RefreshIndicator(
        onRefresh: _refreshPopupList, // 새로고침 시 호출되는 메서드
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(), // 항상 스크롤 가능하게 설정
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            color: Color(0xFF121212),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Divider(color: Colors.grey),

                // FutureBuilder를 사용해 API에서 데이터를 불러오고 MainSliderWidget에 전달
                FutureBuilder<List<PopupboardDTO>>(
                  future: _popupListFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator()); // 로딩 중
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}')); // 오류 발생 시
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('No images available')); // 데이터 없음
                    } else {
                      List<PopupboardDTO> popupList = snapshot.data!;
                      return Column(
                        children: [
                          MainSliderWidget(
                            thumb: popupList,
                            baseUrl: baseUrl,
                          ),
                          SizedBox(height: 20),
                          // 팝업 모음
                          Container(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                children: const [
                                  TextSpan(
                                    text: "담당자 픽 서울 인기 팝업",
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
