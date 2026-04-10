import 'package:flutter/material.dart';
import 'dart:ui';

import '../widgets/sidebar_menu.dart';
import '../widgets/prompt_panel.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/welcome_chips.dart';
import '../widgets/assistant_setup_card.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/premium_widgets.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import '../services/widget_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  final FirebaseService _firebase = FirebaseService();
  final WidgetService _widgetService = WidgetService();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  Future<void> _handleSend(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _isLoading = true;
    });

    final aiResponse = await _apiService.sendMessage(text);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _messages.add({
          'isUser': false,
          'text': aiResponse.trim()
        });
      });
      // Persist to Firebase
      await _firebase.saveChatMessage(text, aiResponse.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
              leading: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset('assets/logo.png', fit: BoxFit.contain),
              ),
              title: const Text('OleksandrAI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.public),
                  onPressed: () {},
                ),
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
      endDrawer: const SidebarMenu(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 80),
            Expanded(
              child: _messages.isEmpty
                  ? _buildDashboard(context)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return ChatBubble(
                          text: msg['text'],
                          isUser: msg['isUser'],
                        );
                      },
                    ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                child: Row(
                  children: const [
                    SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text('OleksandrAI друкує...', style: TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            PromptPanel(onSend: _handleSend),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final healthData = _widgetService.getHealthData();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Header: logo + greeting
          Column(
            children: [
              const SizedBox(height: 8),
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image(image: AssetImage('assets/logo.png'), fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Чим я можу допомогти сьогодні?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // AI Status
              AiStatsWidget(
                status: 'Online',
                model: ApiService.selectedModel.name.toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Clock + Time/Timer row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_widgetService.isTimeEnabled())
                Expanded(child: const TimeTimerWidget()),
              if (_widgetService.isTimeEnabled()) const SizedBox(width: 12),
              if (_widgetService.isWeatherEnabled())
                const Expanded(child: WeatherWidget()),
            ],
          ),
          const SizedBox(height: 12),
          // Calendar + Health
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_widgetService.isCalendarEnabled())
                Expanded(child: const CalendarWidget()),
              if (_widgetService.isCalendarEnabled()) const SizedBox(width: 12),
              if (_widgetService.isHealthEnabled())
                Expanded(
                  child: HealthWidget(data: healthData),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Assistant Setup Card
          const AssistantSetupCard(),
          const SizedBox(height: 12),
          // Quick action chips
          WelcomeChipsList(onChipSelected: _handleSend),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
