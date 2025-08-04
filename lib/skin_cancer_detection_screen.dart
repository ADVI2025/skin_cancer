import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';

class SkinCancerDetectionScreen extends StatefulWidget {
  const SkinCancerDetectionScreen({super.key});

  @override
  State<SkinCancerDetectionScreen> createState() => _SkinCancerDetectionScreenState();
}

class _SkinCancerDetectionScreenState extends State<SkinCancerDetectionScreen> {
  File? _image;
  List? _output;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/mobilenet_softmax_model.tflite",
        labels: "assets/labels.txt",
      );
      print("Successfully Loaded");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Skin Cancer Detection',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _image == null
                ? Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: const Center(
                child: Text(
                  "No image selected",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_image!),
            ),
            const SizedBox(height: 16),
            _output == null
                ? const Text(
              "No prediction yet.",
              style: TextStyle(fontSize: 16),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: _output!.length,
                itemBuilder: (context, index) {
                  var prediction = _output![index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.medical_services_outlined, color: Colors.indigo),
                      title: Text(
                        prediction['label'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Confidence: ${prediction['confidence'] is double ? (prediction['confidence'] * 100).toStringAsFixed(2) : "N/A"}%',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image_search),
          label: const Text("Select Image from Gallery"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File imageFile = File(image.path);
      setState(() {
        _image = imageFile;
      });
      await predictDisease(imageFile);
    }
  }

  Future<void> predictDisease(File imageFile) async {
    const double check_threshold = 0.3210;

    var recognition = await Tflite.runModelOnImage(
      path: imageFile.path,
      numResults: 2,
      threshold: 0.0,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    if (recognition != null && recognition.isNotEmpty) {
      print("Raw predictions: $recognition");

      // Try to find the malignant class
      var malignantResult = recognition.firstWhere(
            (res) => res['label'].toString().toLowerCase().contains('malignant'),
        orElse: () => null,
      );

      double malignantConfidence = malignantResult != null
          ? malignantResult['confidence'] as double
          : 0.0;

      String predictedLabel =
      malignantConfidence >= check_threshold ? 'Malignant' : 'Benign';

      setState(() {
        _output = [
          {
            'label': predictedLabel,
            'confidence': malignantConfidence,
          }
        ];
      });

      print("Predicted: $predictedLabel with ${(malignantConfidence * 100).toStringAsFixed(2)}% confidence");
    } else {
      setState(() {
        _output = null;
      });
      print("No prediction results.");
    }
  }

}
