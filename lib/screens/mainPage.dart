import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:project_popcon_flutter/screens/free_board_list.dart';
import 'package:project_popcon_flutter/widgets/custom_drawer.dart';
import 'package:project_popcon_flutter/widgets/custom_navigation_bar.dart';
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

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Drawer 아이콘의 색상 변경
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
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          color: Color(0xFF121212),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // 위쪽에 정렬
            children: [
              const Divider(color: Colors.grey),
              // 슬라이더 이미지

              CarouselSlider(
                options: CarouselOptions(height: 400.0),
                items: [1, 2, 3, 4, 5].map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(color: Colors.amber),
                        child: Text(
                          'text $i',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              ////////////////////////////////////////////////
              SizedBox(height: 20), // 버튼과 슬라이더 사이에 여백 추가
              ElevatedButton(
                onPressed: () {
                  // 버튼 클릭 시 게시판 페이지로 이동
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
              // Card(
              //   color: Color(0xFF121212), // Card 배경색
              //   elevation: 0, // Card 아래쪽 그림자 제거
              //   margin: EdgeInsets.symmetric(vertical: 16.0), // 상하 여백 조정

              //   child: Container(
              //     height: 150, // 고정된 높이 설정
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         ClipRRect(
              //           borderRadius: BorderRadius.circular(14.0),
              //           child: Image.asset(
              //             'assets/images/popup_image1.jfif',
              //             width: 142,
              //             height: 142,
              //           ),
              //         ),
              //         const SizedBox(width: 16), // 이미지와 텍스트 사이의 간격
              //         Expanded(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.end,
              //             children: [
              //               const Text(
              //                 '쿼카 앤 보보 인 더 우드 팝업스토어',
              //                 style: TextStyle(
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold,
              //                   color: Colors.white,
              //                 ),
              //               ),
              //               Row(
              //                 // 아이콘과 텍스트를 수평으로 배치
              //                 crossAxisAlignment: CrossAxisAlignment.end,
              //                 children: [
              //                   SvgPicture.asset(
              //                     "assets/images/location_icon.svg",
              //                     width: 14,
              //                     height: 14,
              //                   ), // 아이콘 추가
              //                   const SizedBox(width: 2),
              //                   const Text(
              //                     '서울특별시 영등포구',
              //                     style: TextStyle(
              //                         fontSize: 12, color: Colors.grey),
              //                   ),
              //                 ],
              //               ),
              //               const Spacer(), // 빈 공간 추가
              //               const Row(
              //                 mainAxisAlignment: MainAxisAlignment.end,
              //                 children: [
              //                   Text(
              //                     '24.10.24 - 24.11.06',
              //                     style: TextStyle(
              //                       color: Colors.white,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // const Divider(
              //   color: Colors.grey,
              // ),
              // Card(
              //   color: Color(0xFF121212), // Card 배경색
              //   elevation: 0, // Card 아래쪽 그림자 제거
              //   margin: EdgeInsets.symmetric(vertical: 16.0), // 상하 여백 조정

              //   child: Container(
              //     height: 150, // 고정된 높이 설정
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         ClipRRect(
              //           borderRadius: BorderRadius.circular(14.0),
              //           child: Image.asset(
              //             'assets/images/popup_image4.jfif',
              //             width: 142,
              //             height: 142,
              //           ),
              //         ),
              //         const SizedBox(width: 16), // 이미지와 텍스트 사이의 간격
              //         Expanded(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.end,
              //             children: [
              //               const Text(
              //                 '벨리곰 X LH <LH 곰in중개사> 팝업스토어',
              //                 style: TextStyle(
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold,
              //                   color: Colors.white,
              //                 ),
              //               ),
              //               Row(
              //                 // 아이콘과 텍스트를 수평으로 배치
              //                 crossAxisAlignment: CrossAxisAlignment.end,
              //                 children: [
              //                   SvgPicture.asset(
              //                     "assets/images/location_icon.svg",
              //                     width: 14,
              //                     height: 14,
              //                   ), // 아이콘 추가
              //                   const SizedBox(width: 2),
              //                   const Text(
              //                     '서울특별시 영등포구',
              //                     style: TextStyle(
              //                         fontSize: 12, color: Colors.grey),
              //                   ),
              //                 ],
              //               ),
              //               const Spacer(), // 빈 공간 추가
              //               const Row(
              //                 mainAxisAlignment: MainAxisAlignment.end,
              //                 children: [
              //                   Text(
              //                     '24.10.24 - 24.11.06',
              //                     style: TextStyle(
              //                       color: Colors.white,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // const Divider(
              //   color: Colors.grey,
              // ),
              // 추가 카드가 필요한 경우 계속 추가
            ],
          ),
        ),
      ),
    );
  }
}
