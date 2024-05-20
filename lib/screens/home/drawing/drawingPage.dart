import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mymedic1/screens/home/drawing/local_utils/DrawingProvider.dart';
import 'package:mymedic1/model/Dotinfo.dart';
import 'package:provider/provider.dart';

class DrawingPage extends StatefulWidget {
  static const routeName = '/paint';

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {

  @override
  Widget build(BuildContext context) {
    var p = Provider.of<DrawingProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(
                  painter: DrawingPainter(p.lines),
                )),
                GestureDetector(
                  onPanStart: (s) {
                    if (p.eraseMode) {
                      p.erase(s.localPosition);
                    } else {
                      p.drawStart(s.localPosition);
                    }
                  },
                  onPanUpdate: (s) {
                    if (p.eraseMode) {
                      p.erase(s.localPosition);
                    } else {
                      p.drawing(s.localPosition);
                    }
                  },
                  child: Container(),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[300],
          ),
          Container(
            color: Colors.grey[150],
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _colorWidget(Colors.black),
                      _colorWidget(Colors.red),
                      _colorWidget(Colors.yellow),
                      _colorWidget(Colors.green),
                      _colorWidget(Colors.blue),
                      /*ColorPicker(
                        pickerColor: pickerColor, //default color
                        onColorChanged: changeColor,
                    ),*/
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 20, right: 10),
                        child: Slider(
                          activeColor: Colors.black,
                          value: p.size,
                          onChanged: (size) {
                            p.changeSize = size;
                          },
                          min: 3,
                          max: 15,
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        p.changeEraseMode();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 25),
                        child: Text(
                          '지우개',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: p.eraseMode
                                  ? FontWeight.w900
                                  : FontWeight.w300),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorWidget(Color color) {
    var p = Provider.of<DrawingProvider>(context);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        p.changeColor = color;
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: p.color == color
                ? Border.all(color: Colors.white, width: 2)
                : null),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter{
  DrawingPainter(this.lines);
  final List<List<DotInfo>> lines;
  @override
  void paint(Canvas canvas, Size size) {

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}