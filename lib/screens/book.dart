import 'package:flutter/material.dart';
import '../models/kiji.dart';
import '../database/database_helper.dart';
import 'detailbook.dart';
import 'dart:io';

class Book extends StatefulWidget {
  const Book({super.key});

  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> {
  List<Kiji> _kijis = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchKijis(); // 画面が戻るたびにデータを更新
  }

  @override
  void initState() {
    super.initState();
    _fetchKijis(); // 初回データ取得
  }

  // データベースから記事リストを取得
  void _fetchKijis() async {
    List<Kiji> kijis = await _dbHelper.getKijis();
    if (mounted) {
      setState(() {
        _kijis = kijis;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _kijis.isEmpty
        ? const Center(child: Text('記事はありません'))
        : ListView.separated(
      itemCount: _kijis.length,
      separatorBuilder: (context, index) => const Divider(
        thickness: 1,
        color: Colors.grey,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final kiji = _kijis[index];
        return InkWell(
          onTap: () => _pushPage(context, kiji),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 8.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image(
                    image: kiji.thumbnail.startsWith('/data/user')
                        ? FileImage(File(kiji.thumbnail))
                        : AssetImage(kiji.thumbnail),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kiji.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary, // ここを変更
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        kiji.contents,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14,
                            color: Color(0xFFA1887F)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pushPage(BuildContext context, Kiji kiji) async {
    print("渡す前のkiji.id: ${kiji.id}");

    // `await` を使ってページ遷移後の結果を待つ
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailBook(kijiId: kiji.id!),
        fullscreenDialog: true,
      ),
    );

    // 戻ってきたらデータを更新
    _fetchKijis();
  }

}
