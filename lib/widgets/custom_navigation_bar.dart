import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:project_popcon_flutter/screens/popup_board_list.dart';
import '../screens/mainPage.dart';
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
      PopupBoardList(),
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
  Map<String, dynamic>? memberData;
  bool isLoading = false;
  String? errorMessage;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  Future<void> performLogin() async {
    String id = _idController.text.trim();
    String password = _passwordController.text.trim();

    if (id.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = '아이디와 비밀번호를 모두 입력해주세요.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      memberData = null;
    });

    try {
      Map<String, dynamic> data = await apiService.login(id, password);
      setState(() {
        memberData = data;
      });
      // 로그인 성공 후, 필요한 추가 작업을 여기에 추가할 수 있습니다.
      // 예: 토큰 저장, 사용자 상태 업데이트 등
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 로그아웃 기능 추가 (옵션)
  void performLogout() {
    setState(() {
      memberData = null;
      _idController.clear();
      _passwordController.clear();
      errorMessage = null;
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("로그인/마이페이지"),
        backgroundColor: Color(0xFF121212),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Color(0xFF121212),
        child: Center(
          child: SingleChildScrollView(
            child: memberData == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 회원 ID 입력 필드
                      TextField(
                        controller: _idController,
                        decoration: InputDecoration(
                          labelText: '회원 ID',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      // 비밀번호 입력 필드
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: '비밀번호',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      // 로그인 버튼
                      ElevatedButton(
                        onPressed: isLoading ? null : performLogin,
                        child: Text('로그인'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFf0002e),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                      ),
                      SizedBox(height: 20),
                      // 로딩 인디케이터
                      if (isLoading) CircularProgressIndicator(),
                      // 오류 메시지 표시
                      if (errorMessage != null)
                        Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "로그인 성공!",
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      // 로그인된 회원 정보 표시
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF1e1e1e),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ID: ${memberData!['id']}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "이름: ${memberData!['name']}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "이메일: ${memberData!['email']}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "전화번호: ${memberData!['phone']}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "권한: ${memberData!['authority']}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "포인트: ${memberData!['point']}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "사업자 번호: ${memberData!['business_number'] ?? 'N/A'}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "활성화 여부: ${memberData!['enabled'] == 1 ? '활성화' : '비활성화'}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // 로그아웃 버튼 (옵션)
                      ElevatedButton(
                        onPressed: performLogout,
                        child: Text('로그아웃'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
