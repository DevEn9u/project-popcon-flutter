import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'mainPage.dart';
import 'package:project_popcon_flutter/services/api_service.dart';

class CustomNavigationBar extends StatelessWidget {
  final PersistentTabController controller;

  const CustomNavigationBar({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: Color(0xFF121212),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      decoration: NavBarDecoration(
        colorBehindNavBar: Color(0xFF121212),
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.0),
        ),
      ),
      navBarStyle: NavBarStyle.style3,
    );
  }

  List<Widget> _buildScreens() {
    return const [
      HomeTab(),
      PopupBoardTab(),
      NearPopupTab(),
      FreeBoardTab(),
      LoginTab(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      _buildNavBarItem(Icons.home, "홈"),
      _buildNavBarItem(Icons.my_library_books, "팝업발견"),
      _buildNavBarItem(Icons.location_on_rounded, "내주변 팝업",
          activeColor: const Color(0xFFf0002e)),
      _buildNavBarItem(Icons.forum, "자유게시판"),
      _buildNavBarItem(Icons.person, "로그인"),
    ];
  }

  PersistentBottomNavBarItem _buildNavBarItem(IconData icon, String title,
      {Color? activeColor}) {
    return PersistentBottomNavBarItem(
      icon: Icon(icon),
      title: title,
      activeColorPrimary: activeColor ?? const Color(0xFFfce8c3),
      inactiveColorPrimary: Colors.grey,
    );
  }
}

// HomeTab 제외 나머지 Tab
class PopupBoardTab extends StatelessWidget {
  const PopupBoardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF121212),
        title: const Text("팝업게시판"),
      ),
      body: Container(
        color: Color(0xFF121212),
        child: Center(
            child: Text('팝업게시판 화면', style: TextStyle(color: Colors.white))),
      ),
    );
  }
}

class FreeBoardTab extends StatelessWidget {
  const FreeBoardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF121212),
        title: const Text("자유게시판"),
      ),
      body: Container(
        color: Color(0xFF121212),
        child: Center(
            child: Text('자유게시판 화면', style: TextStyle(color: Colors.white))),
      ),
    );
  }
}

class NearPopupTab extends StatelessWidget {
  const NearPopupTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        title: const Text("내주변 팝업"),
      ),
      body: Container(
        color: Color(0xFF121212),
        child: Center(
          child: Text(
            '내주변 팝업 화면',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// LoginTab을 StatefulWidget으로 수정하여 API 호출 테스트 구현
class LoginTab extends StatefulWidget {
  const LoginTab({Key? key}) : super(key: key);

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  late ApiService apiService;
  String testResponse = '';
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // 백엔드 서버의 IP 주소를 설정합니다.
    // 에뮬레이터 사용 시, Android는 10.0.2.2, iOS는 localhost 또는 Mac의 IP 주소
    apiService =
        ApiService(baseUrl: 'http://10.0.2.2:8080'); // Android 에뮬레이터 예시
    // 실제 기기에서 테스트할 경우, 서버의 로컬 네트워크 IP 주소를 사용
    // 예: 'http://192.168.1.100:8080'
  }

  Future<void> performTest() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      testResponse = '';
    });

    try {
      String response = await apiService.testConnection();
      setState(() {
        testResponse = response;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF121212),
        title: const Text("로그인/마이페이지"),
      ),
      body: Container(
        color: Color(0xFF121212),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: performTest,
                      child: Text('백엔드 연결 테스트'),
                    ),
                    SizedBox(height: 20),
                    if (testResponse.isNotEmpty)
                      Text(
                        testResponse,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
