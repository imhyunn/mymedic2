import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mymedic1/screens/bulletinboard/board_edit.dart';
import 'package:mymedic1/screens/bulletinboard/board_list.dart';
import 'package:mymedic1/screens/bulletinboard/board_view_screen.dart';
import 'package:mymedic1/screens/home/home_screen.dart';
import 'package:mymedic1/screens/sign/login_screen.dart';
import 'package:mymedic1/screens/myapp.dart';
import 'package:mymedic1/test.dart';
import 'package:mymedic1/test2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.white)),
      // home: Test2(),
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        BoardList.routeName: (context) => BoardList(),
        BoardEditScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          final id = args != null ? args as int : null;
          return BoardEditScreen(id);
        },
        BoardViewScreen.routeName: (context) {
          final id = ModalRoute.of(context)!.settings.arguments as int;
          return BoardViewScreen(id);
        },
      },
    );
  }
}
