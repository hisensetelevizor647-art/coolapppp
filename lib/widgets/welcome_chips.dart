import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WelcomeChipsList extends StatelessWidget {
  final Function(String) onChipSelected;

  const WelcomeChipsList({Key? key, required this.onChipSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      alignment: WrapAlignment.center,
      children: [
        _buildChip(Icons.chat_bubble_outline, 'AI Чат', context),
        _buildChip(Icons.search, 'Olewser Search', context),
        _buildChip(Icons.image_outlined, 'Generate Image', context),
        _buildChip(Icons.code, 'Code Studio', context),
        _buildChip(Icons.translate, 'Translator', context),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label, BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChipSelected(label),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusPill),
            boxShadow: AppTheme.welcomeChipShadow,
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon, 
                size: 20, 
                color: isDark ? Colors.white : const Color(0xFF111827)
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
