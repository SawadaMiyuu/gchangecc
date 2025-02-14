import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../database/database_helper.dart';
import '../models/kiji.dart';

class AddKijiScreen extends StatefulWidget {
  @override
  _AddKijiScreenState createState() => _AddKijiScreenState();
}

class _AddKijiScreenState extends State<AddKijiScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _imageFile; // 選択された画像
  ScrollController _scrollController = ScrollController(); //初期化時に直接設定

  // 画像を選択する関数
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  //データベースに保存する
  void _saveKiji() async {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      Kiji newKiji = Kiji(
        title: _titleController.text,
        contents: _contentController.text,
        thumbnail: _imageFile != null ? _imageFile!.path : 'assets/butter.png', // ✅ 画像が未選択ならデフォルト画像
        addedAt: DateTime.now().toString(),
      );

      await DatabaseHelper().insertKiji(newKiji);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('記事を追加しました'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
      // デバッグ用: 保存した記事のIDを確認
      print("保存した記事のID: ${newKiji.id}");// データベースから最新記事を取得して確認
      var savedKijis = await DatabaseHelper().getKijis();
      print('保存された記事一覧:');
      for (var kiji in savedKijis) {
        print('追加した後リストID: ${kiji.id}, Title: ${kiji.title}');
      }
      // ✅ 追加した記事を戻り値として渡す。そんで前のページに戻る
      Navigator.pop(context, newKiji);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose(); // ScrollControllerを破棄
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('記事の追加',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.brown,
        ),)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'タイトル'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(Colors.brown[300]),// スクロールバーの色
                  trackColor: WidgetStateProperty.all(Colors.brown[100]),// 背景色
                  thickness: WidgetStateProperty.all(7.0),// スクロールバーの太さ
                ),
                child: Scrollbar(
                  controller: _scrollController, // ScrollControllerを指定
                  thumbVisibility: true, // スクロールバーを常に表示
                  trackVisibility: true, // 背景を表示
                  radius: const Radius.circular(10.0), // バーの角を丸く
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(labelText: '内容'),
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 画像プレビュー
              _imageFile != null
                  ? Image.file(_imageFile!, height: 150)
                  : Image.asset('assets/butter.png', height: 150), // ✅ デフォルト画像を表示

              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(
                  Icons.image,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                label: Text(
                  '画像を選択',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveKiji,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[300], // 背景色をオレンジに設定
                  foregroundColor: Colors.white, // テキストの色を白に設定
                ),
                child: const Text('記事を保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
