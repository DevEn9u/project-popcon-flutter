import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:project_popcon_flutter/models/booking_dto.dart';
import 'package:project_popcon_flutter/models/popupboard_dto.dart';
import 'package:project_popcon_flutter/screens/free_board_list.dart';
import 'package:project_popcon_flutter/screens/popup_board_list.dart';
import 'package:project_popcon_flutter/widgets/booking_list_widget.dart';
import 'package:project_popcon_flutter/widgets/liked_popup_widget.dart';
import 'package:project_popcon_flutter/widgets/popup_board_widget.dart';
import 'package:provider/provider.dart';
import '../screens/mainPage.dart';
import 'package:project_popcon_flutter/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // Clipboard 사용을 위해 추가
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // 알림 패키지 추가
import 'package:timezone/data/latest_all.dart' as tz; // 타임존 데이터 초기화용
import 'package:timezone/timezone.dart' as tz; // 타임존 사용

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
  LatLng _myLoc = const LatLng(37.5702, 126.9830); // 초기 위치 (종각역)
  List<Marker> _markers = [];
  late Future<List<PopupboardDTO>> _popupListFuture;

  // 사용자 정의 마커 세팅
  late BitmapDescriptor customMarker;
  late BitmapDescriptor customMarker2;

  @override
  void initState() {
    super.initState();
    // 초기화 - fetchPopupListAndAddMarkers 함수 호출 전
    _popupListFuture = fetchPopupListAndAddMarkers();
    setCustomMarker().then((_) {
      getCurrentLocation(); // 위치 가져오기
    });
    setCustomMarker2().then((_) {
      getCurrentLocation(); // 위치 가져오기
    });
  }

  // 사용자 정의 마커 이미지 설정
  Future<void> setCustomMarker() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/marker2.png',
    );
  }

  Future<void> setCustomMarker2() async {
    customMarker2 = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/popup_marker.png',
    );
  }

  // 현재 위치 가져오기 및 위치 변경 시 호출
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

    // 현재 위치를 사용자의 위치로 설정
    _myLoc = LatLng(position.latitude, position.longitude);

    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _myLoc, zoom: 17)));

    markerAdd(); // 현재 위치에 마커 추가

    setState(() {
      _popupListFuture = fetchPopupListAndAddMarkers(); // 팝업 리스트 다시 가져오기
    });
  }

  // 주소를 위도, 경도로 변환하는 함수
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print('Error converting address to coordinates: $e');
    }
    return null;
  }

  // 팝업 리스트를 가져오고 각 팝업의 주소를 위도, 경도로 변환 후 마커 추가
  Future<List<PopupboardDTO>> fetchPopupListAndAddMarkers() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    List<PopupboardDTO> popupList = await apiService.getPopupBoardList();

    for (var popup in popupList) {
      LatLng? coordinates =
          await getCoordinatesFromAddress(popup.popupAddr); // popupAddr 사용
      if (coordinates != null) {
        addMarker(coordinates, popup);
      }
    }
    return popupList; // FutureBuilder에서 사용할 수 있도록 반환
  }

  // 팝업에 대한 마커를 지도에 추가하는 함수
  void addMarker(LatLng position, PopupboardDTO popup) {
    final marker = Marker(
      markerId: MarkerId(popup.boardIdx.toString()), // 고유한 markerId 설정
      position: position,
      icon: customMarker2, // customMarker 이미지를 사용
      infoWindow: InfoWindow(title: popup.boardTitle), // 팝업 정보 표시
    );

    setState(() {
      _markers.add(marker); // 마커 리스트에 추가
    });
  }

  // 현재 위치에 마커를 추가하는 함수
  void markerAdd() {
    final marker = Marker(
      markerId: const MarkerId('marker'),
      position: _myLoc,
      icon: customMarker,
    );

    setState(() {
      _markers.clear(); // 기존 마커 제거
      _markers.add(marker); // 현재 위치 마커 추가
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
        child: Column(
          children: [
            Container(
              color: const Color(0xFF121212),
              height: 400,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 4,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: Set.from(_markers), // 마커들
              ),
            ),
            // PopupBoardWidget 추가 (FutureBuilder 사용)
            FutureBuilder<List<PopupboardDTO>>(
              future: _popupListFuture, // 초기화된 Future 사용
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
  List<PopupboardDTO>? likedPopups;
  // 예약된 팝업 목록을 저장할 변수
  List<BookingDTO>? bookings;
  bool isFetchingData = false;

  // FlutterLocalNotificationsPlugin 인스턴스 생성
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeTimeZones(); // 타임존 초기화
    initializeNotifications(); // 알림 초기화
    requestNotificationPermission(); // 알림 권한 요청
  }

  // 알림 권한 요청 메서드
  void requestNotificationPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.notification.request();
      if (status.isGranted) {
        // 권한이 허용됨
        print('알림 권한이 허용되었습니다.');
      } else {
        // 권한이 거부됨
        print('알림 권한이 거부되었습니다.');
      }
    }
  }

  // 타임존 초기화 메서드
  void initializeTimeZones() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul')); // 한국 시간대 설정
  }

  // 알림 초기화 메서드
  void initializeNotifications() async {
    // Android 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 전체 초기화 설정
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // 초기화
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  // 알림 선택 시 호출되는 콜백
  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null && payload.isNotEmpty) {
      int bookingNum = int.parse(payload);
      // 예약 상세 페이지로 이동하는 로직 추가 가능
    }
  }

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
      likedPopups = null;
      bookings = null;
    });

    try {
      Map<String, dynamic> data = await apiService.jwtLogin(id, password);
      print('로그인 성공: $data'); // 로그인 성공 시 데이터 출력
      setState(() {
        memberData = data['user'];
      });
      // 로그인 성공 시 좋아요한 팝업 목록과 예약된 팝업 목록을 가져옵니다.
      await fetchLikedPopups();
      await fetchBookings();
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
    // 모든 스케줄된 알림 취소
    await flutterLocalNotificationsPlugin.cancelAll();
    setState(() {
      memberData = null;
      likedPopups = null;
      bookings = null;
      _idController.clear();
      _passwordController.clear();
      errorMessage = null;
    });
  }

  // 좋아요한 팝업 목록을 가져오는 메서드
  Future<void> fetchLikedPopups() async {
    setState(() {
      isFetchingData = true;
    });
    try {
      List<PopupboardDTO> data = await apiService.getLikedPopups();
      setState(() {
        likedPopups = data;
      });
    } catch (e) {
      setState(() {
        errorMessage =
            '좋아요한 팝업을 가져오는 데 실패했습니다: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      setState(() {
        isFetchingData = false;
      });
    }
  }

  // 예약된 팝업 목록을 가져오는 메서드
  Future<void> fetchBookings() async {
    setState(() {
      isFetchingData = true;
    });
    try {
      List<BookingDTO> data = await apiService.getMyBookings();
      setState(() {
        bookings = data;
      });
      // 예약된 알림 스케줄링
      scheduleNotificationsForBookings(data);
    } catch (e) {
      setState(() {
        errorMessage =
            '예약된 팝업을 가져오는 데 실패했습니다: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      setState(() {
        isFetchingData = false;
      });
    }
  }

  // 예약 정보에 따른 알림 스케줄링
  void scheduleNotificationsForBookings(List<BookingDTO> bookings) async {
    // 기존 알림 모두 취소
    await flutterLocalNotificationsPlugin.cancelAll();

    for (var booking in bookings) {
      if (booking.visitDate != null && booking.isCanceled == 0) {
        scheduleNotification(booking);
      }
    }
  }

  // 개별 예약에 대한 알림 스케줄링
  Future<void> scheduleNotification(BookingDTO booking) async {
    // 방문 날짜 전날 오후 6시에 알림을 보내도록 설정 (예시)
    final DateTime scheduledDate =
        booking.visitDate!.subtract(Duration(minutes: 520));

    // 현재 시간보다 이전이면 스케줄링하지 않음
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    // 알림 ID는 예약 번호로 사용 (고유해야 함)
    int notificationId = booking.bookingNum;

    // 알림 상세 설정
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'booking_reminder_channel', // 채널 ID
      '예약 알림', // 채널 이름
      channelDescription: '팝업 방문 예약 알림', // 채널 설명
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    // 알림 스케줄링
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      '팝업 방문 예약 알림',
      '${booking.popupTitle} 팝업 방문 날짜입니다.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: booking.bookingNum.toString(), // 알림 클릭 시 전달할 데이터
    );
  }

  // 전체 데이터 새로고침
  Future<void> refreshData() async {
    await fetchLikedPopups();
    await fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    // 로그인 상태에 따라 다른 화면을 표시합니다.
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E), // 배경색 설정
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: memberData == null
            ? Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 로고 이미지 추가
                      Image.asset(
                        'assets/images/logo.png',
                        height: 80,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'POPCON 로그인하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 40),
                      // 아이디 입력 필드
                      TextField(
                        controller: _idController,
                        decoration: InputDecoration(
                          hintText: '아이디를 입력하세요',
                          hintStyle: TextStyle(color: Colors.grey),
                          fillColor: Colors.black,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      // 비밀번호 입력 필드
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: '비밀번호를 입력하세요',
                          hintStyle: TextStyle(color: Colors.grey),
                          fillColor: Colors.black,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 24),
                      // 로그인 버튼
                      ElevatedButton(
                        onPressed: isLoading ? null : performJwtLogin,
                        child: isLoading
                            ? CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                '로그인',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF0D9B5),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
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
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 마이페이지: 환영 메시지 표시
                  SizedBox(height: 40),
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
                  // 예약된 팝업 목록과 좋아요한 팝업 목록 표시
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: refreshData,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // 예약된 팝업 목록 표시
                            bookings == null
                                ? Center(child: CircularProgressIndicator())
                                : bookings!.isEmpty
                                    ? Center(
                                        child: Text(
                                          '예약된 팝업이 없습니다.',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    : BookingListWidget(bookings: bookings!),
                            SizedBox(height: 20),
                            // 좋아요한 팝업 목록 표시
                            likedPopups == null
                                ? Center(child: CircularProgressIndicator())
                                : likedPopups!.isEmpty
                                    ? Center(
                                        child: Text(
                                          '좋아요한 팝업이 없습니다.',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    : LikedPopupWidget(popups: likedPopups!),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  // 로그아웃 버튼
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0), // 아래쪽 마진 추가
                    child: ElevatedButton(
                      onPressed: performLogout,
                      child: Text(
                        '로그아웃',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF0D9B5),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
