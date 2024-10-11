import 'image_dto.dart';
import 'comment_dto.dart';

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
  final List<ImageDTO> images;
  final List<CommentDTO> comments;

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
    required this.comments,
  });

  factory BoardDTO.fromJson(Map<String, dynamic> json) {
    var imagesFromJson = json['images'] as List<dynamic>? ?? [];
    List<ImageDTO> imageList = imagesFromJson
        .map((imageJson) => ImageDTO.fromJson(imageJson))
        .toList();

    var commentsFromJson = json['comments'] as List<dynamic>? ?? [];
    List<CommentDTO> commentList = commentsFromJson
        .map((commentJson) => CommentDTO.fromJson(commentJson))
        .toList();

    return BoardDTO(
      boardIdx: json['board_idx'] ?? '',
      boardTitle: json['board_title'] ?? '',
      postDate: DateTime.parse(json['postdate']),
      contents: json['contents'] ?? '',
      writer: json['writer'] ?? '',
      visitCount: json['visitcount'] ?? 0,
      boardType: json['board_type'] ?? '',
      role: json['role'] ?? '',
      writerName: json['writerName'] ?? '알 수 없음',
      images: imageList,
      comments: commentList,
    );
  }
}
