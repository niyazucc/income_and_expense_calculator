import 'package:calculator/model/Perbelanjaan.dart';
import 'package:calculator/model/Perkara.dart';
import 'package:calculator/screens/perbelanjaan.dart';
import 'package:calculator/services/PerkaraServices.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perkara Table',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PerkaraPage(),
    );
  }
}

class PerkaraPage extends StatefulWidget {
  const PerkaraPage({super.key});

  @override
  State<PerkaraPage> createState() => _PerkaraPageState();
}

class _PerkaraPageState extends State<PerkaraPage> {
  Perkaraservices perkaraservices = Perkaraservices();
  final TextEditingController _perkaraController = TextEditingController();
  List<Perkara> _perkaraList = [];
  Set<int> selectedPerkaraIds = {}; // Stores the IDs of selected items

  Future<void> loadPerkara() async {
    try {
      _perkaraList = await perkaraservices.getPerkara();
      setState(() {}); // Refresh the UI after loading data
    } catch (e) {
      print('Failed to load perkara: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadPerkara();
  }

  void _deleteSelected(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Item"),
            content: const Text("Are you sure you want to delete this item?"),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    // Perform the deletion in the backend
                    await perkaraservices.deletePerkara(selectedPerkaraIds);

                    // Update the UI by removing the selected items
                    setState(() {
                      _perkaraList.removeWhere(
                          (perkara) => selectedPerkaraIds.contains(perkara.id));
                      selectedPerkaraIds.clear(); // Clear the selected IDs
                    });
                  } catch (e) {
                    print('Failed to delete selected items: $e');
                  }
                  Navigator.of(context)
                      .pop(); // Close the delete confirmation dialog

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Data deleted'),
                  ));
                },
                child:
                    const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Close the delete confirmation dialog
                },
                child: const Text("Cancel"),
              ),
            ],
          );
        });
  }

  void _showAddPerkaraDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Perkara',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _perkaraController,
                  decoration: const InputDecoration(hintText: 'Enter Perkara'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_perkaraController.text.isNotEmpty) {
                          Perkara newPerkara = Perkara.withoutid(
                            _perkaraController.text,
                          );
                          await perkaraservices.store(_perkaraController.text);
                          setState(() {
                            _perkaraList.add(newPerkara);
                          });
                          _perkaraController
                              .clear(); // Clear the text field after submission
                          Navigator.of(context).pop(true);
                          await loadPerkara();
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, 'refresh'); // Send a signal to refresh
          },
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the color of the back icon
        ),
        backgroundColor: Colors.black,
        title: const Text(
          'Perkara Table',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (selectedPerkaraIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteSelected(context),
              tooltip: 'Delete Selected',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                  shape: WidgetStatePropertyAll<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          5), // Adjust the value for smoother corners
                    ),
                  ),
                  backgroundColor: WidgetStatePropertyAll<Color>(Colors.black),
                  elevation: WidgetStatePropertyAll(5)),
              onPressed: _showAddPerkaraDialog,
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, // Ensure the row takes minimal width
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8), // Space between the icon and text
                  Text(
                    'Add Perkara',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _perkaraList.isEmpty
                  ? const Center(
                      child: Text('No Perkara added yet.'),
                    )
                  : DataTable(
                      columns: const [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Ulasan')),
                        DataColumn(label: Text('Select')),
                      ],
                      rows: _perkaraList.asMap().entries.map((entry) {
                        int index = entry.key;
                        Perkara perkara = entry.value;
                        return DataRow(cells: [
                          DataCell(Text((index + 1).toString())),
                          DataCell(Text(perkara.description)),
                          DataCell(
                            Checkbox(
                              activeColor: Colors
                                  .grey, // Set checkbox active color to grey
                              checkColor: Colors.white,
                              value: selectedPerkaraIds.contains(perkara.id),
                              onChanged: (selected) {
                                setState(() {
                                  if (selected == true) {
                                    selectedPerkaraIds.add(perkara.id!);
                                    print(selectedPerkaraIds);
                                  } else {
                                    selectedPerkaraIds.remove(perkara.id);
                                    print(selectedPerkaraIds);
                                  }
                                });
                              },
                            ),
                          )
                        ]);
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
