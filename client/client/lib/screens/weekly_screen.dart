import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Add intl to your pubspec.yaml for easy dating

class WeeklyPlanScreen extends StatefulWidget {
  final String token;
  const WeeklyPlanScreen({super.key, required this.token});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;

  final Color scaffoldBg = const Color(0xFF0B1220);
  final Color accentBlue = const Color(0xFF40C4FF);

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    const url = 'https://lifeos-7nj8.onrender.com/ai/weekly-plan';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String fullResponse = data['response'] ?? "";

        // 1. Split the big string into individual days using Regex
        // This looks for patterns like "- **Monday**" or "**Monday**"
        final RegExp dayRegex = RegExp(
          r'-?\s?\*\*(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)\*\*',
        );

        final List<String> sections = fullResponse.split(dayRegex);
        final Iterable<Match> matches = dayRegex.allMatches(fullResponse);

        List<Map<String, dynamic>> parsedPlans = [];
        List<String> foundDays = matches.map((m) => m.group(1)!).toList();

        // 2. Map the split sections to our list format
        // sections[0] is usually empty or intro text, so we start at index 1
        for (int i = 0; i < foundDays.length; i++) {
          if (i + 1 < sections.length) {
            String content = sections[i + 1].trim();
            // Clean up leading dashes or extra newlines
            content = content.replaceFirst(RegExp(r'^\n+'), '').trim();

            parsedPlans.add({
              "day": foundDays[i]
                  .substring(0, 2)
                  .toUpperCase(), // "MO", "TU", etc.
              "date": DateFormat(
                'MM/dd/yyyy',
              ).format(DateTime.now().add(Duration(days: i))),
              "content": content,
              "isExpanded": i == 0, // Expand the first day by default
            });
          }
        }

        if (mounted) {
          setState(() {
            _plans = parsedPlans.isEmpty
                ? [
                    {
                      "day": "!!",
                      "date": "Error",
                      "content": "Could not parse plan",
                      "isExpanded": true,
                    },
                  ]
                : parsedPlans;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Weekly Plan",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            "Optimized by LifeOS",
            style: TextStyle(
              color: accentBlue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: accentBlue))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _plans.length,
                    itemBuilder: (context, index) => _buildTimelineItem(index),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(int index) {
    final plan = _plans[index];
    final bool isExpanded = plan['isExpanded'] ?? false;
    final bool isLast = index == _plans.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT COLUMN: Bubble and Line
        Column(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: accentBlue, width: 2),
                boxShadow: [
                  BoxShadow(color: accentBlue.withOpacity(0.3), blurRadius: 10),
                ],
              ),
              child: Center(
                child: Text(
                  plan['day'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: isExpanded
                    ? 220
                    : 80, // Dynamic height based on content
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [accentBlue, accentBlue.withOpacity(0.01)],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 20),

        // RIGHT COLUMN: Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan['date'],
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () =>
                    setState(() => _plans[index]['isExpanded'] = !isExpanded),
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Text(
                    plan['content'].replaceAll(
                      RegExp(r'[*#]'),
                      '',
                    ), // Clean formatting symbols
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  secondChild: Text(
                    plan['content'].replaceAll(RegExp(r'[*#]'), ''),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              _buildActionRow(index, isExpanded),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(int index, bool isExpanded) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        children: [
          const Icon(Icons.favorite_border, color: Colors.white24, size: 18),
          const SizedBox(width: 15),
          const Icon(Icons.share_outlined, color: Colors.white24, size: 18),
          const Spacer(),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: accentBlue,
            ),
            onPressed: () =>
                setState(() => _plans[index]['isExpanded'] = !isExpanded),
          ),
        ],
      ),
    );
  }
}
