import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_popcon_flutter/screens/popup_board_list.dart';
import 'package:project_popcon_flutter/widgets/custom_drawer.dart';

class PopupBoardView extends StatefulWidget {
  const PopupBoardView({super.key});

  @override
  State<PopupBoardView> createState() => _PopupBoardViewState();
}

class _PopupBoardViewState extends State<PopupBoardView> {
  late GoogleMapController _mapController;
  LatLng _location = LatLng(37.5705, 126.9981); // 예시: 서울 종로구
  late BitmapDescriptor customMarker;
  bool _isMarkerInitialized = false; // 마커 초기화 상태

  @override
  void initState() {
    super.initState();
    setCustomMarker();
  }

  Future<void> setCustomMarker() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/marker4.png', // 사용자 정의 마커 이미지 경로
    );
    setState(() {
      _isMarkerInitialized = true; // 초기화 완료 후 상태 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF121212),
        title: Image.asset(
          'assets/images/logo.png',
          height: 30,
        ),
      ),
      endDrawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFF121212),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/popup_image4.jfif'),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '벨리곰',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '벨리곰 주거 고민 체험 해결',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          "assets/images/location_icon.svg",
                          width: 14,
                          height: 14,
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          '서울 종로구',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    Text(
                      '운영시간',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        '11:00 - 17:00',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      '팝업스토어 소개',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      color: Color(0xFF2c2c2c),
                      padding: const EdgeInsets.all(8.0),
                      constraints: BoxConstraints(
                        minWidth: 450,
                      ),
                      child: const Text(
                        '\n안녕하세요 벨리곰이에용.\n하이하이123\n',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      '안내 및 주의사항',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 20.0),
                    // 지도와 주소 추가
                    _isMarkerInitialized
                        ? Container(
                            height: 300,
                            child: GoogleMap(
                              onMapCreated: (GoogleMapController controller) {
                                _mapController = controller;
                              },
                              initialCameraPosition: CameraPosition(
                                target: _location,
                                zoom: 14,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId('popupMarker'),
                                  position: _location,
                                  icon: customMarker,
                                  infoWindow: InfoWindow(
                                    title: '벨리곰',
                                    snippet: '서울 종로구',
                                  ),
                                ),
                              },
                            ),
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          ), // 로딩 표시
                    Container(
                      color: Color(0xFF2c2c2c),
                      padding: const EdgeInsets.all(8.0),
                      constraints: BoxConstraints(
                        minWidth: 450,
                      ),
                      child: Text(
                        '서울특별시 종로구',
                        style: TextStyle(fontSize: 13.0, color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PopupBoardList(),
                            ),
                          ),
                        },
                        child: const Text("목록"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '후기',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      color: Color(0xFF2c2c2c),
                      padding: const EdgeInsets.all(8.0),
                      constraints: BoxConstraints(
                        minWidth: 450,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                // 'assets/images/profile.svg',
                                'assets/images/profile_temp.svg',
                                height: 24.0,
                              ),
                              const Text(
                                '머스트해브(작성자)',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          const Text(
                            '안녕하세요. 댓글입니다.\n좋네요.(댓글내용)',
                            style:
                                TextStyle(fontSize: 13.0, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
