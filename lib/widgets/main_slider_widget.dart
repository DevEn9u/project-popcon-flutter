import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:project_popcon_flutter/models/popupboard_dto.dart';
import 'package:project_popcon_flutter/services/api_service.dart';

class MainSliderWidget extends StatefulWidget {
  const MainSliderWidget({super.key});

  @override
  State<MainSliderWidget> createState() => _MainSliderWidgetState();
}

class _MainSliderWidgetState extends State<MainSliderWidget> {
  late ApiService apiService; // apiService 초기화
  List<PopupboardDTO> popupBoards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(baseUrl: 'http://10.0.2.2:8080'); // 애뮬레이터용
    fetchPopupBoards(); // 데이터를 가져오는 함수 호출
  }

  // 데이터를 가져오는 함수, async로 정의
  void fetchPopupBoards() async {
    try {
      List<PopupboardDTO> data = await apiService.fetchRandomPopupBoards(); // 랜덤 데이터 요청
      setState(() {
        popupBoards = data;
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching random popup boards: $error");
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : CarouselSlider(
            options: CarouselOptions(height: 400.0),
            items: popupBoards.map((board) {
              String imageUrl = "http://your-server-address${board.thumb}";
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(color: Colors.amber),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text('Image not found');
                      },
                    ),
                  );
                },
              );
            }).toList(),
          );
  }
}
