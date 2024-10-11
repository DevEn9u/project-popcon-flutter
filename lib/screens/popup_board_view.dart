import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_popcon_flutter/widgets/custom_drawer.dart';

class PopupBoardView extends StatefulWidget {
  const PopupBoardView({super.key});

  @override
  State<PopupBoardView> createState() => _PopupBoardViewState();
}

class _PopupBoardViewState extends State<PopupBoardView> {
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
          color: Color(0xFF121212),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/popup_image4.jfif'),
              const SizedBox(height: 10), // 텍스트와 이미지 간격 조정
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
                    const Divider(
                      color: Colors.grey,
                    ),
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
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      '팝업스토어 소개',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Container(
                      color: Color(0xFF2c2c2c),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '안녕하세요 벨리곰이에용.\n하이하이123',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      constraints: BoxConstraints(
                        minHeight: 120, // 원하는 최소 높이 설정
                        minWidth: 450,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
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
