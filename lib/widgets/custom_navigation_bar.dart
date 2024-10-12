import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:project_popcon_flutter/screens/popup_board_list.dart';
import '../screens/mainPage.dart';
import 'package:project_popcon_flutter/services/api_service.dart';
import 'package:http/http.dart' as http;

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

// NearPopupTab을 StatefulWidget으로 변경하여 구글 지도 API 가져오기
class NearPopupTab extends StatefulWidget {
  const NearPopupTab({Key? key}) : super(key: key);

  @override
  State<NearPopupTab> createState() => _NearPopupTabState();
}

class _NearPopupTabState extends State<NearPopupTab> {
  final Completer<GoogleMapController> _controller = Completer();
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );
  LatLng _myLoc = const LatLng(0, 0);
  String lat = '';
  String lon = '';
  List<Marker> _markers = [];
  final Random _random = Random();

  // 현재 위치 가져오기 및 위치 변경시 호출
  void getCurrentLocation() async {
    await Permission.location.request().then((status) {
      if (status == PermissionStatus.granted) {
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) => newPosition(position));
      }
    });
  }

  // 위치 변경 시 호출되는 함수
  void newPosition(Position position) async {
    if (position.accuracy > 25) return;

    lat = '${position.latitude}';
    lon = '${position.longitude}';
    _myLoc = LatLng(position.latitude, position.longitude);

    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _myLoc, zoom: 17)));

    markerAdd(); // 현재 위치에 마커 추가
    // fetchNearbyPopups(); // 주변 팝업 API 호출
  }

  // 사용자 정의 마커 세팅
  late BitmapDescriptor customMarker;
  Future<void> setCustomMarker() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/marker4.png');
  }

  // API를 호출하여 주변 팝업데이터 가져오는 함수

  // Future<void> fetchNearbyPopups() async {
  //   final apiUrl = 'http://localhost:8080/api/popupBoard/list';
  //   try {
  //     final response = await http.get(Uri.parse(apiUrl));
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       List<dynamic> popupList = data['popups'];
  //       _addPopupsToMap(popupList);
  //     } else {
  //       print('팝업스토어 정보를 가져오는데 실패했습니다.');
  //     }
  //   } catch(e) {
  //       print('Error: $e');
  //   }
  // }


  void _addPopupsToMap(List<dynamic> popupList) {
    _markers.clear(); // 기존 마커 제거

    for (var popup in popupList) {
      final marker = Marker(
        markerId: MarkerId(popup['id'].toString()),
        position: LatLng(popup['latitude'], popup['longitude']),
        icon: customMarker, // 사용자 정의 마커
        onTap: () => callSnackBar("${popup['name']}"),
      );

      setState(() {
        _markers.add(marker); // 마커 추가
      });
    }
  }

  @override
  void initState() {
    super.initState();

    setCustomMarker().then((value) {
      getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text("내주변팝업", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF121212),
              height: 400,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 17.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: Set.from(_markers), // 마커들
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 현재 위치에 마커를 추가하는 경우
  void markerAdd() {
    final marker = Marker(
      markerId: const MarkerId('marker'),
      position: _myLoc,
      icon: customMarker,
      onTap: () => callSnackBar("안녕하세요 홍길동님!"),
    );

    setState(() {
      print('666');
      _markers.clear();
      _markers.add(marker);
    });
  }

  callSnackBar(msg) {
    int myRandomCount = _random.nextInt(5);
    print(myRandomCount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          color: Color(0xFF121212),
          height: 60,
          child: Row(
            children: [
              Image.asset(
                'assets/images/marker3.png',
                width: 60,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(msg, style: const TextStyle(color: Colors.black)),
                  Row(
                    children: [
                      IconTheme(
                        data: const IconThemeData(
                          color: Colors.red,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < myRandomCount
                                  ? Icons.star
                                  : Icons.star_border,
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: Colors.yellow[800],
        duration: const Duration(milliseconds: 60000),
        action: SnackBarAction(
            label: 'Undo', textColor: Colors.black, onPressed: () {}),
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
