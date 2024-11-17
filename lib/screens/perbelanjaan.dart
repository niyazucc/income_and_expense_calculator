import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MoneyOutForm extends StatefulWidget {
  @override
  _MoneyOutFormState createState() => _MoneyOutFormState();
}

class _MoneyOutFormState extends State<MoneyOutForm> {
  final _hargaPerItemController = TextEditingController();
  final _kuantitiController = TextEditingController();
  final _perkaraController = TextEditingController();
  final _itemController = TextEditingController();
  double _jumlah = 0.0;

  void _calculateJumlah() {
    setState(() {
      _jumlah = (double.tryParse(_hargaPerItemController.text) ?? 0) *
          (int.tryParse(_kuantitiController.text) ?? 0);
    });
  }

  Future<void> _saveMoneyOut() async {
    const url = 'http://127.0.0.1:8000/api/perbelanjaan/store';
    final response = await http.post(Uri.parse(url), body: {
      'tarikh': DateTime.now().toIso8601String(),
      'perkara': _perkaraController.text,
      'item': _itemController.text,
      'harga_per_item': _hargaPerItemController.text,
      'kuantiti': _kuantitiController.text,
      'jumlah': _jumlah.toString(),
    });

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perbelanjaan Disimpan')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving perbelanjaan: ${response.statusCode}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              const SizedBox(height: 20),
              TextField(
                controller: _perkaraController,
                decoration: const InputDecoration(
                  labelText: 'Perkara',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
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
    );
  }
}
