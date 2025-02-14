import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/item.dart';
import '../models/history.dart';
import '../models/favorite.dart';
import '../models/kiji.dart';

class DatabaseHelper {
  static Database? _database;
  // DatabaseHelper._();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'my_database.db');
    await deleteDatabase(path);//実装時に削除
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    //Item 素材id、素材名、基準となるg,←をgにすると...
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        cc INTEGER
      )
    ''');

    // `items` テーブルに初期データを挿入//15cc基準
    await db.insert('items', {'name': '上白糖', 'cc': 9});
    await db.insert('items', {'name': 'グラニュー糖', 'cc': 13});
    await db.insert('items', {'name': '食塩', 'cc': 16});
    await db.insert('items', {'name': '強力粉', 'cc': 8});
    await db.insert('items', {'name': '薄力粉', 'cc': 8});
    await db.insert('items', {'name': '片栗粉', 'cc': 8});
    await db.insert('items', {'name': 'ベーキングパウダー', 'cc': 10});
    await db.insert('items', {'name': 'コーンスターチ', 'cc': 7});
    await db.insert('items', {'name': 'ショートニング', 'cc': 14});
    await db.insert('items', {'name': '顆粒調味料', 'cc': 8});
    await db.insert('items', {'name': 'ごま', 'cc': 9});
    await db.insert('items', {'name': 'パン粉', 'cc': 3});
    await db.insert('items', {'name': '上新粉', 'cc': 9});
    await db.insert('items', {'name': '白玉粉', 'cc': 9});
    await db.insert('items', {'name': '重曹', 'cc': 9});
    await db.insert('items', {'name': 'ココア', 'cc': 6});
    await db.insert('items', {'name': '紅茶葉', 'cc': 6});
    await db.insert('items', {'name': '粉ゼラチン', 'cc': 9});

    // history テーブル（履歴）//履歴id,素材名,入力した値,計算後の値,追加された日時
    await db.execute('''
      CREATE TABLE history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        g INTEGER,
        cc INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // favorites テーブル（お気に入り）//お気に入りID,素材名,履歴から取得したグラム,履歴結果cc,追加日時
    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        g INTEGER,
        cc INTEGER,
        added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(name, g)
      )
    ''');

    // Kiji テーブル（コラム）//コラムID,タイトル,内容,追加日時
    await db.execute('''
      CREATE TABLE kijis(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        contents TEXT,
        thumbnail TEXT,
        added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // `kijis` テーブルに初期データを挿入
    await db.insert('kijis', {'title': '大さじ15cc、小さじ5cc', 'contents': '大さじ15cc,中間10cc,小さじ5cc', 'thumbnail': 'assets/butter.png'});
    await db.insert('kijis', {'title': '少々:３本、一つまみ:２本', 'contents': '少々:親指、人差し指、中指でつまんだ量。'
        '一つまみ：親指と人差し指でつまんだ量', 'thumbnail': 'assets/butter.png'});
    await db.insert('kijis', {'title': '１カップ=200cc', 'contents': '液体の1カップは200CC'
        'お米の１カップは180cc', 'thumbnail': 'assets/butter.png'});
    await db.insert('kijis', {'title': '小麦粉は薄力粉', 'contents': 'レシピに小麦粉を使用。と書いてあったらそれは薄力粉！'
        '厳密にいえば小麦粉と薄力粉は別物だけど、あんまり気にしなくていい。'
        '薄力粉：フライ、天ぷらの打ち粉、天ぷらの衣、たこ焼き、お好み焼き'
        '中力粉：うどんなどの麺類'
        '強力粉：パンやピザの生地'
        ''
        'サクサク感、ふんわり感を出すのは薄力粉'
        'もちもち間を出すのは中力粉、強力粉', 'thumbnail': ''});
  }

  //Item
  Future<int> insertItem(Item item) async {
    Database db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<Item>> getItems() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('items');
    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<int> deleteItem(int id) async {
    Database db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  //History
  Future<int> insertHistory(History history) async {
    Database db = await database;

    // 既存のデータを確認
    List<Map<String, dynamic>> existing = await db.query(
      'history',
      where: 'name = ? AND g = ?',
      whereArgs: [history.name, history.g],
    );

    if (existing.isNotEmpty) {
      // 既存データの `created_at` を更新
      return await db.update(
        'history',
        {'created_at': DateTime.now().toString()},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      // 新規追加
      return await db.insert('history', history.toMap());
    }
  }

  Future<List<History>> getHistory() async {
    Database db = await database;
    List<Map<String, dynamic>> maps =
        await db.query('history', orderBy: 'created_at DESC');
    return maps.map((map) => History.fromMap(map)).toList();
  }

  Future<int> updateHistory(History history) async {
    final db = await database;
    return await db.update(
      'history',
      history.toMap(),
      where: 'id = ?',
      whereArgs: [history.id],
    );
  }

  Future<int> deleteHistory(int id) async {
    Database db = await database;
    return await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  //Favorite
  Future<int> insertFavorite(Favorite favorite) async {
    Database db = await database;

    return await db.insert(
      'favorites',
      favorite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // 重複時に上書き
    );
  }

  Future<List<Favorite>> getFavorites() async {
    Database db = await database;
    List<Map<String, dynamic>> maps =
        await db.query('favorites', orderBy: 'added_at DESC');
    return maps.map((map) => Favorite.fromMap(map)).toList();
  }

  Future<int> deleteFavorite(int id) async {
    Database db = await database;
    return await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

//Kiji
  Future<int> insertKiji(Kiji kiji) async {
    Database db = await database;
    return await db.insert('kijis', kiji.toMap());
  }

  Future<List<Kiji>> getKijis() async {
    Database db = await database;
    List<Map<String, dynamic>> maps =
        await db.query('kijis', orderBy: 'added_at DESC');
    return maps.map((map) => Kiji.fromMap(map)).toList();
  }

  Future<int> deleteKiji(int id) async {
    Database db = await database;
    return await db.delete('kijis', where: 'id = ?', whereArgs: [id]);
  }

  //IDで、一件だけ取ってくる
  Future<Kiji?> getKijiById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'kijis',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Kiji.fromMap(maps.first); // 1 件だけ返す
    }
    return null; // 記事が見つからなかった場合
  }


  /// 記事を更新する
  Future<int> updateKiji(Kiji kiji) async {
    final db = await database;
    return await db.update('kijis',kiji.toMap(),where: 'id = ?',whereArgs: [kiji.id]);
  }
}
