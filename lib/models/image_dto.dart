class ImageDTO {
  final String imageIdx; // 이미지 일련번호
  final String imageUrl; // 이미지 URL
  final String imageType; // 이미지 타입 ('BOARD', 'POPUP', 'COMMENT')
  final String associatedId; // 연관된 게시글, 팝업, 댓글 ID
  final DateTime uploadDate; // 업로드 날짜

  ImageDTO({
    required this.imageIdx,
    required this.imageUrl,
    required this.imageType,
    required this.associatedId,
    required this.uploadDate,
  });

  factory ImageDTO.fromJson(Map<String, dynamic> json) {
    return ImageDTO(
      imageIdx: json['image_idx'],
      imageUrl: json['image_url'],
      imageType: json['image_type'],
      associatedId: json['associated_id'],
      uploadDate: DateTime.parse(json['upload_date']),
    );
  }
}
