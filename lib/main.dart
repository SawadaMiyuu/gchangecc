import 'package:flutter/material.dart';
import 'screens/book.dart';
import 'screens/saved_items.dart';
import 'screens/conversion.dart';
import 'screens/add_kiji.dart';
import 'database/database_helper.dart';
import 'models/kiji.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'g→cc変換',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFFF5252),    // ボトムボタンの選択色
          onPrimary: Color(0xFFFFAB91),       // ボタンやAppBarの背景色
          primaryContainer: Color(0xFFFFAB91), //フロートボタンの背景色
          onPrimaryContainer: Color(0xFFD81B60), //フロートボタンの文字色。
          secondary: Color(0xFFFFB6C1),  // 記事のタイトル色
          onSecondary: Color(0xFFFFCDD2),//ボトムボタンの非選択色
          surface: Colors.white,    // 背景色
          onSurface: Color(0xFFB71C1C),  // 文字とかアイコンの色
          error: Colors.red,
          onError: Colors.white,
        ),
        useMaterial3: true,
      ),



      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  final GlobalKey<BookState> _bookKey = GlobalKey<BookState>(); // 🔥 Bookの状態を管理するキー

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      Measure(),
      SavedItems(),
      Book(key: _bookKey), // Bookに記事リストを渡す
    ];
    // 各ページのタイトルを定義
    List<String> titles = [
      'g→cc変換',
      '保存リスト',
      'コラム',
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // いちごミルクっぽい淡いピンク
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text(titles[selectedIndex],
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),)), // 現在のページに応じたタイトルを設定
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.coffee),
            label: 'Measure',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Keep',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Book',
          ),
        ],
        unselectedItemColor: Theme.of(context).colorScheme.onSecondary, // 選択していないアイコンの色
        selectedItemColor: Theme.of(context).colorScheme.primary, // 選択したアイコンの色
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      floatingActionButton: selectedIndex == 2
          ? FloatingActionButton(
        onPressed: () async {
          final newKiji = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddKijiScreen()),
          );

          if (newKiji != null && newKiji is Kiji) {
            print('mainで受け取ったnewkiji :${newKiji.id}, Title: ${newKiji.title}');
            _bookKey.currentState?.fetchKijis(); // ✅ Book のデータを更新
          }
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
