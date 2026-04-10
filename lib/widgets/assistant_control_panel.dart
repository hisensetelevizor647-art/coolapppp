import 'package:flutter/material.dart';
import 'dart:ui';

class AssistantControlPanel extends StatelessWidget {
  final bool showSubtitles;
  final bool audioEnabled;
  final VoidCallback onToggleSubtitles;
  final VoidCallback onToggleAudio;
  final VoidCallback onClose;

  const AssistantControlPanel({
    Key? key,
    required this.showSubtitles,
    required this.audioEnabled,
    required this.onToggleSubtitles,
    required this.onToggleAudio,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildControlBtn(
                showSubtitles ? Icons.subtitles : Icons.subtitles_off,
                onToggleSubtitles,
                "Субтитри",
                showSubtitles,
              ),
              _buildControlBtn(
                audioEnabled ? Icons.volume_up : Icons.volume_off,
                onToggleAudio,
                "Голос",
                audioEnabled,
              ),
              _buildControlBtn(
                Icons.close,
                onClose,
                "Вихід",
                false,
                isDanger: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlBtn(IconData icon, VoidCallback onTap, String label, bool isActive, {bool isDanger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive 
                  ? Colors.blueAccent.withOpacity(0.2) 
                  : (isDanger ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05)),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? Colors.blueAccent : (isDanger ? Colors.redAccent.withOpacity(0.5) : Colors.white10),
              ),
            ),
            child: Icon(icon, color: isDanger ? Colors.redAccent : (isActive ? Colors.blueAccent : Colors.white54), size: 18),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
