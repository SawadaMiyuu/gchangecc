// history テーブル用のモデル

// History はデータベースの1行（レコード）を表す
// toMap() で sqflite に保存できる形に変換
// fromMap() でデータベースのデータを History オブジェクトに変換

class History {
  final int? id;// データベースの主キー（自動採番）
  final String name;// 材料名（例: "小麦粉"）
  final int g;// 入力したグラム数
  final int cc;// 変換後のcc数
  final String createdAt;// データが作成された日時

  // コンストラクタ
  History({this.id, required this.name, required this.g, required this.cc, required this.createdAt});

  // データベースのMapデータからHistoryオブジェクトを作る
  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      id: map['id'],  // データベースのidを取得
      name: map['name'],  // 名前を取得
      g: map['g'],  // gを取得
      cc: map['cc'],  // ccを取得
      createdAt: map['created_at'],  // 登録日時を取得
    );
  }

  // Historyオブジェクトをデータベースに保存できるMapデータに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id, // ID
      'name': name, // 材料名
      'g': g, // 入力したグラム
      'cc': cc, // 計算後のcc
      'created_at': createdAt, // 登録日時
    };
  }
}