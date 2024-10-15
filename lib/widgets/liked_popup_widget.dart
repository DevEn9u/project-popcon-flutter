import 'package:flutter/material.dart';
import 'package:project_popcon_flutter/models/popupboard_dto.dart';
import 'package:project_popcon_flutter/screens/popup_board_view.dart';

class LikedPopupWidget extends StatelessWidget {
  final List<PopupboardDTO> popups;

  const LikedPopupWidget({Key? key, required this.popups}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String baseUrl = 'http://10.0.2.2:8080'; // 실제 IP 주소로 변경 필요

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "좋아요한 팝업 목록",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true, // 추가
          physics: NeverScrollableScrollPhysics(), // 추가
          itemCount: popups.length,
          itemBuilder: (context, index) {
            final popup = popups[index];
            return Card(
              color: Color(0xFF1e1e1e),
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
              child: ListTile(
                leading: popup.thumb != null && popup.thumb!.isNotEmpty
                    ? Image.network(
                        '$baseUrl/${popup.thumb}',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey,
                            child:
                                Icon(Icons.broken_image, color: Colors.white),
                          );
                        },
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey,
                        child: Icon(Icons.image, color: Colors.white),
                      ),
                title: Text(
                  popup.boardTitle ?? '',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  popup.popupAddr ?? '',
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                onTap: () {
                  // 상세보기 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PopupBoardView(boardIdx: popup.boardIdx),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
