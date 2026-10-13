import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _defaultUrl = 'http://10.140.3.242:5001/api/parking';
  static const String _prefKey = 'api_base_url';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey) ?? _defaultUrl;
  }

  static Future<bool> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_prefKey, url);
  }

  static Future<List<ParkingSlot>> fetchParkingStatus() async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => ParkingSlot.fromJson(json)).toList();
        }
      }
      throw Exception('Gagal memuat data parkir');
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }
}

class ParkingSlot {
  final int slot;
  final String status;
  final int distance;
  final DateTime updatedAt;

  ParkingSlot({
    required this.slot,
    required this.status,
    required this.distance,
    required this.updatedAt,
  });

  factory ParkingSlot.fromJson(Map<String, dynamic> json) {
    return ParkingSlot(
      slot: json['slot'],
      status: json['status'],
      distance: json['distance'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  bool get isOccupied => status.toLowerCase() == 'terisi';
}
