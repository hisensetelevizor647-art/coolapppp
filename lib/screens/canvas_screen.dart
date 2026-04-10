import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({Key? key}) : super(key: key);

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  final List<List<Offset>> _strokes = [];
  final List<Offset> _currentStroke = [];
  Color _penColor = Colors.white;
  final double _strokeWidth = 3.0;
  RenderBox? _renderBox;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _renderBox = context.findRenderObject() as RenderBox?;
  }


  void _onPanUpdate(DragUpdateDetails details) {
    if (_renderBox == null) return;
    final localPosition = _renderBox!.globalToLocal(details.globalPosition);
    setState(() {
      _currentStroke.add(localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke.isNotEmpty) {
      setState(() {
        _strokes.add(List.from(_currentStroke));
        _currentStroke.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OleksandrAI Canvas'),
        backgroundColor: (isDark ? Colors.grey[900] : Colors.white),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: _penColorIcon,
            onSelected: (value) => setState(() {
              switch (value) {
                case 'white': _penColor = Colors.white; break;
                case 'black': _penColor = Colors.black; break;
                case 'blue': _penColor = Colors.blue; break;
                case 'red': _penColor = Colors.red; break;
                case 'green': _penColor = Colors.green; break;
              }
            }),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'white', child: Row(children: [Icon(Icons.circle, color: Colors.white), SizedBox(width: 8), Text('Білий')])),
              const PopupMenuItem(value: 'black', child: Row(children: [Icon(Icons.circle, color: Colors.black), SizedBox(width: 8), Text('Чорний')])),
              const PopupMenuItem(value: 'blue', child: Row(children: [Icon(Icons.circle, color: Colors.blue), SizedBox(width: 8), Text('Синій')])),
              const PopupMenuItem(value: 'red', child: Row(children: [Icon(Icons.circle, color: Colors.red), SizedBox(width: 8), Text('Червонний')])),
              const PopupMenuItem(value: 'green', child: Row(children: [Icon(Icons.circle, color: Colors.green), SizedBox(width: 8), Text('Зелений')])),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() {
              _strokes.clear();
              _currentStroke.clear();
            }),
          ),
        ],
      ),
      body: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: CustomPaint(
          painter: SignaturePainter(
            strokes: _strokes,
            currentStroke: _currentStroke,
            strokeColor: _penColor,
            strokeWidth: _strokeWidth,
          ),
          size: Size.infinite,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final data = CanvasPainterData(strokes: _strokes, width: context.size?.width ?? 0, height: context.size?.height ?? 0);
          final pictureRecorder = ui.PictureRecorder();
          final canvas = Canvas(pictureRecorder);
          final signer = SignaturePainter(
            strokes: _strokes,
            currentStroke: _currentStroke,
            strokeColor: _penColor,
            strokeWidth: _strokeWidth,
          );
          signer.paint(canvas, Size(data.width, data.height));
          final image = pictureRecorder.endRecording().toImageSync(data.width.toInt(), data.height.toInt());
          final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData == null) return;
          final pngBytes = byteData.buffer.asUint8List();

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Малюнок збережено! (${pngBytes.length} байт)')),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget get _penColorIcon {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: _penColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 1),
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color strokeColor;
  final double strokeWidth;

  SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    required this.strokeColor,
    required this.strokeWidth,
  });

  Paint _createPaint() => Paint()
    ..color = strokeColor
    ..strokeCap = StrokeCap.round
    ..strokeWidth = strokeWidth;

  void _drawStrokes(Canvas canvas, List<List<Offset>> strokesToDraw, Paint paint) {
    for (final stroke in strokesToDraw) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _createPaint();
    _drawStrokes(canvas, strokes, paint);
    _drawStrokes(canvas, [currentStroke], paint);
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class CanvasPainterData {
  static const String key = 'canvas_painter';
  final List<List<Offset>> strokes;
  final double width;
  final double height;

  CanvasPainterData({required this.strokes, required this.width, required this.height});

  factory CanvasPainterData.fromJson(Map<String, dynamic> json) {
    return CanvasPainterData(
      strokes: (json['strokes'] as List)
          .map((stroke) => (stroke as List)
              .map((point) => Offset(
                    (point['dx'] as num).toDouble(),
                    (point['dy'] as num).toDouble(),
                  ))
              .toList())
          .toList(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strokes': strokes
          .map((stroke) => stroke
              .map((point) => {'dx': point.dx, 'dy': point.dy})
              .toList())
          .toList(),
      'width': width,
      'height': height,
    };
  }
}