import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

enum AiModel { fast3, fast25, thinking, jules, search }
enum ImageModel { fast, ultra }

class ApiService {
  // --- API Keys ---
  static const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String _siliconFlowApiKey = String.fromEnvironment('SILICONFLOW_API_KEY');
  static const String _searchApiKey = String.fromEnvironment('SEARCH_API_KEY');

  static AiModel selectedModel = AiModel.fast3;
  static ImageModel selectedImageModel = ImageModel.fast;
  static bool thinkingModeActive = false;

  Future<String> sendMessage(String text) async {
    if (text.toLowerCase().startsWith('намалюй') || text.toLowerCase().contains('generate image')) {
      return _generateImage(text);
    }
    if (selectedModel == AiModel.search) return _performWebSearch(text);
    if (thinkingModeActive) return _sendToThinkingModel(text);

    switch (selectedModel) {
      case AiModel.fast3:
        return _sendToOpenAI(text, model: "gpt-4o-mini");
      case AiModel.fast25:
        return _sendToGemini(text, model: "gemini-1.5-flash");
      case AiModel.jules:
        return "Jules Agent Mode is currently initializing...";
      default:
        return _sendToGemini(text);
    }
  }

  /// Analyze a screenshot with Gemini Vision
  Future<String> analyzeScreen(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey');

      final payload = {
        "contents": [
          {
            "parts": [
              {
                "inline_data": {
                  "mime_type": "image/png",
                  "data": base64Image
                }
              },
              {
                "text": "Проаналізуй що зображено на цьому скріншоті екрану. Опиши контент, дій і можливу допомогу яку ти можеш надати. Відповідай по-українськи."
              }
            ]
          }
        ]
      };

      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? 'Зображення не вдалося проаналізувати.';
      }
      return 'Помилка аналізу: ${response.statusCode}';
    } catch (e) {
      return 'Помилка аналізу екрану: $e';
    }
  }

  Future<String> _sendToGemini(String text, {String model = "gemini-1.5-flash"}) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_geminiApiKey');
    final payload = {"contents": [{"parts": [{"text": text}]}]};
    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? '';
      }
      return 'Помилка Gemini: ${response.statusCode}';
    } catch (e) {
      return 'Помилка зʼєднання: $e';
    }
  }

  Future<String> _sendToOpenAI(String text, {String model = "gpt-4o-mini"}) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final payload = {"model": model, "messages": [{"role": "user", "content": text}]};
    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_openAiApiKey'},
          body: jsonEncode(payload));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? '';
      }
      return 'Помилка OpenAI: ${response.statusCode}';
    } catch (e) {
      return 'Помилка зʼєднання: $e';
    }
  }

  Future<String> _sendToThinkingModel(String text) async {
    const String systemPrompt = "You are OleksandrAi (Thinking Mode). Analyze deeply and provide comprehensive response.";
    final String fullPrompt = "$systemPrompt\n\n$text";
    final url = Uri.parse('https://text.pollinations.ai/${Uri.encodeComponent(fullPrompt)}?model=openai');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return response.body;
      return "Помилка Thinking Mode";
    } catch (e) {
      return "Помилка: $e";
    }
  }

  Future<String> _generateImage(String prompt) async {
    if (selectedImageModel == ImageModel.ultra) return _generateUltraImage(prompt);
    final encodedPrompt = Uri.encodeComponent(prompt);
    final url = 'https://image.pollinations.ai/prompt/$encodedPrompt?model=flux&nologo=true';
    return 'Згенероване зображення:\n\n![Image]($url)';
  }

  Future<String> _generateUltraImage(String prompt) async {
    final url = Uri.parse('https://api.siliconflow.com/v1/images/generations');
    final payload = {"model": "black-forest-labs/FLUX.1-dev", "prompt": prompt, "image_size": "1024x1024"};
    try {
      final response = await http.post(url,
          headers: {'Authorization': 'Bearer $_siliconFlowApiKey', 'Content-Type': 'application/json'},
          body: jsonEncode(payload));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['data'][0]['url'];
        return 'Згенероване зображення (Ultra):\n\n![Image]($imageUrl)';
      }
      return 'Помилка Ultra Image: ${response.statusCode}';
    } catch (e) {
      return 'Помилка генерації Ultra: $e';
    }
  }

  Future<String> _performWebSearch(String query) async {
    final url = Uri.parse('https://www.searchapi.io/api/v1/search?engine=google&q=${Uri.encodeComponent(query)}&api_key=$_searchApiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['organic_results'] ?? [];
        if (results.isEmpty) return "Нічого не знайдено за вашим запитом.";
        String buffer = "Результати пошуку:\n\n";
        for (var i = 0; i < results.length && i < 3; i++) {
          buffer += "### ${results[i]['title']}\n${results[i]['snippet']}\n[Читати далі](${results[i]['link']})\n\n";
        }
        return buffer;
      }
      return "Помилка пошуку";
    } catch (e) {
      return "Помилка мережі при пошуку";
    }
  }
}
