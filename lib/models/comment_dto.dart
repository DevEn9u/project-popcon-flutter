import 'image_dto.dart';

class CommentDTO {
  final String comIdx;
  final String popupBoardIdx;
  final String boardIdx;
  final String comWriter;
  final String comContents;
  final DateTime comPostDate;
  final List<ImageDTO> comImg;
  final String comWriterName;
  final String popupTitle;

  CommentDTO({
    required this.comIdx,
    required this.popupBoardIdx,
    required this.boardIdx,
    required this.comWriter,
    required this.comContents,
    required this.comPostDate,
    required this.comImg,
    required this.comWriterName,
    required this.popupTitle,
  });

  factory CommentDTO.fromJson(Map<String, dynamic> json) {
    var imagesFromJson = json['com_img'] as List<dynamic>? ?? [];
    List<ImageDTO> imageList = imagesFromJson
        .map((imageJson) => ImageDTO.fromJson(imageJson))
        .toList();

    return CommentDTO(
      comIdx: json['com_idx'],
      popupBoardIdx: json['popup_board_idx'] ?? '',
      boardIdx: json['board_idx'] ?? '',
      comWriter: json['com_writer'] ?? '',
      comContents: json['com_contents'] ?? '',
      comPostDate: DateTime.parse(json['com_postdate']),
      comImg: imageList,
      comWriterName: json['comWriterName'] ?? '알 수 없음',
      popupTitle: json['popup_title'] ?? '',
    );
  }

  // 한국어 날짜 형식으로 변환하는 메서드
  String getFormattedPostDate() {
    return "${comPostDate.year}년 ${comPostDate.month.toString().padLeft(2, '0')}월 ${comPostDate.day.toString().padLeft(2, '0')}일 ${comPostDate.hour.toString().padLeft(2, '0')}:${comPostDate.minute.toString().padLeft(2, '0')}:${comPostDate.second.toString().padLeft(2, '0')}";
  }
}
