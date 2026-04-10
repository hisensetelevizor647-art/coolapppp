import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../services/android_settings_service.dart';
import '../services/widget_service.dart';

class AssistantSetupCard extends StatefulWidget {
  const AssistantSetupCard({Key? key}) : super(key: key);

  @override
  State<AssistantSetupCard> createState() => _AssistantSetupCardState();
}

class _AssistantSetupCardState extends State<AssistantSetupCard> {
  final AndroidSettingsService _androidSettings = AndroidSettingsService();
  final WidgetService _widgetService = WidgetService();

  late AssistantMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = _widgetService.getAssistantMode();
  }

  Future<void> _openAssistantSettings() async {
    await _androidSettings.openVoiceAssistantSettings();
  }

  Future<void> _requestOverlayPermissionAndOpen() async {
    final granted = await AndroidSettingsService.ensureOverlayPermission();
    if (!granted) return;

    if (!_widgetService.isAssistantOverlayEnabled()) return;

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      overlayTitle: 'OleksandrAI',
      overlayContent: 'Асистент активний',
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.auto,
      width: WindowSize.matchParent,
      height: WindowSize.matchParent,
    );
  }

  String _modeLabel(AssistantMode mode) {
    switch (mode) {
      case AssistantMode.classicChat:
        return 'Класичний чат';
      case AssistantMode.overlayLive:
        return 'Live-оверлей';
      case AssistantMode.defaultAssistant:
        return 'Системний асистент';
    }
  }

  @override
  Widget build(BuildContext context) {
    _mode = _widgetService.getAssistantMode();
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Налаштування асистента',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Увімкни режим як на Gemini: плаваюча панель поверх інших додатків, '
            'аналіз екрана та швидкий виклик асистента.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 10),
          Text(
            'Обраний режим: ${_modeLabel(_mode)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SetupButton(
                  icon: Icons.layers_outlined,
                  label: 'Поверх додатків',
                  onTap: _requestOverlayPermissionAndOpen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SetupButton(
                  icon: Icons.assistant,
                  label: 'Асистент ОС',
                  onTap: _openAssistantSettings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetupButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SetupButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
