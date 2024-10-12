import 'comment_dto.dart';
import 'image_dto.dart';

class PopupboardDTO {
  final String boardIdx;
  final String boardTitle;
  final DateTime postDate;
  final String endDate;
  final String startDate;
  final String contents;
  final String popupAddr;
  final String? thumb; // thumb 값을 nullable로 변경
  final String category;
  final String writer;
  final int visitCount;
  final String role;
  final int popupFee;
  final int likesCount;
  final String openDays;
  final String openHours;
  final bool liked;

  final List<ImageDTO> images;
  final List<CommentDTO> comments;
  final String writerName;

  PopupboardDTO({
    required this.boardIdx,
    required this.boardTitle,
    required this.postDate,
    required this.endDate,
    required this.startDate,
    required this.contents,
    required this.popupAddr,
    this.thumb, // nullable 필드는 required 제거
    required this.category,
    required this.writer,
    required this.visitCount,
    required this.role,
    required this.popupFee,
    required this.likesCount,
    required this.openDays,
    required this.openHours,
    required this.liked,
    required this.images,
    required this.comments,
    required this.writerName,
  });

  factory PopupboardDTO.fromJson(Map<String, dynamic> json) {
    var imagesFromJson = json['images'] as List<dynamic>? ?? [];
    List<ImageDTO> imageList = imagesFromJson
        .map((imageJson) => ImageDTO.fromJson(imageJson))
        .toList();

    var commentsFromJson = json['comments'] as List<dynamic>? ?? [];
    List<CommentDTO> commentList = commentsFromJson
        .map((commentJson) => CommentDTO.fromJson(commentJson))
        .toList();

    return PopupboardDTO(
      boardIdx: json['board_idx'] ?? 'default_idx', // 기본값 설정
      boardTitle: json['board_title'] ?? 'Untitled',
      postDate: DateTime.tryParse(json['postdate'] ?? '') ??
          DateTime.now(), // 기본값 또는 현재 날짜
      endDate: json['end_date'] ?? 'unknown',
      startDate: json['start_date'] ?? 'unknown',
      contents: json['contents'] ?? '',
      popupAddr: json['popup_addr'] ?? '',
      thumb: json['thumb']?.toString() ??
          'assets/images/logo.png', // null일 경우 기본 이미지 경로
      category: json['category'] ?? 'general',
      writer: json['writer'] ?? 'anonymous',
      visitCount: json['visitcount'] ?? 0,
      role: json['role'] ?? 'viewer',
      popupFee: json['popup_fee'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      openDays: json['open_days'] ?? 'all',
      openHours: json['open_hours'] ?? '00:00-23:59',
      liked: json['liked'] ?? false,
      images: imageList,
      comments: commentList,
      writerName: json['writerName'] ?? '알 수 없음',
    );
  }
}
