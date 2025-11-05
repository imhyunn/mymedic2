                                                                    import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mymedic1/screens/bulletinboard/board_edit.dart';
import 'package:mymedic1/screens/bulletinboard/board_list.dart';
import 'package:mymedic1/screens/bulletinboard/board_new.dart';
import 'package:mymedic1/screens/bulletinboard/board_view_screen.dart';
import 'package:mymedic1/screens/home/home_screen.dart';
import 'package:mymedic1/screens/sign/login_screen.dart';
import 'package:mymedic1/screens/myapp.dart';
import 'package:mymedic1/test.dart';
import 'package:mymedic1/test2.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:mymedic1/data/user_provider.dart';

import 'data/board.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  //수정
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      tagForChildDirectedTreatment: TagForchildDirectedTreatment.yes,
      maxAdContentRating: MaxAdContentRating.g,
    ),
  );  
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => UserProvider()),
    ],
    child: MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData( fontFamily: 'Pretendard', scaffoldBackgroundColor: Colors.white, canvasColor: Colors.white, colorSchemeSeed: Colors.white), //colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      // home: Test2(),
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        BoardList.routeName: (context) => BoardList(),
        BoardNewScreen.routeName: (context) => BoardNewScreen(),
        BoardEditScreen.routeName: (context) {
          final board = ModalRoute.of(context)!.settings.arguments as Board;
          return BoardEditScreen(board);
        },
        BoardViewScreen.routeName: (context) {
          final board = ModalRoute.of(context)!.settings.arguments as Board;
          return BoardViewScreen(board);
        },
      },
    );
  }
}
