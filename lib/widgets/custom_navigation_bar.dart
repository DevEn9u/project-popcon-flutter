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
import 'package:timezone/data/latest_all.dart';
import '../screens/mainPage.dart';
import 'package:project_popcon_flutter/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // Clipboard 사용을 위해 추가
import 'package:timezone/data/latest_all.dart' as tz; // 타임존 데이터 초기화용
import 'package:timezone/timezone.dart' as tz; // 타임존 사용
import 'package:android_intent_plus/android_intent.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Set<int> _notifiedBookingNums = {}; // 알림을 보낸 예약 번호 저장

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 좋아요한 팝업 목록을 저장할 변수
  List<PopupboardDTO>? likedPopups;
  // 예약된 팝업 목록을 저장할 변수
  List<BookingDTO>? bookings;
  bool isFetchingData = false;
  Timer? _bookingTimer; // 타이머 상태 변수 추가

  @override
  void initState() {
    super.initState();
    initializeTimeZones(); // 타임존 초기화
    initializeNotifications(); // 알림 초기화
    requestNotificationPermission(); // 알림 권한 요청
    checkLoginStatus(); // 로그인 상태 확인
    fetchBookingsPeriodically(); // 주기적인 예약 확인 시작
  }

  // 타임존 초기화 메서드
  void initializeTimeZones() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul')); // 한국 시간대 설정
  }

  // 알림 초기화 메서드
  void initializeNotifications() async {
    // Awesome Notifications 초기화
    AwesomeNotifications().initialize(
      null, // 아이콘을 지정하려면 'resource://drawable/res_app_icon' 형식으로 설정
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: '기본 채널',
          channelDescription: '기본 알림 채널',
          defaultColor: Colors.teal,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
      debug: true,
    );

    // 알림 응답 리스너 설정 (필요 시)
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  // 알림 응답 리스너 (필요 시)
  Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // 알림 클릭 시 동작 구현
    String? payload = receivedAction.payload?['bookingNum'];
    if (payload != null) {
      int bookingNum = int.parse(payload);
      // 예약 상세 페이지로 이동하는 로직 추가 가능
      // 예: Navigator.pushNamed(context, '/detail', arguments: bookingNum);
    }
  }

  Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}
  Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}
  Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  // 알림 권한 요청 메서드
  void requestNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // 사용자에게 권한 요청
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // 정확한 알람 권한 확인
    if (Platform.isAndroid && await isExactAlarmAllowed() == false) {
      // 사용자에게 정확한 알람 권한 요청 안내
      await showExactAlarmPermissionDialog();
    }
  }

  // 정확한 알람 권한 확인 메서드
  Future<bool> isExactAlarmAllowed() async {
    if (Platform.isAndroid) {
      // Android 12(API 31) 이상에서만 필요
      if (await Permission.scheduleExactAlarm.isGranted) {
        return true;
      } else {
        return false;
      }
    }
    return true; // iOS나 기타 플랫폼에서는 true 반환
  }

  // 정확한 알람 권한 요청 다이얼로그 표시 메서드
  Future<void> showExactAlarmPermissionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('정확한 알람 권한이 필요합니다'),
          content:
              Text('정확한 알람을 사용하려면 권한을 허용해야 합니다. 설정 페이지로 이동하여 권한을 허용해 주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                openExactAlarmSettings(); // 설정 페이지로 이동
              },
              child: Text('설정으로 이동'),
            ),
          ],
        );
      },
    );
  }

  // 정확한 알람 권한 설정 페이지로 이동하는 메서드
  void openExactAlarmSettings() async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _bookingTimer?.cancel(); // 타이머 취소
    super.dispose();
  }

// Jwt로그인
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
      print('로그인 성공: $data');
      setState(() {
        memberData = data['user'];
      });

      // 로그인 성공 후 토큰과 사용자 정보를 SharedPreferences에 저장
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwtToken', data['token']);
      await prefs.setString('userName', data['user']['name']);

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

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');
    String? userName = prefs.getString('userName');

    if (token != null && userName != null) {
      setState(() {
        memberData = {'name': userName};
      });
      // 필요 시 좋아요한 팝업 목록과 예약된 팝업 목록을 가져옵니다.
      await fetchLikedPopups();
      await fetchBookings();
    }
  }

  // 로그아웃 기능
  void performLogout() async {
    await apiService.logout(); // JWT 토큰 삭제
    await AwesomeNotifications().cancelAll();

    // SharedPreferences 초기화
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');
    await prefs.remove('userName');

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
    await AwesomeNotifications().cancelAll();

    for (var booking in bookings) {
      if (booking.visitDate != null && booking.isCanceled == 0) {
        scheduleNotification(booking);
      }
    }
  }

// 예약된 팝업 목록을 주기적으로 확인하여 새로운 예약이 있는지 확인하는 메서드
  void fetchBookingsPeriodically() {
    // 5초마다 예약 확인
    Timer.periodic(Duration(seconds: 5), (timer) async {
      await checkForNewBookings();
    });
  }

