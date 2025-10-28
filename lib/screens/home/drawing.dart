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
  bool _isEraser = false;

  List<bool> _isSelected = [true, false, false, false, false];

  MemoryImage? image = null;

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
          backgroundColor: Colors.white,
          title: Row(
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
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: "check",
              onPressed: () async {
                var renderImage = await notifier.renderImage();
                setState(() {
                  image = MemoryImage(renderImage.buffer.asUint8List());
                });
                var result = Navigator.pop(context, image);
              },
            ),
          ],
        ),
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
        body: Column(
          children: [
            Expanded(
              child: Center(
                  child: AspectRatio(
                aspectRatio: 1,
                child: Card(
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Color(0x16000000), width: 1),
                  ),
                  color: Colors.white,
                  child: Scribble(notifier: notifier),
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SafeArea(
                top: false,
                child: Container(
                  // width: size.width * 0.98,
                  // height: size.height * 0.13,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    color: Color(0xE3F3F3F3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0x14000000)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.mode_edit_outline,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              notifier.setColor(_pickedColor);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.auto_fix_off_outlined,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              notifier.setEraser();
                            },
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _pickedColor = Color(0xFFFD0000);
                                notifier.setColor(_pickedColor);
                                _isSelected[0] = true;
                                _isSelected[1] = false;
                                _isSelected[2] = false;
                                _isSelected[3] = false;
                                _isSelected[4] = false;
                              });
                            },
                            child: Container(
                              width: 27,
                              height: 27,
                              decoration: BoxDecoration(
                                color: Color(0xFFFD0000),
                                borderRadius: BorderRadius.circular(16),
                                border: _isSelected[0]
                                    ? Border.all(
                                        color: Color(0x57000000), width: 2.5)
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
                                _isSelected[4] = false;
                              });
                            },
                            child: Container(
                              width: 27,
                              height: 27,
                              decoration: BoxDecoration(
                                color: Color(0xFF0034FF),
                                borderRadius: BorderRadius.circular(16),
                                border: _isSelected[1]
                                    ? Border.all(
                                        color: Color(0x57000000), width: 2.5)
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
                                _isSelected[4] = false;
                              });
                            },
                            child: Container(
                              width: 27,
                              height: 27,
                              decoration: BoxDecoration(
                                color: Color(0xFFFFD800),
                                borderRadius: BorderRadius.circular(16),
                                border: _isSelected[2]
                                    ? Border.all(
                                        color: Color(0x57000000), width: 2.5)
                                    : null,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _pickedColor = Color(0xFF000000);
                                notifier.setColor(_pickedColor);
                                _isSelected[0] = false;
                                _isSelected[1] = false;
                                _isSelected[2] = false;
                                _isSelected[3] = false;
                                _isSelected[4] = true;
                              });
                            },
                            child: Container(
                              width: 27,
                              height: 27,
                              decoration: BoxDecoration(
                                color: Color(0xFF000000),
                                borderRadius: BorderRadius.circular(16),
                                border: _isSelected[4]
                                    ? Border.all(
                                        color: Color(0x57000000), width: 2.5)
                                    : null,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Color(0xfff4f4f4),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  // title: Text('색을 선택하세요'),
                                  contentPadding: EdgeInsets.all(23),
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
                                      child: const Text(
                                        '선택',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _pickedColor = _currentColor;
                                          notifier.setColor(_pickedColor);
                                          _isSelected[0] = false;
                                          _isSelected[1] = false;
                                          _isSelected[2] = false;
                                          _isSelected[3] = true;
                                          _isSelected[4] = false;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7),
                                          ),
                                          backgroundColor: Color(0xffe7effa)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: _isSelected[3]
                                    ? Border.all(
                                        color: Color(0x57000000), width: 2.5)
                                    : null,
                                color: _isSelected[3] ? _pickedColor : null,
                                gradient: _isSelected[3]
                                    ? null
                                    : LinearGradient(
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
                        ],
                      ),
                      Row(children: [
                        Text(
                          '굵기',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                  trackHeight: 9,
                                  activeTrackColor:
                                      Colors.black.withOpacity(0.45),
                                  inactiveTickMarkColor:
                                      Colors.black.withOpacity(0.15),
                                  overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
                                  thumbColor: Colors.black87,
                                  thumbShape: _RectThumb(
                                      width: 10,
                                      height: 18,
                                      radius: 10,
                                      borderColor: Colors.black,
                                      borderWidth: 1)),
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
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

class _RectThumb extends SliderComponentShape {
  _RectThumb({
    this.width = 10,
    this.height = 18,
    this.radius = 2,
    this.borderColor,
    this.borderWidth = 1,
  });

  final double width;
  final double height;
  final double radius;
  final Color? borderColor;
  final double borderWidth;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(width, height);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final fill = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.black87
      ..style = PaintingStyle.fill;
    context.canvas.drawRRect(rrect, fill);

    if (borderColor != null && borderWidth > 0) {
      final stroke = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      context.canvas.drawRRect(rrect, stroke);
    }
  }
}
