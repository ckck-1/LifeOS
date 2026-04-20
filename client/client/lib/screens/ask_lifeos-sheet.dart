import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AskLifeOSSheet extends StatefulWidget {
  const AskLifeOSSheet({super.key});

  @override
  State<AskLifeOSSheet> createState() => _AskLifeOSSheetState();
}

class _AskLifeOSSheetState extends State<AskLifeOSSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isProcessing = false;

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isProcessing) return;

    setState(() {
      _messages.add({"text": text, "isAi": false});
      _isProcessing = true;
      _controller.clear();
    });

    try {
      final response = await http.post(
        Uri.parse('https://lifeos-7nj8.onrender.com/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // FIX: Your backend uses the key 'reply', not 'response'
        String rawReply =
            data['reply'] ?? "I'm not sure how to respond to that.";
        String formattedMessage = "";

        try {
          // Parse the nested JSON string returned by your backend
          final Map<String, dynamic> nestedJson = jsonDecode(rawReply);

          if (nestedJson.containsKey('daily_focus')) {
            formattedMessage += "📅 **Daily Focus**\n";
            for (var item in nestedJson['daily_focus']) {
              formattedMessage += "• ${item['priority']}: ${item['action']}\n";
            }
          }

          if (nestedJson.containsKey('productivity_suggestions')) {
            formattedMessage += "\n💡 **Tips**\n";
            for (var tip in nestedJson['productivity_suggestions']) {
              formattedMessage += "• $tip\n";
            }
          }
        } catch (e) {
          // Fallback if the reply is just plain text and not a JSON string
          formattedMessage = rawReply;
        }

        setState(() {
          _messages.add({"text": formattedMessage.trim(), "isAi": true});
        });
      } else {
        _showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Connection failed. Please check your internet.");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showError(String error) {
    setState(() {
      _messages.add({"text": "Error: $error", "isAi": true});
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFF510105);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF121315),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildMessageList(),
            if (_isProcessing) _buildLoader(),
            const SizedBox(height: 8),
            _buildInputBar(primaryRed),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LifeOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                'Command interface',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF404040), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Flexible(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final msg = _messages[index];
            return _ChatBubble(
              text: msg['text'],
              isAi: msg['isAi'],
              accentColor: const Color(0xFF7BA5D6),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF7BA5D6),
        ),
      ),
    );
  }

  Widget _buildInputBar(Color primaryRed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Ask LIFEOS...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isAi;
  final Color accentColor;

  const _ChatBubble({
    required this.text,
    required this.isAi,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isAi ? const Color(0xFF1E2228) : const Color(0xFF1A1A1C),
          borderRadius: BorderRadius.circular(12),
          border: isAi ? Border.all(color: accentColor.withOpacity(0.2)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAi) ...[
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
