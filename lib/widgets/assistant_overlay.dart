import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

import '../services/api_service.dart';
import '../services/widget_service.dart';

class AssistantOverlay extends StatefulWidget {
  const AssistantOverlay({Key? key}) : super(key: key);

  @override
  State<AssistantOverlay> createState() => _AssistantOverlayState();
}

class _AssistantOverlayState extends State<AssistantOverlay>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  final WidgetService _widgetService = WidgetService();

  String _response = '';
  bool _isLoading = false;
  bool _showResponse = false;
  late final AnimationController _animController;
  late final Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyzeScreen() async {
    if (!_widgetService.isAssistantScreenAnalysisEnabled()) {
      setState(() {
        _showResponse = true;
        _response = 'Аналіз екрана вимкнений у налаштуваннях.';
      });
      return;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      setState(() {
        _showResponse = true;
        _response =
            'На мобільному аналіз екрана запускається після скриншота. Зроби скриншот і надішли його в чат.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showResponse = true;
      _response = 'Аналізую екран...';
    });

    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/screen_capture.png';
      final captured = await ScreenCapturer.instance.capture(
        mode: CaptureMode.screen,
        imagePath: path,
        copyToClipboard: false,
      );

      if (captured?.imagePath == null) {
        setState(() {
          _response = 'Не вдалося зробити скриншот екрана.';
          _isLoading = false;
        });
        return;
      }

      final file = File(captured!.imagePath!);
      final analysis = await _apiService.analyzeScreen(file);
      setState(() {
        _response = analysis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Помилка аналізу екрана: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _isLoading = true;
      _showResponse = true;
      _response = 'Думаю...';
    });

    final result = await _apiService.sendMessage(text);
    if (!mounted) return;
    setState(() {
      _response = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(_slideAnim),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
            child: _buildPanel(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _analyzeScreen,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.screen_share_outlined,
                          size: 18, color: Colors.black54),
                      SizedBox(width: 8),
                      Text(
                        'Поділитися екраном у Live-чаті',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_showResponse)
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E2E5)),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : SingleChildScrollView(
                          child: Text(
                            _response,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                        ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E2E5)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Спитай OleksandrAI',
                          hintStyle:
                              TextStyle(color: Colors.black45, fontSize: 16),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Швидка дія',
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Colors.black54),
                    ),
                    IconButton(
                      tooltip: 'Мікрофон',
                      onPressed: () {},
                      icon: const Icon(Icons.mic_none, color: Colors.black54),
                    ),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 38,
                        height: 38,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF0F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.graphic_eq,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => FlutterOverlayWindow.closeOverlay(),
                  child: const Text('Закрити'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
