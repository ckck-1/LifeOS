import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeeklyPlanScreen extends StatefulWidget {
  final String token;
  const WeeklyPlanScreen({super.key, required this.token});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  late Future<List<String>> _planFuture;

  @override
  void initState() {
    super.initState();
    _planFuture = fetchWeeklyPlan();
  }

  /// Fetches specifically the Weekly Plan from the LifeOS AI endpoint
  Future<List<String>> fetchWeeklyPlan() async {
    const String url = 'https://lifeos-7nj8.onrender.com/ai/weekly-plan';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // The API returns the plan inside the 'response' key as a long string
        String rawContent = data['response'] ?? "";

        // logic: Split by newlines and filter out empty lines or generic titles
        // to get clean list items for the timeline view
        return rawContent
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty && line != "### Next Steps:")
            .toList();
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBg = Color(0xFF0B1220);
    const Color brandGreen = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              "Weekly Plan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Optimized by LifeOS",
              style: TextStyle(color: Colors.blue.shade400, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54, size: 20),
            onPressed: () => setState(() {
              _planFuture = fetchWeeklyPlan();
            }),
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _planFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF40C4FF)),
            );
          } else if (snapshot.hasError) {
            return _buildErrorState();
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildTimelineItem(
                label: _getDayLabel(index),
                content: items[index],
                isLast: index == items.length - 1,
                lineColor: brandGreen,
              );
            },
          );
        },
      ),
    );
  }

  String _getDayLabel(int index) {
    const days = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"];
    return days[index % days.length];
  }

  Widget _buildTimelineItem({
    required String label,
    required String content,
    required bool isLast,
    required Color lineColor,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: lineColor.withOpacity(0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "CURRENT WEEK",
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
                const SizedBox(height: 8),
                Text(
                  content.replaceAll('**', '').replaceAll('- ', ''),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                _buildItemActions(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemActions() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          const Icon(Icons.favorite_border, size: 18, color: Colors.white38),
          const Spacer(),
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: Colors.white38,
          ),
          const SizedBox(width: 16),
          const Icon(Icons.open_in_full, size: 16, color: Colors.white38),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
          const SizedBox(height: 16),
          const Text(
            "Failed to load your plan",
            style: TextStyle(color: Colors.white70),
          ),
          TextButton(
            onPressed: () => setState(() => _planFuture = fetchWeeklyPlan()),
            child: const Text(
              "Try Again",
              style: TextStyle(color: Color(0xFF40C4FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No insights generated for this week.",
        style: TextStyle(color: Colors.white38),
      ),
    );
  }
}
