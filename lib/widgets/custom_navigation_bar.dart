import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:project_popcon_flutter/models/popupboard_dto.dart';
import 'package:project_popcon_flutter/screens/free_board_list.dart';
import 'package:project_popcon_flutter/screens/popup_board_list.dart';
import 'package:project_popcon_flutter/widgets/liked_popup_widget.dart';
import 'package:project_popcon_flutter/widgets/popup_board_widget.dart';
import 'package:provider/provider.dart';
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
// 자유게시판 탭
class FreeBoardTab extends StatelessWidget {
  const FreeBoardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 페이지 빌드 시 바로 PopupBoardList 페이지로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FreeBoardList(),
        ),
      );
    });

    // 대체 페이지 반환 (실제로 표시되지 않음)
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // 로딩 인디케이터 또는 빈 위젯
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

  // 팝업 리스트를 가져오는 Future
  late Future<List<PopupboardDTO>> _popupListFuture;

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

    // 팝업 리스트를 가져오는 Future를 다시 할당하여 업데이트
    setState(() {
      _popupListFuture = fetchPopupList(); // 위치 변경 시 팝업 리스트 다시 가져오기
    });
  }

  // 사용자 정의 마커 세팅
  late BitmapDescriptor customMarker;
  Future<void> setCustomMarker() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/marker4.png');
  }

  // 팝업 리스트를 가져오는 메서드
  Future<List<PopupboardDTO>> fetchPopupList() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return await apiService.getPopupBoardList(); // 실제 API 호출
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

    _popupListFuture = setCustomMarker().then((_) {
      getCurrentLocation();
      return fetchPopupList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text("내주변팝업", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        // 스크롤 가능하도록 변경
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
            // PopupBoardWidget 추가 (FutureBuilder 사용)
            FutureBuilder<List<PopupboardDTO>>(
              future: _popupListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // 로딩 중
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white),
                  )); // 오류 발생 시
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text(
                    '주변에 팝업이 없습니다.',
                    style: TextStyle(color: Colors.white),
                  )); // 데이터 없음
                } else {
                  List<PopupboardDTO> popupList = snapshot.data!;
                  return PopupBoardWidget(popups: popupList);
                }
              },
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

// LoginTab
class LoginTab extends StatefulWidget {
  const LoginTab({Key? key}) : super(key: key);

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final ApiService apiService = ApiService.instance;
  Map<String, dynamic>? memberData;
  bool isLoading = false;
  String? errorMessage;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 좋아요한 팝업 목록을 저장할 변수
  Future<List<PopupboardDTO>>? _likedPopupsFuture;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> performJwtLogin() async {
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
      _likedPopupsFuture = null;
    });

    try {
      Map<String, dynamic> data = await apiService.jwtLogin(id, password);
      print('로그인 성공: $data'); // 로그인 성공 시 데이터 출력
      setState(() {
        memberData = data['user'];
        // 로그인 성공 시 좋아요한 팝업 목록을 가져옵니다.
        _likedPopupsFuture = apiService.getLikedPopups();
      });
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

  // 로그아웃 기능 추가
  void performLogout() async {
    await apiService.logout(); // JWT 토큰 삭제
    setState(() {
      memberData = null;
      _likedPopupsFuture = null;
      _idController.clear();
      _passwordController.clear();
      errorMessage = null;
    });
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
                      // JWT 로그인 버튼
                      ElevatedButton(
                        onPressed: isLoading ? null : performJwtLogin,
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
                        GestureDetector(
                          onLongPress: () {
                            // 오류 메시지를 클립보드에 복사
                            Clipboard.setData(
                              ClipboardData(text: errorMessage!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('오류 메시지가 복사되었습니다.')),
                            );
                          },
                          child: SelectableText(
                            errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 마이페이지: 환영 메시지 표시
                      Text(
                        "환영합니다, ${memberData!['name']}님!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      // 좋아요한 팝업 목록 표시
                      _likedPopupsFuture == null
                          ? CircularProgressIndicator()
                          : FutureBuilder<List<PopupboardDTO>>(
                              future: _likedPopupsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child:
                                          CircularProgressIndicator()); // 로딩 중
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onLongPress: () {
                                          // 오류 메시지를 클립보드에 복사
                                          Clipboard.setData(
                                            ClipboardData(
                                              text:
                                                  '좋아요한 팝업을 가져오는 데 실패했습니다:\n${snapshot.error}',
                                            ),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('오류 메시지가 복사되었습니다.')),
                                          );
                                        },
                                        child: SelectableText(
                                          '좋아요한 팝업을 가져오는 데 실패했습니다:\n${snapshot.error}',
                                          style: TextStyle(color: Colors.red),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                    child: Text(
                                      '좋아요한 팝업이 없습니다.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                } else {
                                  List<PopupboardDTO> likedPopups =
                                      snapshot.data!;
                                  return LikedPopupWidget(popups: likedPopups);
                                }
                              },
                            ),
                      SizedBox(height: 40),
                      // 로그아웃 버튼
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
