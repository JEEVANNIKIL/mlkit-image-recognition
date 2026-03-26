import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

void main() {
  runApp(const ImageRecognitionApp());
}

class ImageRecognitionApp extends StatelessWidget {
  const ImageRecognitionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ML Kit Image Recognition',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const ImageLabelingScreen(),
    );
  }
}

class ImageLabelingScreen extends StatefulWidget {
  const ImageLabelingScreen({Key? key}) : super(key: key);

  @override
  State<ImageLabelingScreen> createState() =>
      _ImageLabelingScreenState();
}

class _ImageLabelingScreenState
    extends State<ImageLabelingScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  late ImageLabeler _labeler;

  List<ImageLabel> _labels = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _labeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.6));
  }

  @override
  void dispose() {
    _labeler.close();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    if (file == null) return;

    setState(() {
      _image = File(file.path);
      _loading = true;
      _labels = [];
    });

    final inputImage = InputImage.fromFile(_image!);
    final result = await _labeler.processImage(inputImage);

    setState(() {
      _labels = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Recognition"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          _image == null
              ? const Text("No Image Selected")
              : Image.file(_image!, height: 200),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => pickImage(ImageSource.camera),
                child: const Text("Camera"),
              ),
              ElevatedButton(
                onPressed: () => pickImage(ImageSource.gallery),
                child: const Text("Gallery"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _loading
              ? const CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    itemCount: _labels.length,
                    itemBuilder: (context, index) {
                      final label = _labels[index];
                      return ListTile(
                        title: Text(label.label),
                        trailing: Text(
                            "${(label.confidence * 100).toStringAsFixed(1)}%"),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
