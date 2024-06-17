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
        actions: [
          Row(
            children: [
              ValueListenableBuilder(
                valueListenable: notifier,
                builder: (context, value, child) => IconButton(
                    onPressed: notifier.canUndo ? notifier.undo : null,
                    icon: Icon(Icons.undo)),
              ),
              ValueListenableBuilder(
                valueListenable: notifier,
                builder: (context, value, child) => IconButton(
                    onPressed: notifier.canRedo ? notifier.redo : null,
                    icon: Icon(Icons.redo)),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: "Clear",
                onPressed: notifier.clear,
              ),

            ],
          )
        ],
        // title: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     InkWell(onTap: (){ notifier.setColor(Colors.red);}, child: Container(width: 30, height: 30, color: Colors.red,),),
        //     InkWell(onTap: (){ notifier.setColor(Colors.blue);}, child: Container(width: 30, height: 30, color: Colors.blue,),),
        //     InkWell(onTap: (){ notifier.setColor(Colors.green);}, child: Container(width: 30, height: 30, color: Colors.green,),),
        //     InkWell(onTap: (){ notifier.setColor(Colors.yellow);}, child: Container(width: 30, height: 30, color: Colors.yellow,),),
        //     InkWell(onTap: (){ notifier.setColor(Colors.black);}, child: Container(width: 30, height: 30, color: Colors.black,),)
        //   ],
        // ),
      ),
      body: Scribble(
        notifier: notifier,
      ),
    );
  }


}
