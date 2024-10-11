// lib/models/board_dto.dart

class BoardDTO {
  final String boardIdx;
  final String boardTitle;
  final DateTime postDate;
  final String contents;
  final String writer;
  final int visitCount;
  final String boardType;
  final String role;
  final String writerName;

  BoardDTO({
    required this.boardIdx,
    required this.boardTitle,
    required this.postDate,
    required this.contents,
    required this.writer,
    required this.visitCount,
    required this.boardType,
    required this.role,
    required this.writerName,
  });

  factory BoardDTO.fromJson(Map<String, dynamic> json) {
    return BoardDTO(
      boardIdx: json['board_idx'],
      boardTitle: json['board_title'],
      postDate: DateTime.parse(json['postdate']),
      contents: json['contents'],
      writer: json['writer'],
      visitCount: json['visitcount'],
      boardType: json['board_type'],
      role: json['role'],
      writerName: json['writerName'],
    );
  }
}
