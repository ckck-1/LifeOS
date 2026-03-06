import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  final String apiUrl =
      'https://22b4-154-68-65-174.ngrok-free.app/ai/opportunities';

  Future<List<Opportunity>>? _opportunitiesFuture;

  @override
  void initState() {
    super.initState();
    _opportunitiesFuture = fetchOpportunities();
  }

  /// Fetch token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Make sure this matches your login storage key
  }

  /// Fetch opportunities from backend with auth token
  Future<List<Opportunity>> fetchOpportunities() async {
    print('[DEBUG] Fetching opportunities from backend...');
    final token = await _getToken();
    if (token == null) {
      print('[ERROR] No token found! User may not be logged in.');
      throw Exception('No token found');
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<Opportunity> opportunities = [];

        // Assuming your backend returns a "response" string that contains bullet points
        final rawText = data['response'] as String;
        final lines = rawText.split('\n');

        // Extract opportunities from numbered lines
        for (var line in lines) {
          final match = RegExp(r'\d+\.\s\*\*(.+?)\*\*:\s(.+)').firstMatch(line);
          if (match != null) {
            opportunities.add(
              Opportunity(
                title: match.group(1)!.trim(),
                paragraph: match.group(2)!.trim(),
              ),
            );
          }
        }

        return opportunities;
      } else {
        print('[ERROR] Failed to load opportunities, status: ${response.statusCode}');
        throw Exception('Failed to load opportunities');
      }
    } catch (e) {
      print('[ERROR] Exception occurred: $e');
      throw Exception('Exception occurred while fetching opportunities: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: FutureBuilder<List<Opportunity>>(
          future: _opportunitiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              print('[DEBUG] Waiting for data...');
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('[ERROR] Snapshot error: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No opportunities found'));
            }

            final opportunities = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildTopBar(context),
                  const SizedBox(height: 30),
                  _buildCategoryList(),
                  const SizedBox(height: 30),
                  _buildSectionHeader("AI Opportunities"),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: opportunities
                          .map((op) => _buildOpportunityCard(op))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Top Bar
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildSquareBackButton(context),
          const Expanded(
            child: Center(
              child: Text(
                "Opportunities",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 45),
        ],
      ),
    );
  }

  /// Back Button
  Widget _buildSquareBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 16),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// Filters
  Widget _buildCategoryList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          _buildChip("All", isSelected: true),
          _buildChip("Online"),
          _buildChip("Freelance"),
          _buildChip("Remote"),
          _buildChip("Side Hustles"),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.arrow_forward, color: Colors.grey),
        ],
      ),
    );
  }

  /// Opportunity Card
  Widget _buildOpportunityCard(Opportunity op) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            op.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            op.paragraph,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(onPressed: () {}, child: const Text("Explore")),
            ],
          ),
        ],
      ),
    );
  }

  /// Bottom Nav
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey[400],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.access_time), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
      ],
    );
  }
}

/// Opportunity Model
class Opportunity {
  final String title;
  final String paragraph;

  Opportunity({required this.title, required this.paragraph});

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      title: json['title'] ?? 'Untitled',
      paragraph: json['paragraph'] ?? '',
    );
  }
}