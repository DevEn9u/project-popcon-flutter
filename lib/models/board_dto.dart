class BoardDTO {
  String boardIdx; // 게시글 일련번호
  String boardTitle; // 제목
  DateTime postdate; // 작성 날짜
  String contents; // 내용
  String writer; // 작성자 ID
  int visitcount; // 조회수
  String boardType; // 게시글 구분 (공지, 자유)
  String role; // 권한
  List<ImageDTO> images; // 연관된 이미지 리스트
  String writerName; // 작성자 이름

  BoardDTO({
    required this.boardIdx,
    required this.boardTitle,
    required this.postdate,
    required this.contents,
    required this.writer,
    required this.visitcount,
    required this.boardType,
    required this.role,
    required this.images,
    required this.writerName,
  });

  factory BoardDTO.fromJson(Map<String, dynamic> json) {
    return BoardDTO(
      boardIdx: json['board_idx'],
      boardTitle: json['board_title'],
      postdate: DateTime.parse(json['postdate']),
      contents: json['contents'],
      writer: json['writer'],
      visitcount: json['visitcount'],
      boardType: json['board_type'],
      role: json['role'],
      images:
          (json['images'] as List).map((i) => ImageDTO.fromJson(i)).toList(),
      writerName: json['writerName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board_idx': boardIdx,
      'board_title': boardTitle,
      'postdate': postdate.toIso8601String(),
      'contents': contents,
      'writer': writer,
      'visitcount': visitcount,
      'board_type': boardType,
      'role': role,
      'images': images.map((image) => image.toJson()).toList(),
      'writerName': writerName,
    };
  }
}

class ImageDTO {
  String imageUrl; // 이미지 URL
  String imageType; // 이미지 타입
  String associatedId; // 연관된 ID

  ImageDTO({
    required this.imageUrl,
    required this.imageType,
    required this.associatedId,
  });

  factory ImageDTO.fromJson(Map<String, dynamic> json) {
    return ImageDTO(
      imageUrl: json['image_url'],
      imageType: json['image_type'],
      associatedId: json['associated_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'image_type': imageType,
      'associated_id': associatedId,
    };
  }
}
