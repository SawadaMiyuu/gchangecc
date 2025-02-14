import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:flutter/services.dart';
import '../models/history.dart';
import '../models/item.dart';
import '../models/favorite.dart';

class Measure extends StatefulWidget {
  const Measure({super.key});

  @override
  State<Measure> createState() => _MeasureState();
}

class _MeasureState extends State<Measure> {
  Item? isSelectedItem;
  final TextEditingController _gramController = TextEditingController();
  double? _convertedValue;
  List<Item> items = []; // データベースから取得したデータを保存
  List<History> _historyList = [];
  Set<int> _favoriteSet = {}; // お気に入りの履歴IDを保存
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fetchHistory(); // アプリ起動時に履歴を取得
    _fetchItems(); // アプリ起動時にデータベースから items を取得
    _fetchFavorites(); // お気に入り情報を取得
  }

  //メモリの開放(メモリリークを防ぐ)
  @override
  void dispose() {
    _gramController.dispose(); // ここで破棄
    super.dispose();
  }

  // 🔹 `items` テーブルからデータを取得する
  void _fetchItems() async {
    try {
      List<Item> fetchedItems = await _dbHelper.getItems();
      setState(() {
        items = fetchedItems;
      });
    } catch (e) {
      print("エラー発生: $e"); // 本番ではログに残す
    }
  }

  // 履歴をデータベースから取得する
  void _fetchHistory() async {
    List<History> history = await _dbHelper.getHistory();
    setState(() {
      _historyList = history;
    });
  }

  // グラムをccに変換する
  void _convertGramsToCc() {
    setState(() {
      double grams = double.tryParse(_gramController.text) ?? 0;
      if (grams > 0 && isSelectedItem != null) {
        double conversionFactor = isSelectedItem!.cc.toDouble();
        _convertedValue = grams * (conversionFactor / 15);
      } else {
        _convertedValue = null;
      }
    });
  }

  // 履歴をデータベースに追加または更新
  void _addHistory() async {
    if (_convertedValue == null || isSelectedItem == null) return;
      int gValue = int.tryParse(_gramController.text) ?? 0;

      // すでに同じアイテム名 + g の履歴があるかチェック
      History? existingHistory;
      try {
        existingHistory = _historyList.firstWhere(
              (history) => history.name == isSelectedItem!.name && history.g == gValue,
        );
      } catch (e) {
        existingHistory = null;
      }

      if (existingHistory != null) {
        // 既存の履歴がある場合は `createdAt` を更新
        final updatedHistory = History(
          id: existingHistory.id, // ID を保持
          name: existingHistory.name,
          g: existingHistory.g,
          cc: existingHistory.cc,
          createdAt: DateTime.now().toString(), // 更新
        );
        await DatabaseHelper().updateHistory(updatedHistory);
      } else {
        // ない場合は新規追加
        final newHistory = History(
          name: isSelectedItem!.name,
          g: gValue,
          cc: _convertedValue!.toInt(),
          createdAt: DateTime.now().toString(),
        );
        await DatabaseHelper().insertHistory(newHistory);
      }

// 🔹 履歴の件数をチェックし、30 件を超えたら古い履歴を削除
    List<History> allHistory = await _dbHelper.getHistory();
    if (allHistory.length > 30) {
      // `createdAt` が最も古い履歴を取得
      allHistory.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      int? oldestId = allHistory.first.id;
      if (oldestId != null) {
        await _dbHelper.deleteHistory(oldestId);
      }}
      _fetchHistory(); // 履歴を更新
  }


  // 履歴を削除する
  void _deleteHistory(int? id) async {
    if (id == null) return;
    await _dbHelper.deleteHistory(id);
    _fetchHistory();
  }

  // お気に入りの履歴IDを取得
  void _fetchFavorites() async {
    List<Favorite> favorites = await _dbHelper.getFavorites();
    setState(() {
      _favoriteSet = favorites.map((f) => f.id!).toSet();
    });
  }

  // お気に入りを追加・削除
  void _toggleFavorite(History history) async {
    if (history.id == null) return; // IDがnullなら処理しない

    // 🔹 すでに同じ名前 & g のお気に入りがあるかチェック
    List<Favorite> favorites = await _dbHelper.getFavorites();
    Favorite? existingFavorite = favorites.firstWhere(
          (f) => f.name == history.name && f.g == history.g,
      orElse: () => Favorite(id: null, name: "", g: 0, cc: 0, addedAt: ""),
    );

    if (existingFavorite.id != null) {
      // 既存の同じお気に入りがある場合は削除
      await _dbHelper.deleteFavorite(existingFavorite.id!);
      setState(() {
        _favoriteSet.remove(existingFavorite.id);
      });
      return;
    }

    // お気に入りに追加
    final favorite = Favorite(
      id: history.id,
      name: history.name,
      g: history.g,
      cc: history.cc,
      addedAt: DateTime.now().toString(),
    );
    await _dbHelper.insertFavorite(favorite);
    setState(() {
      _favoriteSet.add(history.id!);
    });
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 30),
          // 🟡 セレクトボックス
          Center(
            child: DropdownButton<Item>(
              items: items.map((item) {
                return DropdownMenuItem<Item>(
                  value: item,
                  child: Center(
                    child: Text(item.name,
                        style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.onPrimary),),
                  ),
                );
              }).toList(),
              onChanged: (Item? value) {
                setState(() {
                  isSelectedItem = value;
                  _convertGramsToCc();
                });
              },
              value: isSelectedItem,
              hint: Text("選択してください",
                  style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary),
              ),
              icon: Icon(
                Icons.arrow_drop_down,  // ドロップダウンのアイコン
                color: Theme.of(context).colorScheme.primary,    // アイコンの色を変更
                size: 30,               // アイコンの大きさを調整（お好みで）
              ),
            ),
          ),

          // 🟡 変換
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 🟢 テキストフィールド
              SizedBox(
                width: 100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextField(
                    controller: _gramController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'グラム',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 10, // 最大5文字まで
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // 数字のみ入力許可
                    ],
                    onChanged: (value) => _convertGramsToCc(),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(right: 20), child: Text("g")),
              Icon(Icons.fast_forward_rounded,color: Theme.of(context).colorScheme.onPrimary,size: 30,),
              const SizedBox(width: 20),
              Flexible(
                child: Text(
                  _convertedValue != null ? _convertedValue!.toStringAsFixed(2) : '',
                  style: const TextStyle(
                    color: Color(0xFFFF795548),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dashed,
                    decorationThickness: 2.0,
                    decorationColor: Colors.amber,
                  ),
                  overflow: TextOverflow.ellipsis, // はみ出す場合は省略
                ),
              ),
              const Text("cc"),
            ],
          ),

          // 🟡 履歴に追加ボタン
          Container(
            width: 100,
            height: 40,
            child: ClipPath(
              clipper: TriangleClipper(),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary, // ボタンの色
                  foregroundColor: Theme.of(context).colorScheme.onSurface, // 文字の色
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                onPressed: _addHistory,
                child: const Padding(
                  padding: EdgeInsets.only(left: 15, bottom: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('履歴に残す'),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // 🟡 履歴セクション
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("履歴",style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.onPrimary)),
              Text(
                "(${_historyList.length}件)", // 🔹 履歴の件数を表示
                style: TextStyle(fontSize: 16, color: Colors.brown[300]),
              ),
            ],
          ),
          Container(
            height: 300,
            width: 360,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _historyList.isEmpty
                ? Center(child: Text("履歴なし",style: TextStyle(fontSize: 16,color: Theme.of(context).colorScheme.onSecondary)))
                : ListView.builder(
              itemCount: _historyList.length,
              itemBuilder: (context, index) {
                final history = _historyList[index];
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround, // 左右に配置
                      children: [
                        const SizedBox(width: 5),
                        // 星アイコンを左側に配置
                        IconButton(
                          icon: Icon(
                            Icons.star,
                            color: _favoriteSet.contains(history.id)
                                ? Color(0xFF8D6E63) // 登録
                                : Theme.of(context).colorScheme.onSecondary, // 外れてる
                          ),
                          onPressed: () => _toggleFavorite(history),
                        ),
                        // 名前とグラム

                        SizedBox(
                          width: 250,
                          height: 50,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Text("${history.name} "),
                                const SizedBox(width: 5),
                                Text("${history.g}g"),
                                Icon(
                                  Icons.fast_forward_rounded,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                                Text("${history.cc}cc"),
                              ],
                            ),
                          ),
                        ),
                        // ゴミ箱アイコンを右側に配置
                        IconButton(
                          icon: Icon(Icons.delete,color: Color(0xFFFF8A80),),
                          onPressed: () => _deleteHistory(history.id!),
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                    Divider(color: Theme.of(context).colorScheme.onSecondary),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// 三角形の形状を作るクリッパー
class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // 四角形の上部分
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 15);

    // 三角形の下部分
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height - 15);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
