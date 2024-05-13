import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';


class DrawingPage extends StatelessWidget {
  Color _color = Colors.black;
  late final double wheelWidth;


  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(
      children: [
        Expanded(child: Container()),
        Divider(height: 1, thickness: 1, color: Colors.grey[400],),
        Container(
          padding: EdgeInsets.only(top: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
                  child: Slider(value: 3, onChanged: (size) {

                  }, min: 3, max: 15,),
                ),
              ),
            ]
        )
      ],
    ),);

  }


  Widget _colorWidget(Color color) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {},
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}


