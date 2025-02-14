// favorites テーブル用のモデル
class Favorite {
  final int? id;
  final String name;
  final int g;
  final int cc;
  final String addedAt;

  Favorite({this.id, required this.name, required this.g, required this.cc, required this.addedAt});

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'],
      name: map['name'],
      g: map['g'],
      cc: map['cc'],
      addedAt: map['added_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'g': g,
      'cc': cc,
      'added_at': addedAt,
    };
  }
}