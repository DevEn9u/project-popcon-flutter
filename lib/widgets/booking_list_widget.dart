import 'package:flutter/material.dart';
import 'package:project_popcon_flutter/models/booking_dto.dart';
import 'package:intl/intl.dart';
import 'package:project_popcon_flutter/screens/popup_board_view.dart'; // PopupBoardView import

class BookingListWidget extends StatelessWidget {
  final List<BookingDTO> bookings;

  const BookingListWidget({Key? key, required this.bookings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "예약된 팝업 목록",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              color: Color(0xFF1e1e1e),
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
              child: ListTile(
                title: Text(
                  booking.popupTitle,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '방문 날짜: ${booking.visitDate != null ? dateFormat.format(booking.visitDate!) : '정보 없음'}\n'
                  '인원: ${booking.headcount}명\n'
                  '가격: ${booking.price}원',
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: booking.isCanceled == 1
                    ? Text(
                        '취소됨',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      )
                    : null,
                onTap: () {
                  // 예약 상세보기 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PopupBoardView(
                        boardIdx: booking.popupIdx,
                      ),
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
