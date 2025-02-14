// items テーブル用のモデル
class Item {
  final int? id;
  final String name;
  final int cc;

  Item({this.id, required this.name, required this.cc});

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      cc: map['cc'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cc': cc,
    };
  }
}