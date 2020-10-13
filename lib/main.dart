import 'package:flutter/material.dart';
import 'package:simple_popup_flutter/components/popup_clipper.dart';
import 'package:simple_popup_flutter/components/popup_position.dart';
import 'package:simple_popup_flutter/popup_widget.dart';

// sorry for my english :)

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PopupWidget Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  double x;
  double y;

  @override
  void initState() {
    x = 100;
    y = 100;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = 220;
    double height = 50;

    Widget activator = Container(
        alignment: Alignment.center,
        width: width,
        height: height,
        color: Colors.blue,
        child: Material(
          color: Colors.transparent,
          child: Text(
            'Drag me to change my position.\n'
            'Tap me to open the popup.',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ));

    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Container(
        child: Stack(
          children: [
            Positioned(
                top: y - MediaQuery.of(context).padding.top * 3,
                left: x,
                child: Draggable(
                  onDragEnd: (details) {
                    setState(() {
                      x = details.offset.dx;
                      y = details.offset.dy;
                      if (x < 0) x = 0;
                      if (y < MediaQuery.of(context).padding.top * 3)
                        y = MediaQuery.of(context).padding.top * 3;
                      if (x > MediaQuery.of(context).size.width - width)
                        x = MediaQuery.of(context).size.width - width;
                      if (y > MediaQuery.of(context).size.height - height)
                        y = MediaQuery.of(context).size.height - height;
                    });
                  },
                  feedback: activator,
                  child: PopupWidget(
                    withBlackout: true,
                    // Передаем PopupClipper, чтобы у попапа появилась стрелочка
                    popupClipper:
                        PopupClipper(isWithShadow: true, borderRadius: 6),
                    position: PopupPosition.AUTO,
                    child: activator,
                    popupContent: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Pop-up with automatic positioning'
                        '\n(but you can also set a specific position).\n'
                        'Depends of the widget\'s position and the screen limits',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
