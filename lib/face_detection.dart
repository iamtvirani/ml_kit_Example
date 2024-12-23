import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FaceDetectionPage extends StatefulWidget {
  @override
  _FaceDetectionPageState createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  final picker = ImagePicker();
  File? _image;
  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector(
    FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableContours: true,
      minFaceSize: 0.1,
      mode: FaceDetectorMode.fast,
    ),
  );
  List<Face> _faces = [];
  bool _isLoading = false; // To track loading state

  // Function to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true; // Start loading
      });

      // Run face detection on the picked image
      await _detectFaces(_image!);
    }
  }

  // Function to detect faces in the image
  Future<void> _detectFaces(File image) async {
    final visionImage = FirebaseVisionImage.fromFile(image);
    final faces = await _faceDetector.processImage(visionImage);

    setState(() {
      _faces = faces;
      _isLoading = false; // Stop loading
    });
  }

  // Function to display detected faces information
  Widget _buildFaceInfo() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_faces.isEmpty) {
      return Center(child: Text('No faces detected'));
    }

    return ListView.builder(
      itemCount: _faces.length,
      itemBuilder: (context, index) {
        final face = _faces[index];
        return ListTile(
          title: Text('Face ${index + 1}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bounding box: ${face.boundingBox}'),
              if (face.smilingProbability != null)
                Text('Smiling probability: ${face.smilingProbability}'),
              if (face.leftEyeOpenProbability != null)
                Text('Left eye open probability: ${face.leftEyeOpenProbability}'),
              if (face.rightEyeOpenProbability != null)
                Text('Right eye open probability: ${face.rightEyeOpenProbability}'),
              Text('Head Euler Angle Y: ${face.headEulerAngleY}'),
              Text('Head Euler Angle Z: ${face.headEulerAngleZ}'),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(
                _image!,
                height: 250,
                width: 250,
              ),
            if (_image == null) Text('Pick an image from the gallery or camera'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: Text('Take a Photo'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: Text('Pick from Gallery'),
            ),
            Expanded(child: _buildFaceInfo()),
          ],
        ),
      ),
    );
  }
}
