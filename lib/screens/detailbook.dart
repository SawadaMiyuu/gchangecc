import 'package:flutter/material.dart';
import '../models/kiji.dart';
import '../database/database_helper.dart';
import '../screens/editbook.dart';
import 'dart:io'; // 追加

class DetailBook extends StatefulWidget {
  final int kijiId; // ID のみを受け取る

  const DetailBook({super.key, required this.kijiId});

  @override
  _DetailBookState createState() => _DetailBookState();
}

class _DetailBookState extends State<DetailBook> {
  Kiji? _kiji; // 記事のデータ
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ScrollController _scrollController = ScrollController(); // ScrollControllerを追加

  @override
  void initState() {
    super.initState();
    _fetchKiji(); // 初回取得
  }

  // ID を元に記事を取得
  Future<void> _fetchKiji() async {
    try {
      final kiji = await _dbHelper.getKijiById(widget.kijiId);
      if (mounted) {
        setState(() {
          _kiji = kiji;
        });
      }
    } catch (e) {
      debugPrint('記事の取得に失敗しました: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('記事の取得に失敗しました')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_kiji == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _kiji!.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Color(0xFFF57F17)),
            onPressed: () => _editKiji(context),
          ),
          IconButton(
            icon: Icon(Icons.delete,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => _deleteKiji(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.all(Colors.brown[300]), // スクロールバーの色
            trackColor: WidgetStateProperty.all(Colors.brown[100]), // 背景色
            thickness: WidgetStateProperty.all(7.0), // スクロールバーの太さ
          ),
          child: Scrollbar(
            controller: _scrollController, // ScrollControllerを指定
            thumbVisibility: true, // スクロールバーを常に表示
            trackVisibility: true, // 背景を表示
            radius: const Radius.circular(10.0), // バーの角を丸く
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 記事の画像（サムネイル）
                  Center(
                    child: _kiji!.thumbnail.isNotEmpty
                        ? (_kiji!.thumbnail.startsWith('/data/user') // ファイルパスか判定
                        ? Image.file(File(_kiji!.thumbnail),
                        height: 250) // ファイルとして表示
                        : Image.asset(_kiji!.thumbnail,
                        height: 250)) // アセットならImage.assetを使う
                        : SizedBox(), // 空の場合は何も表示しない
                  ),

                  // タイトル
                  Text(
                    _kiji!.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _kiji!.contents,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editKiji(BuildContext context) async {
    try {
      print("遷移元のサムネイルパス: ${_kiji!.thumbnail}"); // デバッグ用
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditBook(kiji: _kiji!)),
      );
      _fetchKiji(); // 更新処理
    } catch (e) {
      debugPrint('編集画面への遷移に失敗しました: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('編集画面を開けませんでした')),
      );
    }
  }

  void _deleteKiji(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('記事を削除'),
        content: const Text('本当に削除しますか？この操作は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // キャンセル
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final dbHelper = DatabaseHelper();
                await dbHelper.deleteKiji(_kiji!.id!);
                Navigator.pop(context); // ダイアログを閉じる
                Navigator.pop(context); // 詳細画面を閉じる
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('記事を削除しました'),
                    backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                  ),
                );
              } catch (e) {
                debugPrint('記事の削除に失敗しました: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('記事の削除に失敗しました')),
                );
              }
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
