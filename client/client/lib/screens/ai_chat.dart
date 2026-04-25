import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AIChatScreen extends StatefulWidget {
  final String token;
  const AIChatScreen({super.key, required this.token});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final String baseUrl = "https://lifeos-7nj8.onrender.com";
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _loading = false;
  String username = "";
  bool _greetingAdded = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          username =
              (data['name'] ?? data['username'] ?? data['email'] ?? "Sophie")
                  .toString();
        });
        _addGreeting();
      } else {
        _addGreeting();
      }
    } catch (e) {
      debugPrint("User fetch error: $e");
      _addGreeting();
    }
  }

  void _addGreeting() {
    if (_greetingAdded) return;
    _greetingAdded = true;
    final hour = DateTime.now().hour;
    String message;
    if (hour < 12) {
      message = "Good morning $username ☀️ Ready when you are.";
    } else if (hour < 18) {
      message = "Good afternoon $username 👋 What are we building today?";
    } else {
      message = "Good evening $username 🌙 I'm here whenever you need me.";
    }
    setState(() {
      _messages.insert(0, {"role": "ai", "text": message});
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    setState(() {
      _messages.add({"role": "user", "text": text});
      _loading = true;
    });

    _scrollToBottom();

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"message": text}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _messages.add({
            "role": "ai",
            "text": (data['reply'] ?? "No response").toString(),
          });
        });
      } else {
        setState(() {
          _messages.add({"role": "ai", "text": "Server error 😬"});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "ai", "text": "Network error 🌐"});
      });
    }

    setState(() => _loading = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ✅ NEW: Bold formatter (**text**)
  Widget _buildFormattedText(String text, bool isUser) {
    final List<TextSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int start = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: TextStyle(
              color: isUser ? Colors.black : Colors.white,
              fontSize: 16,
              height: 1.3,
              fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: isUser ? Colors.black : Colors.white,
            fontSize: 16,
            height: 1.3,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: TextStyle(
            color: isUser ? Colors.black : Colors.white,
            fontSize: 16,
            height: 1.3,
            fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBg = Color(0xFF0F172A);
    const Color aiBubbleColor = Color(0xFF1E293B);
    const Color userBubbleColor = Color(0xFF4ADE80);
    const Color textSecondary = Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textSecondary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.white, radius: 18),
            const SizedBox(width: 12),
            Text(
              username,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isUser = msg["role"] == "user";
                final text = (msg["text"] ?? "").toString();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? userBubbleColor : aiBubbleColor,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(22),
                              topRight: const Radius.circular(22),
                              bottomLeft: Radius.circular(isUser ? 22 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 22),
                            ),
                          ),
                          child: _buildFormattedText(text, isUser),
                        ),
                      ),
                      if (!isUser) const SizedBox(width: 40),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: userBubbleColor,
                ),
              ),
            ),
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: userBubbleColor,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: "How can I be more productive?",
                        hintStyle: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: const Color(0xFF64748B).withOpacity(0.2),
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
