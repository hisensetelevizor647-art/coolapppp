import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../screens/voice_screen.dart';
import '../screens/tests_screen.dart';
import '../screens/canvas_screen.dart';
import '../screens/code_studio_screen.dart';
import '../screens/widget_settings_screen.dart';
import '../theme/app_theme.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({Key? key}) : super(key: key);

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  final FirebaseService _firebase = FirebaseService();

  void _showNewFolderDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Створити нову папку'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Назва папки'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.pop(context);
              },
              child: const Text('Скасувати'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _firebase.createFolder(controller.text);
                }
                controller.dispose();
                Navigator.pop(context);
              },
              child: const Text('Створити'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF111111), // Matte Black like Web
      elevation: 0,
      width: 280,
      child: SafeArea(
        child: Column(
          children: [
            // Header with Logo (Web style)
            _buildHeader(context),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildItem(Icons.add_circle_outline, 'Новий чат', () => Navigator.pop(context)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: Divider(color: Colors.white10),
                  ),

                  // Режими
                  _buildSectionTitle('РЕЖИМИ'),
                  _buildItem(Icons.graphic_eq, 'Voice Mode', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceScreen()));
                  }),
                  _buildItem(Icons.psychology_outlined, 'Tests Mode', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TestsScreen()));
                  }),
                  _buildItem(Icons.code, 'Code Studio', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CodeStudioScreen()));
                  }),
                  _buildItem(Icons.brush_outlined, 'Canvas', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CanvasScreen()));
                  }),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: Divider(color: Colors.white10),
                  ),

                  // Папки
                  _buildSectionTitle('ПАПКИ'),
                  _buildFolderExpansionTile(),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: Divider(color: Colors.white10),
                  ),

                  // Профіль
                  _buildItem(Icons.history, 'Історія', () {}),
                  _buildItem(Icons.settings_outlined, 'Налаштування', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WidgetSettingsScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  _buildItem(Icons.logout, 'Вийти', () => _firebase.signOut(), color: Colors.redAccent.withOpacity(0.8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          // Real Logo (32x32)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'OleksandrAI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.menu_open, color: Colors.white54, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white30,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, VoidCallback onTap, {Color color = Colors.white70}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          title,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        onTap: onTap,
        dense: true,
        horizontalTitleGap: -4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        hoverColor: Colors.white.withOpacity(0.05),
      ),
    );
  }

  Widget _buildFolderExpansionTile() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.only(right: 8),
        leading: const Icon(Icons.folder_open, color: Colors.amberAccent, size: 20),
        title: const Text('Збережені папки', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        trailing: IconButton(
          icon: const Icon(Icons.add, color: Colors.white30, size: 16),
          onPressed: _showNewFolderDialog,
        ),
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firebase.getFolders(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final folders = snapshot.data!.docs;
              
              if (folders.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Порожньо', style: TextStyle(color: Colors.white24, fontSize: 11)),
                );
              }

              return Container(
                margin: const EdgeInsets.only(left: 12, right: 12),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusPanel),
                ),
                child: Column(
                  children: folders.map((doc) => _buildFolderItem(doc)).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFolderItem(DocumentSnapshot doc) {
    final name = doc['name'] ?? 'Без назви';
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      title: Text(name, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 14, color: Colors.white24),
        onPressed: () => _firebase.deleteFolder(doc.id),
      ),
      onTap: () {},
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
