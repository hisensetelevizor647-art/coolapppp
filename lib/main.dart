import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/chat_screen.dart';
import 'theme/app_theme.dart';
import 'services/widget_service.dart';
import 'widgets/assistant_overlay.dart';

// The overlay entry point — called by flutter_overlay_window
@pragma('vm:entry-point')
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC9LEhBI--8tzwRy61XZbafupcP0NcnIi4",
      appId: "1:1034187669203:web:dfff76fe755ccf9cb15e26",
      messagingSenderId: "1034187669203",
      projectId: "oleksandrai-f5565",
      storageBucket: "oleksandrai-f5565.firebasestorage.app",
    ),
  );
  await WidgetService().init();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AssistantOverlay(),
  ));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC9LEhBI--8tzwRy61XZbafupcP0NcnIi4",
      appId: "1:1034187669203:web:dfff76fe755ccf9cb15e26",
      messagingSenderId: "1034187669203",
      projectId: "oleksandrai-f5565",
      storageBucket: "oleksandrai-f5565.firebasestorage.app",
    ),
  );

  try {
    await WidgetService().init();
  } catch (e) {
    debugPrint('Failed to initialize WidgetService: $e');
  }

  runApp(const OleksandrAIApp());
}

class OleksandrAIApp extends StatelessWidget {
  const OleksandrAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OleksandrAI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const ChatScreen(),
    );
  }
}
