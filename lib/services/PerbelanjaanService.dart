import 'dart:convert';
import 'dart:typed_data';

import 'package:calculator/model/Perbelanjaan.dart';
import 'package:calculator/screens/senarai.dart';
import 'package:flutter/material.dart';
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

  Future<List<dynamic>> getPerbelanjaanByDate(
      String? month, String? year) async {
    final response = await http.get(Uri.parse('$baseUrl/pada-$month-$year'));

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

  Future<String> deletePerbelanjaan(List<int> ids) async {
    List<int> failedDeletions = []; // To track failed deletions

    for (int id in ids) {
      try {
        final response = await http.delete(Uri.parse('$baseUrl/$id'));

        if (response.statusCode != 200) {
          // Track failed deletions
          failedDeletions.add(id);
        }
      } catch (e) {
        // Handle network errors and track the failed deletion
        failedDeletions.add(id);
      }
    }

    // Return the result
    if (failedDeletions.isEmpty) {
      return "All items deleted successfully!";
    } else {
      return "Failed to delete items with IDs: ${failedDeletions.join(', ')}";
    }
  }

  updatePerbelanjaan(
    BuildContext context,
    int id,
    Perbelanjaan per,
    VoidCallback clearFileStateCallback,
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$id'));
    request.fields['id'] = id.toString();
    request.fields['tarikh'] = per.tarikh.toString();
    request.fields['perkara'] = per.perkara.toString();
    request.fields['item'] = per.item.toString();
    request.fields['harga_per_item'] = per.harga_per_item.toString();
    request.fields['kuantiti'] = per.kuantiti.toString();
    request.fields['jumlah'] = per.jumlah.toString();

    if (per.file != null && per.file is Uint8List) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          per.file as Uint8List,
          filename: 'test.pdf',
        ),
      );
    }

    var response = await request.send();
    if (response.statusCode == 201 || response.statusCode == 200) {
      clearFileStateCallback();
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peruntukan disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Peruntukan gagal untuk disimpan: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  deleteFilePerbelanjaan(BuildContext context, int id) async {
    final response = await http.post(Uri.parse('$baseUrl/$id/file'));
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
    } else {
      return "Error. Status Code: $response";
    }
  }
}
