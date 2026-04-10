import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class PromptPanel extends StatefulWidget {
  final Function(String) onSend;

  const PromptPanel({Key? key, required this.onSend}) : super(key: key);

  @override
  State<PromptPanel> createState() => _PromptPanelState();
}

class _PromptPanelState extends State<PromptPanel> {
  final TextEditingController _controller = TextEditingController();
  AiModel _currentAiModel = ApiService.selectedModel;
  bool _isThinkingActive = ApiService.thinkingModeActive;

  void _submit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSend(_controller.text);
      _controller.clear();
    }
  }

  void _toggleThinking() {
    setState(() {
      _isThinkingActive = !_isThinkingActive;
      ApiService.thinkingModeActive = _isThinkingActive;
    });
  }

  void _changeModel(AiModel model) {
    setState(() {
      _currentAiModel = model;
      ApiService.selectedModel = model;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Model Chips & Thinking Toggle (Web style)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildModelChip("Fast 3.0", AiModel.fast3, isDark),
                _buildModelChip("2.5 Fast", AiModel.fast25, isDark),
                _buildModelChip("Search", AiModel.search, isDark),
                _buildModelChip("Jules", AiModel.jules, isDark),
                const SizedBox(width: 8),
                _buildThinkingToggle(isDark),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 2. Main Input Wrapper (Pixel-perfect web style)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusWrapper),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppTheme.geminiInputDark.withOpacity(0.85) 
                      : AppTheme.geminiInputLight.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusWrapper),
                  border: Border.all(
                    color: isDark ? AppTheme.geminiBorderDark : AppTheme.geminiBorderLight,
                  ),
                  boxShadow: isDark ? AppTheme.inputShadowDark : AppTheme.inputShadowLight,
                ),
                child: Column(
                  children: [
                    // Textarea
                    TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 8,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: _getHintText(),
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white30 : Colors.black45,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      ),
                    ),

                    // Toolbar (Web layout: Left tools, Right actions)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Row(
                        children: [
                          // Left Tools
                          _buildIconButton(Icons.add, isDark, isPlus: true),
                          _buildIconButton(Icons.camera_alt_outlined, isDark),
                          _buildIconButton(Icons.image_outlined, isDark),
                          
                          const Spacer(),
                          
                          // Right Actions
                          _buildIconButton(Icons.mic_none, isDark, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          _buildSendButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelChip(String label, AiModel model, bool isDark) {
    bool isSelected = _currentAiModel == model;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: GestureDetector(
        onTap: () => _changeModel(model),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : (isDark ? Colors.white12 : Colors.black.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusPill),
            border: Border.all(color: isSelected ? Colors.white24 : Colors.transparent),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingToggle(bool isDark) {
    return GestureDetector(
      onTap: _toggleThinking,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: _isThinkingActive 
            ? const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)])
            : null,
          color: _isThinkingActive ? null : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusPill),
        ),
        child: Row(
          children: [
            Icon(Icons.psychology, size: 14, color: _isThinkingActive ? Colors.white : (isDark ? Colors.white54 : Colors.black54)),
            const SizedBox(width: 4),
            Text(
              "Thinking",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _isThinkingActive ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, bool isDark, {bool isPlus = false, Color? color}) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: isPlus 
            ? (isDark ? Colors.white10 : Colors.black.withOpacity(0.03)) 
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? (isDark ? Colors.white70 : Colors.black54), size: 18),
        onPressed: () {},
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        splashRadius: 20,
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
        onPressed: _submit,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }

  String _getHintText() {
    switch (_currentAiModel) {
      case AiModel.search: return "Пошук в Інтернеті...";
      case AiModel.jules: return "Завдання для Агента...";
      default: return "Повідомлення OleksandrAI...";
    }
  }
}
