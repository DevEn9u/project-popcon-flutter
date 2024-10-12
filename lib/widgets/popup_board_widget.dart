import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_popcon_flutter/screens/popup_board_view.dart';

class PopupBoardWidget extends StatelessWidget {
  const PopupBoardWidget({super.key});

  // API로 불러올 데이터 전 사용할 더미데이터
  static const List<Map<String, String>> popupData = [
    {
      "title": "쿼카 앤 보보 인 더 우드 팝업스토어",
      "location": "서울특별시 성동구",
      "date": "24.10.24 - 24.11.06",
      "image": "assets/images/popup_image1.jfif",
    },
    {
      "title": "벨리곰 X LH <LH 곰in중개사> 팝업스토어",
      "location": "서울특별시 영등포구",
      "date": "24.10.24 - 24.11.06",
      "image": "assets/images/popup_image4.jfif",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 카드 생성
    return ListView.builder(
      // physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
      shrinkWrap: true, // 부모 위젯의 크기에 맞춰서 조정
      itemCount: popupData.length,
      itemBuilder: (context, index) {
        final popup = popupData[index];
        return Column(
          children: [
            Card(
              color: const Color(0xFF121212),
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              child: Container(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        // 상세보기 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PopupBoardView()),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.0),
                        child: Image.asset(
                          popup['image']!,
                          width: 142,
                          height: 142,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            popup['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SvgPicture.asset(
                                "assets/images/location_icon.svg",
                                width: 14,
                                height: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                popup['location']!,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                popup['date']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              color: Colors.grey,
            ),
          ],
        );
      },
    );
  }
}
