import 'package:flutter/material.dart';
import 'package:mymedic1/screens/bulletinboard/board_list.dart';
import 'package:mymedic1/screens/home/home_screen.dart';

import 'package:mymedic1/screens/mypage.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    BoardList(),
    MyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 메인 위젯
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'home',
            activeIcon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_quilt_outlined),
            label: 'Bulletin Board',
            activeIcon: Icon(Icons.view_quilt),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'my',
            activeIcon: Icon(Icons.person),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF394B81),
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void initState() {
    //해당 클래스가 호출되었을떄
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
