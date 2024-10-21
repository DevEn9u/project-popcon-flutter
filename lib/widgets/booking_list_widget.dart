import 'package:awesome_notifications/awesome_notifications.dart';
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
                    : ElevatedButton(
                        onPressed: () {
                          Future.delayed(Duration(seconds: 3), () {
                            // 테스트버튼 클릭시 알림 주석
                            // scheduleImmediateNotificationForBooking(booking);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero, // 버튼 크기를 아이콘 크기에 맞춤
                          backgroundColor: Color(0xFFF0D9B5), // 버튼 색상
                          shape: CircleBorder(), // 버튼을 원형으로 설정
                        ),
                        child: Icon(
                          Icons.notifications, // 알림 아이콘
                          size: 18, // 아이콘 크기 설정
                          color: Colors.black, // 아이콘 색상 설정
                        ),
                      ),
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

  // // 개별 예약에 대한 알림 스케줄링
  // Future<void> scheduleImmediateNotificationForBooking(
  //     BookingDTO booking) async {
  //   int notificationId = booking.bookingNum;

  //   try {
  //     await AwesomeNotifications().createNotification(
  //       content: NotificationContent(
  //         id: notificationId,
  //         channelKey: 'basic_channel',
  //         title: '예약 팝업 알림',
  //         body: '${booking.popupTitle} 팝업 방문 예약이 있습니다.',
  //         notificationLayout: NotificationLayout.Default,
  //         payload: {'bookingNum': booking.bookingNum.toString()},
  //       ),
  //     );

  //     print('3초 후 예약 알림이 전송되었습니다.');
  //   } catch (e) {
  //     print('알림 전송 중 오류 발생: $e');
  //   }
  // }
}