// 새로운 예약이 있는지 확인하는 메서드
  Future<void> checkForNewBookings() async {
    setState(() {
      isFetchingData = true;
    });

    try {
      List<BookingDTO> currentBookings = await apiService.getMyBookings();

      // 기존 예약 번호 리스트 생성
      List<int> existingBookingNums =
          bookings?.map((b) => b.bookingNum).toList() ?? [];

      // 새로운 예약 필터링
      List<BookingDTO> newBookings = currentBookings
          .where((b) => !existingBookingNums.contains(b.bookingNum))
          .toList();

      if (newBookings.isNotEmpty) {
        for (var newBooking in newBookings) {
          if (!_notifiedBookingNums.contains(newBooking.bookingNum)) {
            await sendNotificationForNewBooking(newBooking);
            _notifiedBookingNums.add(newBooking.bookingNum); // 알림을 보낸 예약 번호 추가
          }
        }
      }

      // 예약 목록을 업데이트
      setState(() {
        bookings = currentBookings;
      });
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

// 새로 추가된 예약에 대해 5초 뒤 알림을 보내는 메서드
  Future<void> sendNotificationForNewBooking(BookingDTO booking) async {
    print('새로 추가된 예약에 대해 5초 뒤 알림을 스케줄링합니다: ${booking.popupTitle}');

    // 5초 뒤 알림을 스케줄링
    Future.delayed(Duration(seconds: 5), () async {
      print('5초 후 알림 스케줄링 시작');
      // 예약 정보에 따라 알림을 스케줄링
      await sendReservationNotification(booking);
    });
  }

// 새로 추가된 예약에 대한 알림을 즉시 보내는 메서드
  Future<void> sendReservationNotification(BookingDTO booking) async {
    try {
      print('알림 생성 시작: ${booking.popupTitle}');
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: booking.bookingNum, // 알림 ID는 예약 번호로 사용 (고유해야 함)
          channelKey: 'basic_channel',
          title: '예약 완료', // 알림 제목
          body: '"${booking.popupTitle}"을(를) 예약하였습니다.', // 알림 내용
          notificationLayout: NotificationLayout.Default,
          payload: {'bookingNum': booking.bookingNum.toString()},
        ),
      );
      print('예약 알림이 전송되었습니다: ${booking.popupTitle}');
    } catch (e) {
      print('예약 알림 전송 중 오류 발생: $e');
    }
  }

// 개별 예약에 대한 알림 스케줄링
  Future<void> scheduleNotification(BookingDTO booking) async {
    // 방문 날짜 전날 오후 6시에 알림
    DateTime scheduledDate =
        booking.visitDate!.subtract(Duration(minutes: 360));

    // 현재 시간보다 이전이면 스케줄링하지 않음
    DateTime now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      print('scheduledDate가 현재 시간보다 이전입니다.');
      print('현재 시간: $now');
      print('scheduledDate: $scheduledDate');
      return;
    }

    // 알림 ID는 예약 번호로 사용 (고유해야 함)
    int notificationId = booking.bookingNum;

    // 알림 스케줄링
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'basic_channel',
          title: '팝업 예약 완료', // 알림 제목
          body: '"${booking.popupTitle}"을(를) 예약하였습니다.', // 알림 내용
          notificationLayout: NotificationLayout.Default,
          payload: {'bookingNum': booking.bookingNum.toString()},
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduledDate,
          preciseAlarm: true, // 정확한 알람 설정 (권한 필요)
        ),
      );

      print('알림이 스케줄링되었습니다. 시간: $scheduledDate');
    } catch (e) {
      print('알림 스케줄링 중 오류 발생: $e');
      if (e is PlatformException && e.code == 'exact_alarms_not_permitted') {
        // 정확한 알람 권한이 없을 경우 사용자에게 권한 요청 안내
        await showExactAlarmPermissionDialog();
      } else {
        setState(() {
          errorMessage = '알림 스케줄링 중 오류가 발생했습니다: $e';
        });
      }
    }
  }

  //테스트 알림 스케줄링 메서드
  Future<void> sendTestNotification() async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 100, // 고유 ID
          channelKey: 'basic_channel',
          title: '테스트 알림',
          body: '이것은 테스트 알림입니다.',
          notificationLayout: NotificationLayout.Default,
          payload: {'test': 'test_payload'},
        ),
      );

      print('테스트 알림이 전송되었습니다.');
      setState(() {
        errorMessage = '테스트 알림이 전송되었습니다.';
      });
    } catch (e) {
      print('테스트 알림 전송 중 오류 발생: $e');
      setState(() {
        errorMessage = '테스트 알림 전송 중 오류가 발생했습니다: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            SizedBox(height: 20),
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

  // 데이터 새로고침 메서드
  Future<void> refreshData() async {
    await fetchLikedPopups();
    await fetchBookings();
  }
}
