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
      options: CarouselOptions(height: 400.0),
      items: widget.thumb.map((popupBoard) {
        String thumbUrl = '${widget.baseUrl}${popupBoard.thumb}'; // 이미지 URL
        print(thumbUrl);

        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(color: Colors.amber),
              child: popupBoard.thumb != null && popupBoard.thumb!.isNotEmpty ? CachedNetworkImage(
                imageUrl: thumbUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.broken_image, size: 50),
              )
              : Icon(Icons.image_not_supported, size: 50), // 대체 이미지
            );
          },
        );
      }).toList(),
    );
  }
}
