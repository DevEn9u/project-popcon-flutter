class BookingDTO {
  final int bookingNum;
  final String popupIdx;
  final String memberId;
  final DateTime? visitDate;
  final DateTime? bookingDate;
  final int price;
  final int headcount;
  final int isPaid;
  final int isCanceled;
  final String popupTitle;

  BookingDTO({
    required this.bookingNum,
    required this.popupIdx,
    required this.memberId,
    this.visitDate,
    this.bookingDate,
    required this.price,
    required this.headcount,
    required this.isPaid,
    required this.isCanceled,
    required this.popupTitle,
  });

  factory BookingDTO.fromJson(Map<String, dynamic> json) {
    return BookingDTO(
      bookingNum: json['booking_num'] ?? 0,
      popupIdx: json['popup_idx']?.toString() ?? '',
      memberId: json['member_id'] ?? '',
      visitDate: parseDate(json['visit_date']),
      bookingDate: parseDate(json['booking_date']),
      price: json['price'] ?? 0,
      headcount: json['headcount'] ?? 0,
      isPaid: json['is_paid'] ?? 0,
      isCanceled: json['is_canceled'] ?? 0,
      popupTitle: json['popup_title'] ?? '',
    );
  }

  static DateTime? parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      print('Date parsing error: $e');
      return null;
    }
  }
}
