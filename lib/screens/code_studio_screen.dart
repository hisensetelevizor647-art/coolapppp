import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/python.dart';

class CodeStudioScreen extends StatefulWidget {
  const CodeStudioScreen({Key? key}) : super(key: key);

  @override
  State<CodeStudioScreen> createState() => _CodeStudioScreenState();
}

class _CodeStudioScreenState extends State<CodeStudioScreen> {
  late CodeController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: "// Write your code here...\n\nfunction hello() {\n  console.log('Hello OleksandrAI');\n}",
      language: javascript,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Studio'),
        backgroundColor: Colors.black,
        actions: [
          PopupMenuButton<dynamic>(
             onSelected: (lang) => setState(() => _codeController.language = lang),
             itemBuilder: (context) => [
                PopupMenuItem(value: dart, child: const Text("Dart")),
                PopupMenuItem(value: javascript, child: const Text("JavaScript")),
                PopupMenuItem(value: python, child: const Text("Python")),
             ],
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF1E1E1E),
        child: SingleChildScrollView(
          child: CodeTheme(
            data: CodeThemeData(styles: const {}), // Standard Dark Theme
            child: CodeField(
              controller: _codeController,
              textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Mock execution or link to remote runner
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Виконання коду у розробці...')));
        },
        label: const Text('Run Code'),
        icon: const Icon(Icons.play_arrow),
        backgroundColor: Colors.green,
      ),
    );
  }
}
