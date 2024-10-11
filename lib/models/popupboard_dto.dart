class PopupboardDTO {
  final String boardIdx;
  final String boardTitle;
  final DateTime postDate;
  final String endDate;
  final String startDate;
  final String contents;
  final String popupAddr;
  final String thumb;
  final String category;
  final String writer;
  final int visitCount;
  final String role;
  final int popupFee;
  final int likesCount;
  final String openDays;
  final String openHours;
  final bool liked;


  PopupboardDTO({
    required this.boardIdx,
    required this.boardTitle,
    required this.postDate,
    required this.endDate,
    required this.startDate,
    required this.contents,
    required this.popupAddr,
    required this.thumb,
    required this.category,
    required this.writer,
    required this.visitCount,
    required this.role,
    required this.popupFee,
    required this.likesCount,
    required this.openDays,
    required this.openHours,
    required this.liked
  });

  factory PopupboardDTO.fromJson(Map<String, dynamic> json) {
    return PopupboardDTO(
      boardIdx: json['board_idx'],
      boardTitle: json['board_title'],
      postDate: DateTime.parse(json['postdate']),
      endDate: json['end_date'],
      startDate: json['start_date'],
      contents: json['contents'],
      popupAddr: json['popup_addr'],
      thumb: json['thumb'],
      category: json['category'],
      writer: json['writer'],
      visitCount: json['visitcount'],
      role: json['role'],
      popupFee: json['popup_fee'],
      likesCount: json['likes_count'],
      openDays: json['open_days'],
      openHours: json['open_hours'],
      liked: json['liked']
    );
  }
}
