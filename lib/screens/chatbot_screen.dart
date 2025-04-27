import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text.trim();
    setState(() {
      _messages.insert(0, _ChatMessage(message: text, isUser: true));
    });
    _messageController.clear();
    _simulateBotResponse(text);
  }

  void _simulateBotResponse(String userMessage) {
    // محاكاة رد بسيط: يمكن استبداله بمنطق AI في المستقبل.
    final response = "رد: " + userMessage;
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _messages.insert(0, _ChatMessage(message: response, isUser: false));
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الشات بوت"),
      ),
      body: Column(
        children: [
          // قائمة الرسائل
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Container(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      msg.message,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          // حقل الإدخال وزر الإرسال
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "اكتب رسالتك...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Text("أرسل"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// فئة صغيرة لتمثيل الرسالة
class _ChatMessage {
  final String message;
  final bool isUser;
  _ChatMessage({required this.message, required this.isUser});
}
