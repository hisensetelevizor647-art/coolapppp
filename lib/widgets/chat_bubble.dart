import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme/app_theme.dart';
import '../utils/image_actions.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl = _extractImageUrl(text);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser)
            _buildAgentHeader(isDark),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
            decoration: BoxDecoration(
              color: isUser 
                  ? AppTheme.bgMessageUserLight 
                  : (isDark ? const Color(0xFF1F2937) : Colors.white),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusStandard),
              border: !isUser 
                  ? Border.all(color: isDark ? AppTheme.geminiBorderDark : AppTheme.geminiBorderLight) 
                  : null,
              boxShadow: !isUser ? AppTheme.softShadow : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Render Markdown Content (including images)
                MarkdownBody(
                  data: text,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                      fontSize: 15,
                      height: 1.5,
                    ),
                    img: const TextStyle(fontSize: 0), // Use custom img builder if needed, but default works
                  ),
                  imageBuilder: (uri, title, alt) {
                    return ClipRRect(
                       borderRadius: BorderRadius.circular(12),
                       child: Image.network(uri.toString(), fit: BoxFit.cover),
                    );
                  },
                ),
                
                // --- Action Buttons ---
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isUser) ...[
                      _buildActionBtn(Icons.copy_all_outlined, isDark, label: "Копіювати", onTap: () {
                        Clipboard.setData(ClipboardData(text: text));
                      }),
                      const SizedBox(width: 8),
                      // Image Specific Actions
                      if (imageUrl != null) ...[
                        _buildActionBtn(Icons.download_for_offline_outlined, isDark, 
                          label: "Завантажити", 
                          onTap: () => ImageActions.downloadImage(imageUrl)),
                        const SizedBox(width: 8),
                        _buildActionBtn(Icons.open_in_new, isDark, 
                          label: "У веб", 
                          onTap: () => ImageActions.viewInWeb(imageUrl)),
                        const SizedBox(width: 8),
                      ],
                      _buildActionBtn(Icons.thumb_up_outlined, isDark, onTap: () {
                        // TODO: Send feedback to backend
                      }),
                    ],
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.psychology, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            'OleksandrAI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, bool isDark, {String? label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDark ? Colors.white38 : Colors.black38, size: 14),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }

  String? _extractImageUrl(String text) {
    final regExp = RegExp(r'!\[.*?\]\((.*?)\)');
    final match = regExp.firstMatch(text);
    return match?.group(1);
  }
}
