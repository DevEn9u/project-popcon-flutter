import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:project_popcon_flutter/widgets/custom_navigation_bar.dart';
import 'package:provider/provider.dart'; // Provider 패키지 추가
import 'package:project_popcon_flutter/services/api_service.dart';
import 'package:project_popcon_flutter/models/popupboard_dto.dart';
import 'package:project_popcon_flutter/widgets/main_slider_widget.dart';
import 'package:project_popcon_flutter/widgets/custom_drawer.dart';
import 'package:project_popcon_flutter/screens/free_board_list.dart';
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
  late Future<List<PopupboardDTO>> _thumbListFuture;

  @override
  void initState() {
    super.initState();
    _thumbListFuture = fetchThumbList(); // 이미지 리스트를 가져오는 Future
  }

  Future<List<PopupboardDTO>> fetchThumbList() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return await apiService.listPopup(); // API에서 이미지 리스트 가져오기
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          color: Color(0xFF121212),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Divider(color: Colors.grey),

              // FutureBuilder를 사용해 API에서 데이터를 불러오고 MainSliderWidget에 전달
              FutureBuilder<List<PopupboardDTO>>(
                future: _thumbListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // 로딩 중
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}')); // 오류 발생 시
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No images available')); // 데이터 없음
                  } else {
                    return MainSliderWidget(
                      thumb: snapshot.data!, // 이미지 리스트 전달
                      baseUrl: baseUrl, // 베이스 URL 전달
                    );
                  }
                },
              ),

              SizedBox(height: 20), // 버튼과 슬라이더 사이에 여백 추가
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FreeBoardList()),
                  );
                },
                child: Text("자유게시판 보기"),
              ),
              ///////////////////////////////////////////////

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
              PopupBoardWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
