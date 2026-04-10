import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/api_service.dart';

class TestsScreen extends StatefulWidget {
  const TestsScreen({Key? key}) : super(key: key);

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  CameraController? _controller;
  bool _isProcessing = false;
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _scanAndGenerate() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String prompt = "На основі цього тексту створи тест з 5 питаннями (варіанти відповіді А, Б, В, Г):\n\n${recognizedText.text}";
      
      final aiResponse = await _api.sendMessage(prompt);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Згенерований тест'),
            content: SingleChildScrollView(child: Text(aiResponse)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрити')),
            ],
          ),
        );
      }
    } catch (e) {
      print("OCR Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tests Mode (OCR)'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.large(
                onPressed: _isProcessing ? null : _scanAndGenerate,
                backgroundColor: Colors.blueAccent,
                child: const Icon(Icons.psychology, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
