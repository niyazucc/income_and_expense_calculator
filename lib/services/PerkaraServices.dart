import 'dart:convert';
import 'package:calculator/model/Perkara.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Perkaraservices extends StatelessWidget {
  final String baseUrl = 'http://127.0.0.1:8000/api/perkara';

  const Perkaraservices({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Future<void> store(String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/store'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'description': description}),
      );

      if (response.statusCode == 200) {
        print('Perkara stored successfully: ${response.body}');
      } else {
        print('Failed to store Perkara. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<List<Perkara>> getPerkara() async {
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body);
        List<Map<String, dynamic>> perkaraList =
            List<Map<String, dynamic>>.from(data['perkara']);

        // Convert JSON maps to Perkara objects
        return perkaraList.map((item) => Perkara.fromJson(item)).toList();
      } catch (e) {
        throw Exception('Error parsing JSON: $e');
      }
    } else {
      throw Exception('Failed to load perkara data');
    }
  }

  Future<List<Perkara>> getListPerkara() async {
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body);
        List<Map<String, dynamic>> perkaraList =
            List<Map<String, dynamic>>.from(data['perkara']);

        // Convert JSON maps to Perkara objects
        return  perkaraList.map((item) =>  Perkara.fromJson(item)).toList();
      } catch (e) {
        throw Exception('Error parsing JSON: $e');
      }
    } else {
      throw Exception('Failed to load perkara data');
    }
  }

  Future<void> deletePerkara(Set<int> perkaraList) async {
    // Create a copy of the set to safely iterate
    final perkaraCopy = List<int>.from(perkaraList);

    for (int id in perkaraCopy) {
      try {
        final request = await http.delete(Uri.parse('$baseUrl/$id'));
        if (request.statusCode == 200) {
          print('Deleted id: $id');
        } else {
          print('Failed to delete id: $id');
        }
      } catch (e) {
        print('Error deleting id $id: $e');
      }
    }
  }
}
