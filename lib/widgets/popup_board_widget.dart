import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_popcon_flutter/screens/popup_board_view.dart';
import '../models/popupboard_dto.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PopupBoardWidget extends StatelessWidget {
  final List<PopupboardDTO> popups;
  final String baseUrl = 'http://3.38.153.104:8586';
  const PopupBoardWidget({Key? key, required this.popups}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (popups.isEmpty) {
      return Center(
        child: Text(
          '진행중인 팝업이 없습니다.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: popups.length,
      itemBuilder: (context, index) {
        final popup = popups[index];
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
                        // 상세보기 페이지로 이동, boardIdx 전달
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PopupBoardView(boardIdx: popup.boardIdx),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.0),
                        child: popup.thumb != null && popup.thumb!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl:
                                    '$baseUrl${popup.thumb}', // baseUrl에 맞게 수정
                                width: 142,
                                height: 142,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.broken_image, size: 50),
                              )
                            : Image.asset(
                                'assets/images/logo.png',
                                width: 142,
                                height: 142,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            popup.boardTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/images/location_icon.svg",
                                width: 14,
                                height: 14,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  popup.popupAddr,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  softWrap: true,
                                  maxLines: 2, // 최대 2줄로 제한
                                  overflow: TextOverflow
                                      .ellipsis, // 넘치는 텍스트는 말줄임표로 표시
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${popup.startDate} - ${popup.endDate}',
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
