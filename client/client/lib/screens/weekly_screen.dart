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
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;

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
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Initialize with isExpanded = false
          _plans = [
            {
              "content": data['response'],
              "isExpanded": false,
              "date": "April 23, 2026",
            },
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        title: const Text("Weekly Plan"),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _plans.length,
              itemBuilder: (context, index) => _buildTimelineItem(index),
            ),
    );
  }

  Widget _buildTimelineItem(int index) {
    final plan = _plans[index];
    bool isExpanded = plan['isExpanded'];

    return IntrinsicHeight(
      child: Row(
        children: [
          _buildGradientLine(index == _plans.length - 1),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan['date'],
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 8),

                // EXPANDABLE SECTION
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Text(
                    plan['content'].split('\n').first, // Only show first line
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  secondChild: Text(
                    plan['content'].replaceAll(
                      '**',
                      '',
                    ), // Show full cleaned text
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ),

                _buildActions(index, isExpanded),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientLine(bool isLast) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          child: Icon(Icons.bolt, color: Colors.black),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green, Colors.green.withOpacity(0)],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActions(int index, bool isExpanded) {
    return Row(
      children: [
        const Icon(Icons.favorite_border, color: Colors.white38, size: 18),
        const Spacer(),
        IconButton(
          icon: Icon(
            isExpanded ? Icons.close_fullscreen : Icons.open_in_full,
            color: Colors.white38,
            size: 18,
          ),
          onPressed: () =>
              setState(() => _plans[index]['isExpanded'] = !isExpanded),
        ),
      ],
    );
  }
}
