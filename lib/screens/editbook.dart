import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../database/database_helper.dart';
import '../models/kiji.dart';

class EditBook extends StatefulWidget {
  final Kiji kiji;

  const EditBook({super.key, required this.kiji});

  @override
  _EditBookState createState() => _EditBookState();
}

class _EditBookState extends State<EditBook> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  File? _imageFile; // 選択された画像
  ScrollController _scrollController = ScrollController(); //初期化時に直接設定

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.kiji.title);
    _contentController = TextEditingController(text: widget.kiji.contents);
    // 既存のサムネイル画像を表示
    _imageFile = widget.kiji.thumbnail.isNotEmpty ? File(widget.kiji.thumbnail) : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose(); // ScrollControllerを破棄
    super.dispose();
  }

  // 画像を選択する関数
  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// 記事を保存
  void _saveKiji() async {
    // 更新するKijiオブジェクトを作成
    Kiji updatedKiji = Kiji(
      id: widget.kiji.id,
      // 編集対象のID
      title: _titleController.text,
      contents: _contentController.text,
      thumbnail: _imageFile!.path,
      // 画像が変更されていない場合は元の画像を使用
      addedAt: widget.kiji.addedAt, // 投稿日時はそのまま
    );

    // データベースを更新
    await DatabaseHelper().updateKiji(updatedKiji);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('記事を更新しました'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );

    Navigator.pop(context); // 編集画面を閉じる
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '記事を編集',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
      ),
      body: SingleChildScrollView(
        // 画面をスクロール可能にする
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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

              const SizedBox(height: 16),
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
              _imageFile == null
                  ? Image.asset('assets/butter.png', height: 150)
                  : _imageFile!.path.startsWith('/data/user') // ファイルパスかどうかを判定
                  ? Image.file(_imageFile!,
                  height: 150) // ファイルパスならImage.fileを使用
                  : Image.asset(_imageFile!.path, height: 150),
              // アセットならImage.assetを使用

              SizedBox(height: 10),
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
