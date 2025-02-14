// Kiji テーブル用のモデル
class Kiji {
  final int? id;
  final String title;
  final String contents;
  final String thumbnail;
  final String addedAt;

//コンストラクタ
  Kiji({
    this.id,
    required this.title,
    required this.contents,
    required this.thumbnail,
    required this.addedAt,
  });

  factory Kiji.fromMap(Map<String, dynamic> map) {
    return Kiji(
      id: map['id'],
      title: map['title'],
      contents: map['contents'],
      thumbnail: map['thumbnail'],
      addedAt: map['added_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'contents': contents,
      'thumbnail': thumbnail,
      'added_at': addedAt,
    };
  }
}
