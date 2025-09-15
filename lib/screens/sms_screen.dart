import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SmsScreen extends StatefulWidget {
  const SmsScreen({super.key});

  @override
  State<SmsScreen> createState() => _SmsScreenState();
}

class _SmsScreenState extends State<SmsScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    String userMessage = _controller.text.trim();
    setState(() {
      messages.add({"text": userMessage, "isUser": true});
    });
    _controller.clear();

    // Mock reply
    Future.delayed(const Duration(milliseconds: 800), () {
      String reply = _getDummyReply(userMessage);
      setState(() {
        messages.add({"text": reply, "isUser": false});
      });
    });
  }

  String _getDummyReply(String msg) {
    if (msg.toUpperCase().contains("12A")) {
      return "🚌 Bus 12A → Central Mall\nETA: Market Road 7 min, Station 15 min";
    } else if (msg.toUpperCase().contains("18B")) {
      return "🚌 Bus 18B → Tech Park\nETA: City Center 5 min, Central Mall 12 min";
    } else {
      return "❓ Bus not found. Try 'BUS 12A' or 'BUS 18B'";
    }
  }

  Future<void> _openSmsApp(String msg) async {
    final Uri uri = Uri(scheme: "sms", path: "12345", queryParameters: {"body": msg});
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMS/USSD Demo"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Messages (chat bubbles)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg["isUser"] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg["isUser"] ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: msg["isUser"] ? Colors.white : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type e.g. BUS 12A",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
                IconButton(
                  icon: const Icon(Icons.sms, color: Colors.green),
                  onPressed: () => _openSmsApp("BUS 12A"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
