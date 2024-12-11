import 'package:calculator/model/Perkara.dart';
import 'package:calculator/screens/perkara.dart';
import 'package:calculator/services/PerkaraServices.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

import 'package:http/http.dart' as http;
import 'dart:typed_data';

class MoneyOutForm extends StatefulWidget {
  @override
  _MoneyOutFormState createState() => _MoneyOutFormState();
}

class _MoneyOutFormState extends State<MoneyOutForm> {
  @override
  void initState() {
    super.initState();
    fetchPerkaraData(); // Fetch data when the widget initializes
  }

  final _hargaPerItemController = TextEditingController();
  final _kuantitiController = TextEditingController();
  final _perkaraController = TextEditingController();
  final _itemController = TextEditingController();

  DateTime? tarikh;
  double _jumlah = 0.0;
  Uint8List? fileBytes;
  String? fileName;
  FilePickerResult? filePickerResult;
  List<String> listPerkara = [];
  String? selectedPerkara;
  void _calculateJumlah() {
    setState(() {
      _jumlah = (double.tryParse(_hargaPerItemController.text) ?? 0) *
          (int.tryParse(_kuantitiController.text) ?? 0);
    });
  }

  Future<void> fetchPerkaraData() async {
    try {
      Perkaraservices perkaraservices = Perkaraservices();
      List<Perkara> perkaraList = await perkaraservices.getPerkara();

      // Map Perkara objects to a list of strings (e.g., names or titles)
      setState(() {
        listPerkara = perkaraList.map((p) => p.description).toList();
      });
    } catch (e) {
      print('Error fetching Perkara data: $e');
      // Optionally handle errors (e.g., show a snackbar or placeholder)
    }
  }

  Future<void> _saveMoneyOut() async {
    if (selectedPerkara.toString().isEmpty ||
        _itemController.text.isEmpty ||
        _hargaPerItemController.text.isEmpty ||
        _kuantitiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    const url = 'http://127.0.0.1:8000/api/perbelanjaan/store';
    final request = http.MultipartRequest('POST', Uri.parse(url));

    request.fields['tarikh'] =
        tarikh?.toIso8601String() ?? DateTime.now().toIso8601String();
    request.fields['perkara'] = selectedPerkara.toString();
    request.fields['item'] = _itemController.text;
    request.fields['harga_per_item'] = _hargaPerItemController.text;
    request.fields['kuantiti'] = _kuantitiController.text;
    request.fields['jumlah'] = _jumlah.toString();

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes!,
        filename: fileName,
      ),
    );

    final response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Perbelanjaan Disimpan',
            )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Error saving perbelanjaan: ${response.statusCode}',
            )),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PerkaraPage()),
          );
          if (result == 'refresh') {
            setState(() {
              fetchPerkaraData(); // Refresh logic
            });
          }
          
        },
        backgroundColor: Colors.white,
        tooltip: 'Tambah Perkara',
        child: const Icon(Icons.add),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Perbelanjaan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  children: [
                    Text(
                      'Pilih Tarikh:',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          alignment: Alignment.centerLeft,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                                tarikh = pickedDate;
                              });
                            }
                          });
                        },
                        child: Text(
                          tarikh != null
                              ? 'Date: ${tarikh!.toLocal().toString().split(' ')[0]}'
                              : 'Select Tarikh Perbelanjaan',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Text(
                      'Pilih Perkara:',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Text(
                          'Select Perkara',
                          style: TextStyle(color: Colors.black),
                        ),
                        items: listPerkara
                            .map((String perkara) => DropdownMenuItem<String>(
                                  value: perkara,
                                  child: Text(perkara),
                                ))
                            .toList(),
                        value: selectedPerkara,
                        onChanged: (String? value) {
                          setState(() {
                            selectedPerkara = value;
                          });
                        },
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                // TextField(
                //   controller: _perkaraController,
                //   decoration: const InputDecoration(
                //     labelText: 'Perkara',
                //     border: OutlineInputBorder(),
                //     contentPadding:
                //         EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                //   ),
                // ),
                const SizedBox(height: 16),
                TextField(
                  controller: _itemController,
                  decoration: const InputDecoration(
                    labelText: 'Item',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _hargaPerItemController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga per Item',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  onChanged: (_) => _calculateJumlah(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _kuantitiController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Kuantiti',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  onChanged: (_) => _calculateJumlah(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Add File:',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: getImageorVideoFromGallery,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          alignment: Alignment.centerLeft,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          fileBytes != null
                              ? 'File: ${fileName!}'
                              : 'Select File',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Jumlah: RM $_jumlah',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _saveMoneyOut,
                    child: const Text(
                      'SIMPAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
