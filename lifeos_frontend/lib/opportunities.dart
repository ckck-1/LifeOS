import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  final String apiUrl =
      'https://8840-154-68-65-174.ngrok-free.app/ai/opportunities';

  Future<List<Opportunity>>? _opportunitiesFuture;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _opportunitiesFuture = fetchOpportunities();
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
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

        // Extract opportunities from JSON array
        final List<dynamic> opsJson = data['opportunities'] ?? [];
        final opportunities = opsJson
            .map((json) => Opportunity.fromJson(json))
            .toList(growable: false);

        return opportunities;
      } else {
        print(
          '[ERROR] Failed to load opportunities, status: ${response.statusCode}',
        );
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

  Widget _buildTopBar(BuildContext context) {
    /* same as before */
    return Container();
  }

  Widget _buildSquareBackButton(BuildContext context) {
    /* same as before */
    return Container();
  }

  Widget _buildCategoryList() {
    /* same as before */
    return Container();
  }

  Widget _buildChip(String label, {bool isSelected = false}) {
    /* same as before */
    return Container();
  }

  Widget _buildSectionHeader(String title) {
    /* same as before */
    return Container();
  }

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
            op.description, // updated from paragraph to description
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

  Widget _buildBottomNav() {
    /* same as before */
    return Container();
  }
}

/// Opportunity Model
class Opportunity {
  final String title;
  final String description; // changed from paragraph

  Opportunity({required this.title, required this.description});

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
    );
  }
}
