import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class RealChat extends StatefulWidget {
  const RealChat({super.key});

  @override
  State<RealChat> createState() => _RealChatState();
}

class _RealChatState extends State<RealChat> {
  final channel = IOWebSocketChannel.connect("https://real-time:3000");
  final TextEditingController _controller = TextEditingController();
  final List<String> messages = [];

  @override
  void initState() {
    super.initState();

    // الاستماع للرسائل القادمة من السيرفر
    channel.stream.listen((event) {
      try {
        final msg = jsonDecode(event);
        // setState(() {
          messages.add("${msg['from'] ?? 'Server'}: ${msg['text']}");
        // });
      } catch (_) {
        // في حال الرسالة ليست بصيغة JSON
        setState(() {
          messages.add(event.toString());
        });
      }
    });
  }

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final data = jsonEncode({
      'type': 'message',
      'text': text,
      'from': "App",
    });
    channel.sink.add(data);

        setState(() {
      messages.add("Me: $text");
    });
    _controller.clear();
  }

  void sendMessage1() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final data = jsonEncode({
      'type': 'message',
      'text': text,
      'from': "App",
    });
    channel.sink.add(data);

        setState(() {
      messages.add("Me: $text");
    });
    _controller.clear();
  }

  @override
  void dispose() {
    channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Chat 💬'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // عرض الرسائل
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.startsWith('Me:');

                return Align(
                  alignment:
                  isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.blueAccent.withOpacity(0.8)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // حقل الإدخال وزر الإرسال
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "اكتب رسالتك...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
