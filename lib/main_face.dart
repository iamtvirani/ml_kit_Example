import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_ml_vision/flutter_camera_ml_vision.dart';

class FindFacesPage extends StatefulWidget {
  FindFacesPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _FindFacesPageState createState() => _FindFacesPageState();
}

class _FindFacesPageState extends State<FindFacesPage> {
  List<Face> _faces = [];
  final _scanKey = GlobalKey<CameraMlVisionState>();
  CameraLensDirection cameraLensDirection = CameraLensDirection.back;
  FaceDetector detector =
  FirebaseVision.instance.faceDetector(FaceDetectorOptions(
    enableTracking: true,
    mode: FaceDetectorMode.accurate,
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ""),
      ),
      body: Column(
        children: [
          Expanded(
            child: SizedBox.expand(
              child: CameraMlVision<List<Face>>(
                key: _scanKey,
                cameraLensDirection: cameraLensDirection,
                detector: detector.processImage,
                overlayBuilder: (c) {
                  return CustomPaint(
                    painter: FaceDetectorPainter(
                      _scanKey.currentState?.cameraValue?.previewSize?.flipped ??
                          Size(100, 100),
                      _faces,
                      reflection:
                      cameraLensDirection == CameraLensDirection.back,
                    ),
                  );
                },
                onResult: (faces) {
                  if (faces == null || faces.isEmpty || !mounted) {
                    return;
                  }
                  setState(() {
                    _faces = [...faces];
                  });
                },
                onDispose: () {
                  detector.close();
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Faces detected: ${_faces.length}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.imageSize, this.faces, {this.reflection = false});

  final bool reflection;
  final Size imageSize;
  final List<Face> faces;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    for (final face in faces) {
      final faceRect =
      _reflectionRect(reflection, face.boundingBox, imageSize.width);
      canvas.drawRect(
        _scaleRect(
          rect: faceRect,
          imageSize: imageSize,
          widgetSize: size,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}

Rect _reflectionRect(bool reflection, Rect boundingBox, double width) {
  if (!reflection) {
    return boundingBox;
  }
  final centerX = width / 2;
  final left = ((boundingBox.left - centerX) * -1) + centerX;
  final right = ((boundingBox.right - centerX) * -1) + centerX;
  return Rect.fromLTRB(left, boundingBox.top, right, boundingBox.bottom);
}

Rect _scaleRect({
  required Rect rect,
  required Size imageSize,
  required Size widgetSize,
}) {
  final scaleX = widgetSize.width / imageSize.width;
  final scaleY = widgetSize.height / imageSize.height;

  final scaledRect = Rect.fromLTRB(
    rect.left.toDouble() * scaleX,
    rect.top.toDouble() * scaleY,
    rect.right.toDouble() * scaleX,
    rect.bottom.toDouble() * scaleY,
  );
  return scaledRect;
}
