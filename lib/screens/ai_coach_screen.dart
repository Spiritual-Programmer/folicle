import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:folicle/models/storage.dart' as storage;
import 'package:folicle/services/weekly_history.dart';
import 'package:folicle/services/trigger_calculator.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeOpenAI();
    _addWelcomeMessage();
  }

  void _initializeOpenAI() {
    // Load API key from environment variable
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    OpenAI.apiKey = apiKey;
    _isInitialized = apiKey.isNotEmpty;
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add({
        'role': 'assistant',
        'content':
            'Hi! I\'m your personal hirsutism coach. I have access to your assessment data and weekly tracking insights. Ask me how I can help you manage.',
      });
    });
  }

  String _buildUserContext() {
    final weekCount = WeeklyHistory.getWeekCount();
    final context = StringBuffer();

    context.writeln('User Context:');
    context.writeln(
      '- Assessment completed: ${storage.appDataBox.get(storage.StorageKeys.isAssessmentComplete, defaultValue: false)}',
    );
    context.writeln('- Weeks tracked: $weekCount');

    // Include initial assessment data
    final hairGrowthAreas =
        storage.appDataBox.get(
              storage.StorageKeys.hairGrowthAreas,
              defaultValue: <String>[],
            )
            as List;
    final treatments =
        storage.appDataBox.get(
              storage.StorageKeys.treatments,
              defaultValue: <String>[],
            )
            as List;
    final conditions =
        storage.appDataBox.get(
              storage.StorageKeys.conditions,
              defaultValue: <String>[],
            )
            as List;
    final hairRemovalMethods =
        storage.appDataBox.get(
              storage.StorageKeys.hairRemovalMethods,
              defaultValue: <String>[],
            )
            as List;

    if (hairGrowthAreas.isNotEmpty) {
      context.writeln('\nInitial Assessment Data:');
      context.writeln('- Hair growth areas: ${hairGrowthAreas.join(", ")}');
      if (treatments.isNotEmpty) {
        context.writeln('- Previous treatments: ${treatments.join(", ")}');
      }
      if (conditions.isNotEmpty) {
        context.writeln('- Known conditions: ${conditions.join(", ")}');
      }
      if (hairRemovalMethods.isNotEmpty) {
        context.writeln(
          '- Hair removal methods: ${hairRemovalMethods.join(", ")}',
        );
      }
    }

    if (weekCount >= 3) {
      final history = WeeklyHistory.getAllHistory();
      final correlations = TriggerCalculator.correlationsAgainstHairGrowth(
        sugar: history.sugar,
        stress: history.stress,
        sleep: history.sleep,
        exercise: history.exercise,
        hairGrowth: history.hairGrowth,
      );

      final ranked = TriggerCalculator.rankByAbsoluteStrength(correlations);

      context.writeln('\nTrigger Analysis (1-week lagged correlation):');
      for (var entry in ranked) {
        if (!entry.value.isNaN) {
          final strength = (entry.value.abs() * 100).toStringAsFixed(0);
          final direction = entry.value > 0 ? 'increases' : 'decreases';
          context.writeln(
            '- ${entry.key}: $strength% correlation ($direction hirsutism)',
          );
        }
      }
    }

    return context.toString();
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty || !_isInitialized) return;

    setState(() {
      _messages.add({'role': 'user', 'content': message});
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final systemContext = _buildUserContext();

      final chatMessages = [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              '''You are an expert hirsutism coach for women. You provide evidence-based, 
              empathetic advice about managing hirsutism through lifestyle, diet, and medical options.
              
              $systemContext
              
              Guidelines:
              - Be supportive and empathetic
              - Provide actionable, science-backed advice
              - Reference the user's specific trigger data when relevant
              - Suggest lifestyle changes, dietary adjustments, and when to consult doctors
              - Never diagnose or replace medical advice - always recommend consulting healthcare providers for medical decisions
              - Keep responses extremely concise(extremely short responses) and to the point but also very readable.
              - Use emojis sparingly to enhance tone
              ''',
            ),
          ],
        ),
        ..._messages.map(
          (msg) => OpenAIChatCompletionChoiceMessageModel(
            role: msg['role'] == 'user'
                ? OpenAIChatMessageRole.user
                : OpenAIChatMessageRole.assistant,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                msg['content']!,
              ),
            ],
          ),
        ),
      ];

      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: chatMessages,
        temperature: 0.7,
        maxTokens: 500,
      );

      final assistantMessage =
          response.choices.first.message.content?.first.text ??
          'Sorry, I couldn\'t generate a response.';

      setState(() {
        _messages.add({'role': 'assistant', 'content': assistantMessage});
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'Sorry, I encountered an error: ${e.toString()}',
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Coach'), centerTitle: true),
      body: Column(
        children: [
          if (!_isInitialized)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.orange[100],
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[900]),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'OpenAI API key not configured. Add your key to use the AI Coach.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['content']!,
                      style: TextStyle(
                        color: isUser
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask about hirsutism management...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                      enabled: _isInitialized && !_isLoading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isInitialized && !_isLoading
                        ? () => _sendMessage(_controller.text)
                        : null,
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
