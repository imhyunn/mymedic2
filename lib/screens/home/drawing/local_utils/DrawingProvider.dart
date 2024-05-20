import 'dart:math';
import 'package:mymedic1/model/Dotinfo.dart';
import 'package:flutter/material.dart';

class DrawingProvider extends ChangeNotifier{
  final lines = <List<DotInfo>>[];

  double _size = 3;
  double get size => _size;
  set changeSize(double size){
    _size = size;
    notifyListeners();
  }

  Color _color  = Colors.black;
  Color get color => _color;
  set changeColor(Color color){
    _color = color;
    notifyListeners();
  }

  bool _eraseMode = false;
  bool get eraseMode => _eraseMode;

  void changeEraseMode(){
    _eraseMode = !_eraseMode;
    notifyListeners();
  }

  void drawStart(Offset offset){
    var oneLine  = <DotInfo>[];
    oneLine.add(DotInfo(offset, size, color));
    lines.add(oneLine);
    notifyListeners();
  }

  void drawing(Offset offset){
    lines.last.add(DotInfo(offset, size, color));
    notifyListeners();
  }

  void erase(Offset offset){

  }
}