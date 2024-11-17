import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
// import 'package:calculator/model/api_response.dart';
import 'package:calculator/model/Peruntukan.dart';
import 'package:http/http.dart' as http;

class Peruntukanservice {
  String baseUrl = 'http://127.0.0.1:8000/api/peruntukan';

  Future<List<dynamic>> getPeruntukan() async {
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      // Decode the JSON response
      var data = jsonDecode(response.body);

      // Access the "peruntukan" key to retrieve the list
      if (data is Map && data['peruntukan'] is List) {
        return data['peruntukan'];
      } else {
        throw Exception('Unexpected data format');
      }
    } else {
      throw Exception('Failed to load income data');
    }
  }

  Future<void> addIncome(BuildContext context, Peruntukan peruntukan) async {
    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/store'));

      // Add fields to the request
      request.fields['amaun'] = peruntukan.amaun.toString();
      request.fields['catatan'] = peruntukan.catatan.toString();
      request.fields['tarikh_diterima'] = peruntukan.tarikhDiterima.toString();

      // Add the file
      if (peruntukan.file != null && peruntukan.file is Uint8List) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file', // The name of the file field in your API
            peruntukan.file as Uint8List,
            filename: 'test.pdf', // Or use the actual file name
            contentType: MediaType('application', 'octet-stream'),
          ),
        );
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peruntukan disimpan successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add income: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  deletePeruntukan(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return "Peruntukan Deleted!";
    }
  }

  updatePeruntukan(Map<String, dynamic> item) {}
}
