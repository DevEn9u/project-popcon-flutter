import 'image_dto.dart';

class BoardDTO {
  final String boardIdx; // 게시글 일련번호
  final String boardTitle; // 제목
  final DateTime postDate; // 작성 날짜
  final String contents; // 내용
  final String writer; // 작성자 ID
  final int visitCount; // 조회수
  final String boardType; // 게시글 구분 (공지, 자유)
  final String role; // 권한
  final String writerName; // 작성자 이름
  final List<ImageDTO> images; // 연관된 이미지 리스트

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
    required this.images,
  });

  factory BoardDTO.fromJson(Map<String, dynamic> json) {
    var imagesFromJson = json['images'] as List<dynamic>? ?? [];
    List<ImageDTO> imageList =
        imagesFromJson.map((i) => ImageDTO.fromJson(i)).toList();

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
      images: imageList,
    );
  }
}
