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
    super.dispose();
  }

  // 画像を選択する関数
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

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
      id: widget.kiji.id,  // 編集対象のID
      title: _titleController.text,
      contents: _contentController.text,
      thumbnail: _imageFile!.path, // 画像が変更されていない場合は元の画像を使用
      addedAt: widget.kiji.addedAt, // 投稿日時はそのまま
    );

    // データベースを更新
    await DatabaseHelper().updateKiji(updatedKiji);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('記事を更新しました')),
    );

    Navigator.pop(context); // 編集画面を閉じる
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('記事を編集'),
      ),
      body: SingleChildScrollView( // 画面をスクロール可能にする
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'タイトル'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: '内容'),
                maxLines: 10,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),

              // 画像プレビュー
              _imageFile == null
                  ? Image.asset('assets/butter.png', height: 150)
                  : _imageFile!.path.startsWith('/data/user') // ファイルパスかどうかを判定
                  ? Image.file(_imageFile!, height: 150) // ファイルパスならImage.fileを使用
                  : Image.asset(_imageFile!.path, height: 150), // アセットならImage.assetを使用

              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('画像を選択'),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveKiji,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade500, // 背景色をオレンジに設定
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
