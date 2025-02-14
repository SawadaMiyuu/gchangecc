import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/favorite.dart';

class SavedItems extends StatefulWidget {
  const SavedItems({super.key});

  @override
  _SavedItemsState createState() => _SavedItemsState();
}

class _SavedItemsState extends State<SavedItems> {
  List<Favorite> _favoriteList = []; // お気に入りリスト
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fetchFavorites(); // アプリ起動時にデータベースから favorites を取得
  }

  // お気に入りデータを取得
  void _fetchFavorites() async {
    List<Favorite> favorites = await _dbHelper.getFavorites();
    if (mounted) {
      setState(() {
        _favoriteList = favorites;
      });
    }
  }

  // お気に入りを削除（リストを直接更新）
  void _removeFavorite(int id) async {
    await _dbHelper.deleteFavorite(id);
    setState(() {
      _favoriteList.removeWhere((fav) => fav.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _favoriteList.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(10),
            child: Text("お気に入りなし", style: TextStyle(fontSize: 16)),
          )
        : ListView.builder(
            shrinkWrap: true,
            itemCount: _favoriteList.length,
            itemBuilder: (context, index) {
              final favorite = _favoriteList[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.star, color: Color(0xFF8D6E63)),
                          onPressed: () => _removeFavorite(favorite.id!),
                        ),
                        SizedBox(
                          width: 300,
                          height: 50,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: [
                              Text("${favorite.name} ${favorite.g}g"),
                              Icon(
                                Icons.fast_forward_rounded,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              Text("${favorite.cc}cc"),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey, height: 1),
                  ],
                ),
              );
            },
          );
  }
}
