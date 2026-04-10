import 'package:flutter/material.dart';

class OrbitingVisualizer extends StatefulWidget {
  final bool isListening;

  const OrbitingVisualizer({Key? key, required this.isListening}) : super(key: key);

  @override
  State<OrbitingVisualizer> createState() => _OrbitingVisualizerState();
}

class _OrbitingVisualizerState extends State<OrbitingVisualizer> with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isListening) {
      return _buildStaticCircle();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        _buildRipple(0.0),
        _buildRipple(0.4),
        _buildRipple(0.8),
        _buildStaticCircle(),
      ],
    );
  }

  Widget _buildRipple(double delay) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        double value = (_pulseController.value + delay) % 1.0;
        double radius = 100 + (100 * value);
        double opacity = (1 - value) * 0.4;

        return Container(
          width: radius,
          height: radius,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blueAccent.withOpacity(opacity), width: 2),
            color: Colors.blueAccent.withOpacity(opacity * 0.2),
          ),
        );
      },
    );
  }

  Widget _buildStaticCircle() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blueAccent,
        boxShadow: [
          BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)
        ],
      ),
      child: Icon(
        widget.isListening ? Icons.mic : Icons.mic_none,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}
