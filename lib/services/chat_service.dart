import 'dart:async';
import '../models/chat_message.dart';

class ChatService {
  final _messagesController = StreamController<List<ChatMessage>>();
  final List<ChatMessage> _messages = [];

  Stream<List<ChatMessage>> get messages => _messagesController.stream;

  ChatService() {
    _messagesController.add(_messages);
  }

  void sendMessage(String message) {
    final userMessage = ChatMessage(message: message, isUser: true);
    _messages.add(userMessage);
    _messagesController.add(_messages);

    // Simulate bot response after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      final botResponse = ChatMessage(
        message: _generateBotResponse(message),
        isUser: false,
      );
      _messages.add(botResponse);
      _messagesController.add(_messages);
    });
  }

  String _generateBotResponse(String userMessage) {
    // This is a simple response generation. In a real app, you'd integrate with an AI service
    final responses = [
      "I understand you're asking about $userMessage. How can I help you further?",
      "That's an interesting question about $userMessage. Let me help you with that.",
      "I'm here to assist you with $userMessage. What specific information do you need?",
    ];
    return responses[DateTime.now().millisecondsSinceEpoch % responses.length];
  }

  void dispose() {
    _messagesController.close();
  }
} 