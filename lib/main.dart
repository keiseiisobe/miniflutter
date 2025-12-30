import 'package:flutter/material.dart';
import 'package:miniflutter/widgets.dart' as miniflutter;

void main() {
  miniflutter.runApp(const MyApp());
}

class MyApp extends miniflutter.StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Widget Catalog'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _string1 = "Hello World!";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Text('Flutter', textAlign: TextAlign.center),
                ),
              ),
              SizedBox(width: 20, height: 30, child: const VerticalDivider()),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Text('Miniflutter', textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _ComparisonWidget(
            title: 'Text',
            flutterWidget: Text(_string1),
            miniflutterWidget: miniflutter.Text(_string1),
          ),
        ],
      ),
    );
  }
}

class _ComparisonWidget extends StatelessWidget {
  const _ComparisonWidget({
    required this.title,
    required this.flutterWidget,
    required this.miniflutterWidget,
  });

  final String title;

  final Widget flutterWidget;

  final Widget miniflutterWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Center(child: flutterWidget)),
            SizedBox(width: 20, height: 30, child: const VerticalDivider()),
            Expanded(child: Center(child: miniflutterWidget)),
          ],
        ),
      ],
    );
  }
}
