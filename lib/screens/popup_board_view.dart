// lib/screens/popup_board_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_popcon_flutter/widgets/custom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:project_popcon_flutter/services/api_service.dart';
import '../models/popupboard_dto.dart';
import 'popup_board_list.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 이미지 로딩을 위한 패키지

class PopupBoardView extends StatefulWidget {
  final String boardIdx;

  const PopupBoardView({Key? key, required this.boardIdx}) : super(key: key);

  @override
  State<PopupBoardView> createState() => _PopupBoardViewState();
}

class _PopupBoardViewState extends State<PopupBoardView> {
  late Future<PopupboardDTO> _popupFuture;

  late GoogleMapController _mapController;
  LatLng _location = LatLng(37.5705, 126.9981); // 기본 위치: 서울 종로구
  late BitmapDescriptor customMarker;
  bool _isMarkerInitialized = false; // 마커 초기화 상태

  @override
  void initState() {
    super.initState();
    _popupFuture = fetchPopupBoardDetail();
    setCustomMarker();
  }

  Future<PopupboardDTO> fetchPopupBoardDetail() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return await apiService.getPopupBoardDetail(widget.boardIdx);
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
    final apiService = Provider.of<ApiService>(context, listen: false);
    final String baseUrl = apiService.baseUrl;

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
      body: FutureBuilder<PopupboardDTO>(
        future: _popupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 로딩 상태
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // 오류 상태
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            // 데이터 없음
            return Center(child: Text('게시글을 찾을 수 없습니다.'));
          } else {
            // 성공적으로 데이터 로드
            PopupboardDTO popup = snapshot.data!;

            // 위치 정보를 백엔드에서 제공받을 수 있다면, 해당 정보를 사용하여 _location을 업데이트
            // 예시:
            // _location = LatLng(popup.latitude, popup.longitude);

            return SingleChildScrollView(
              child: Container(
                color: Color(0xFF121212),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 게시글 썸네일
                    popup.thumb != null && popup.thumb!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: '$baseUrl${popup.thumb}',
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.broken_image, size: 50),
                          )
                        : Image.asset(
                            'assets/images/logo.png',
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            popup.writerName,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            popup.boardTitle,
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
                              Text(
                                popup.popupAddr,
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
                              '${popup.startDate} - ${popup.endDate}',
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
                            child: Text(
                              '${popup.contents}',
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
                                    onMapCreated:
                                        (GoogleMapController controller) {
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
                                          title: popup.boardTitle,
                                          snippet: popup.popupAddr,
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
                              popup.popupAddr,
                              style: TextStyle(
                                  fontSize: 13.0, color: Colors.white),
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
                                    builder: (context) =>
                                        const PopupBoardList(),
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
                          SizedBox(
                            height: 20.0,
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
                          // 댓글 섹션
                          popup.comments.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: popup.comments.map((comment) {
                                    return Container(
                                      color: Color(0xFF2c2c2c),
                                      padding: const EdgeInsets.all(8.0),
                                      constraints: BoxConstraints(
                                        minWidth: 450,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/images/profile.jpg',
                                                height: 24.0,
                                              ),
                                              SizedBox(width: 8.0),
                                              Text(
                                                comment.comWriterName,
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15.0,
                                          ),
                                          // 댓글 이미지 (있을 경우)
                                          comment.comImg.isNotEmpty
                                              ? Column(
                                                  children: comment.comImg
                                                      .map((image) {
                                                    return Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 4.0),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            '$baseUrl${image.imageUrl}',
                                                        width: double.infinity,
                                                        height: 150,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context,
                                                                url) =>
                                                            Center(
                                                                child:
                                                                    CircularProgressIndicator()),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(
                                                                Icons
                                                                    .broken_image,
                                                                size: 50),
                                                      ),
                                                    );
                                                  }).toList(),
                                                )
                                              : SizedBox(),
                                          SizedBox(
                                            height: 4.0,
                                          ),
                                          Text(
                                            comment.comContents,
                                            style: TextStyle(
                                                fontSize: 13.0,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Text(
                                  '댓글이 없습니다.',
                                  style: TextStyle(color: Colors.white),
                                ),
                          SizedBox(
                            height: 20.0,
                          ),
                          // 댓글 작성 기능은 생략 (추후 구현 가능)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
