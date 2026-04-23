import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SessionScreen extends StatefulWidget {
  final String token;
  final String taskId;
  final String taskTitle;
  final String type;

  const SessionScreen({
    super.key,
    required this.token,
    required this.taskId,
    required this.taskTitle,
    required this.type,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final String baseUrl = "https://lifeos-7nj8.onrender.com";

  Timer? _timer;
  int _secondsElapsed = 0;
  String? _sessionId;
  bool _isStarting = true;

  @override
  void initState() {
    super.initState();
    _startSessionOnBackend();
  }

  /// 1. POST /sessions/start
  Future<void> _startSessionOnBackend() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessions/start'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "taskId": int.parse(widget.taskId),
          "type": widget.type,
          "startTime": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _sessionId = data['id'].toString();
        _startTimer();
        if (mounted) setState(() => _isStarting = false);
      } else {
        if (mounted) setState(() => _isStarting = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  /// 2. POST /sessions/end AND PATCH /tasks/:id
  Future<void> _endAndCompleteTask() async {
    if (_sessionId == null) return;

    // Show loading indicator during final API calls
    setState(() => _isStarting = true);

    try {
      // Step A: End the Session
      final sessionResponse = await http.post(
        Uri.parse('$baseUrl/sessions/end'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"sessionId": int.parse(_sessionId!)}),
      );

      if (sessionResponse.statusCode == 200) {
        // Step B: Mark Task as Done
        final taskResponse = await http.patch(
          Uri.parse('$baseUrl/tasks/${widget.taskId}'),
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "status":
                "done", // Adjust to "completed" if your backend requires it
          }),
        );

        if (taskResponse.statusCode == 200 || taskResponse.statusCode == 204) {
          debugPrint("Task marked as done.");
        }

        _timer?.cancel();
        if (mounted) {
          Navigator.pop(context); // Go back to Home
        }
      } else {
        debugPrint("Failed to end session: ${sessionResponse.body}");
        if (mounted) setState(() => _isStarting = false);
      }
    } catch (e) {
      debugPrint("Error in finishing sequence: $e");
      if (mounted) setState(() => _isStarting = false);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$remainingSeconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgDark = Color(0xFF0F172A);
    const Color purpleBtn = Color(0xFF1B143F);
    const Color brandBlue = Color(0xFF40C4FF);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Session", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 14, bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: brandBlue.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                widget.type.toUpperCase(),
                style: const TextStyle(
                  color: brandBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isStarting
          ? const Center(child: CircularProgressIndicator(color: brandBlue))
          : Column(
              children: [
                const Spacer(flex: 2),

                // Task Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.purpleAccent,
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.taskTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Timer Display
                Text(
                  _formatTime(_secondsElapsed),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),

                const Spacer(flex: 3),

                // Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed:
                            _endAndCompleteTask, // Combined Finish action
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purpleBtn,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                        child: const Text(
                          "Finish",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Quit",
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
    );
  }
}
