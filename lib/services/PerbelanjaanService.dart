import 'dart:convert';

import 'package:calculator/model/Perbelanjaan.dart';
import 'package:http/http.dart' as http;

class Perbelanjaanservice {
  String baseUrl = 'http://127.0.0.1:8000/api/perbelanjaan';

  Future<List<dynamic>> getPerbelanjaan() async {
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      // Decode the JSON response
      var data = jsonDecode(response.body);

      // Access the "perbelanjaan" key to retrieve the list
      if (data is Map && data['perbelanjaan'] is List) {
        return data['perbelanjaan'];
      } else {
        throw Exception('Unexpected data format');
      }
    } else {
      throw Exception('Failed to load income data');
    }
  }

  deletePerbelanjaan(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return "Peruntukan Deleted!";
    }
  }

  updatePerbelanjaan(Map<String, dynamic> item) {}
}
