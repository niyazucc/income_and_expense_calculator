import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:calculator/model/Peruntukan.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:calculator/services/PeruntukanService.dart';

class MoneyInForm extends StatefulWidget {
  const MoneyInForm({super.key});

  @override
  _MoneyInFormState createState() => _MoneyInFormState();
}

class _MoneyInFormState extends State<MoneyInForm> {
  final _amountController = TextEditingController();
  final _catatanController = TextEditingController();
  DateTime? _tarikhDiterima;
  Peruntukanservice per = Peruntukanservice();
  Uint8List? fileBytes;
  String? fileName;

  FilePickerResult? filePickerResult;

  Future<void> getImageorVideoFromGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null) {
        setState(() {
          fileName = result.files.first.name;
          if (kIsWeb) {
            // On web, use `bytes`
            fileBytes = result.files.first.bytes; // Uint8List
          }
        });

        print("File name: $fileName");
        if (kIsWeb) {
          print("File bytes length (web): ${fileBytes?.length}");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _saveIncome() async {
    double? amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    String? catatan = _catatanController.text;
    if (catatan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a note (catatan)')),
      );
      return;
    }

    if (fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file')),
      );
      return;
    }

    Peruntukan peruntukan = Peruntukan(
      tarikhDiterima: _tarikhDiterima?.toIso8601String(),
      catatan: catatan,
      amaun: amount,
      file: fileBytes!,
    );

    try {
      await per.addIncome(context, peruntukan);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add income: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Peruntukan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amaun',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _catatanController,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                foregroundColor: WidgetStateProperty.all(Colors.grey),
              ),
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                ).then((pickedDate) {
                  if (pickedDate != null) {
                    setState(() {
                      _tarikhDiterima = pickedDate;
                    });
                  }
                });
              },
              child: Text(
                _tarikhDiterima != null
                    ? 'Date: ${_tarikhDiterima!.toLocal().toString().split(' ')[0]}'
                    : 'Select Tarikh Diterima',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getImageorVideoFromGallery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                alignment: Alignment.centerLeft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                fileBytes != null ? 'File: ${fileName!}' : 'Select File',
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveIncome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'SIMPAN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
