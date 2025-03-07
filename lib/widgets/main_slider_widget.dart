import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project_popcon_flutter/models/popupboard_dto.dart';

class MainSliderWidget extends StatefulWidget {
  final List<PopupboardDTO> thumb; // 이미지 리스트를 받아옴
  final String baseUrl; // API 베이스 URL

  MainSliderWidget({required this.thumb, required this.baseUrl});

  @override
  _MainSliderWidgetState createState() => _MainSliderWidgetState();
}

class _MainSliderWidgetState extends State<MainSliderWidget> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 400.0,
        viewportFraction: 1.0, // 슬라이더가 가로로 꽉 차도록 설정
        autoPlay: true, // 슬라이더가 자동으로 넘어가도록 설정
        autoPlayInterval: Duration(seconds: 3), // 자동 넘김 간격 설정
      ),
      items: widget.thumb.map((popupBoard) {
        String thumbUrl = '${widget.baseUrl}${popupBoard.thumb}'; // 이미지 URL
        print(thumbUrl);

        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),

              child: popupBoard.thumb != null && popupBoard.thumb!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: thumbUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.broken_image, size: 50),
                    )
                  : Icon(Icons.image_not_supported, size: 50), // 대체 이미지
            );
          },
        );
      }).toList(),
    );
  }
}
