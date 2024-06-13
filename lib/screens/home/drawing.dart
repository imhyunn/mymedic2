import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  late ScribbleNotifier notifier;
  @override
  void initState() {
    notifier = ScribbleNotifier();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            InkWell(onTap: (){ notifier.setColor(Colors.red);}, child: Container(width: 30, height: 30, color: Colors.red,),)
          ],
        ),
      ),
      body: Scribble(
        notifier: notifier,
      ),
    );
  }
}
