import 'package:example/barcode_scan.dart';
import 'package:example/face_detection.dart';
import 'package:example/main_face.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ML kit example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> data = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              final barcode = await Navigator.of(context).push<Barcode>(
                MaterialPageRoute(
                  builder: (c) {
                    return ScanPage();
                  },
                ),
              );
              if (barcode == null) {
                return;
              }
              setState(() {
                data.add(barcode.displayValue ?? "");
              });
            },
            child: Text('Scan product'),
          ),
          ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FaceDetectionPage(),
                  )),
              child: Text('Scan Face')),
          ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FindFacesPage(),
                  )),
              child: Text('Find Face')),
          Expanded(
            child: ListView(
              children: data.map((d) => Text(d)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
