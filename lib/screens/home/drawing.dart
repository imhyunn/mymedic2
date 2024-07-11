import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:scribble/scribble.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  late ScribbleNotifier notifier;
  double currentValue = 5.0;
  Color _pickedColor = Colors.black;
  Color _currentColor = Colors.black;
  List<bool> _isSelected = [true, false, false, false];

  @override
  void initState() {
    notifier = ScribbleNotifier();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
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
        body: Column(
          children: [
            Expanded(child: Scribble(notifier: notifier)),
            Card(
              child: Container(
                width: size.width * 0.98,
                height: size.height * 0.13,
                decoration: BoxDecoration(
                  color: Color(0xE3F3F3F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _pickedColor = Color(0xFFFD0000);
                              notifier.setColor(_pickedColor);
                              _isSelected[0] = true;
                              _isSelected[1] = false;
                              _isSelected[2] = false;
                              _isSelected[3] = false;
                            });
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(0xFFFD0000),
                              borderRadius: BorderRadius.circular(4),
                              border: _isSelected[0]
                                  ? Border.all(color: Colors.grey, width: 2.5)
                                  : null,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _pickedColor = Color(0xFF0034FF);
                              notifier.setColor(_pickedColor);
                              _isSelected[0] = false;
                              _isSelected[1] = true;
                              _isSelected[2] = false;
                              _isSelected[3] = false;
                            });
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(0xFF0034FF),
                              borderRadius: BorderRadius.circular(4),
                              border: _isSelected[1]
                                  ? Border.all(color: Colors.grey, width: 2.5)
                                  : null,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _pickedColor = Color(0xFFFFD800);
                              notifier.setColor(_pickedColor);
                              _isSelected[0] = false;
                              _isSelected[1] = false;
                              _isSelected[2] = true;
                              _isSelected[3] = false;
                            });
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFD800),
                              borderRadius: BorderRadius.circular(4),
                              border: _isSelected[2]
                                  ? Border.all(color: Colors.grey, width: 2.5)
                                  : null,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('색을 선택하세요.'),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: _pickedColor,
                                    onColorChanged: (color) {
                                      setState(() {
                                        _currentColor = color;
                                      });
                                    },
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    child: const Text('선택'),
                                    onPressed: () {
                                      setState(() {
                                        _pickedColor = _currentColor;
                                        notifier.setColor(_pickedColor);
                                        _isSelected[0] = false;
                                        _isSelected[1] = false;
                                        _isSelected[2] = false;
                                        _isSelected[3] = true;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: _isSelected[3]
                                  ? Border.all(color: Colors.grey, width: 2.5)
                                  : null,
                              color: _isSelected[3] ? _pickedColor : null,
                              gradient: _isSelected[3] ? null : LinearGradient(
                                colors: [
                                  Color(0xFFFF0000),
                                  Color(0xFFFFC400),
                                  Color(0xFF1AFF00),
                                  Color(0xFF00FFD0),
                                  Color(0xFF003CFF),
                                  Color(0xFFD000FF),
                                  Color(0xFFFF0000),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.mode_edit_outline),
                          onPressed: () {
                            notifier.setColor(_pickedColor);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_off),
                          onPressed: () {
                            notifier.setEraser();
                          },
                        )
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Color(0xFFB6B6B6),
                        thumbColor: Color(0xFF3B3B3B),
                      ),
                      child: Slider(
                        value: currentValue,
                        max: 30,
                        min: 1,
                        onChanged: (value) => setState(() {
                          currentValue = value;
                          notifier.setStrokeWidth(currentValue);
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
