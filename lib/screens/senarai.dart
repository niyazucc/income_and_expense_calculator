import 'dart:convert';

import 'package:calculator/services/PerbelanjaanService.dart';
import 'package:calculator/services/PeruntukanService.dart';
import 'package:flutter/material.dart';

class SenaraiPage extends StatefulWidget {
  const SenaraiPage({super.key});

  @override
  State<SenaraiPage> createState() => _SenaraiPageState();
}

class _SenaraiPageState extends State<SenaraiPage> {
  Peruntukanservice apiService = Peruntukanservice();
  Perbelanjaanservice perbelanjaanservice = Perbelanjaanservice();

  List<dynamic> peruntukanList = [];
  List<dynamic> perbelanjaanList = [];
  bool isLoading = true; // Loading state
  double totalPeruntukan = 0.0;
  double totalPerbelanjaan = 0.0;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  double calculateTotal(List<dynamic> list, String key) {
    return list.fold(0.0, (sum, item) {
      double value = double.tryParse(item[key].toString()) ?? 0.0;
      return sum + value;
    });
  }

  void fetchData() async {
    // Fetch both lists and update the state
    try {
      var peruntukanData = await apiService.getPeruntukan();
      setState(() {
        peruntukanList = peruntukanData;
        isLoading = false;
        totalPeruntukan = calculateTotal(peruntukanList, 'amaun');
      });
    } catch (error) {
      // print("Error fetching data: $error");
      setState(() {
        isLoading = false;
      });
    }
    try {
      var perbelanjaanData = await perbelanjaanservice.getPerbelanjaan();
      setState(() {
        perbelanjaanList = perbelanjaanData;
        isLoading = false;
        totalPerbelanjaan = calculateTotal(perbelanjaanList, 'jumlah');
      });
    } catch (error) {
      // print("Error fetching data: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  void showEditDeleteDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit or Delete"),
          content: const Text("Choose an action for the selected item."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // showEditDialog(context, item); // Open the edit form
              },
              child: const Text("Edit"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                showDeleteConfirmation(context, item); // Confirm deletion
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmation(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Item"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () {
                if (item['amaun'] != null) {
                  apiService.deletePeruntukan(item['id']); // R
                  setState(() {
                    peruntukanList.remove(item);
                  });
                } else {
                  perbelanjaanservice.deletePerbelanjaan(
                      item['id']); // Remove the item from the list
                  setState(() {
                    perbelanjaanList.remove(item);
                  });
                }

                Navigator.of(context)
                    .pop(); // Close the delete confirmation dialog

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Data deleted'),
                ));
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
      },
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: AspectRatio(
            aspectRatio: 1, // Adjust as needed to control aspect ratio
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover, // Ensures the image fills the space
              width: double.infinity, // Matches the width of the container
              height: double.infinity, // Matches the height of the container
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    // Section Header
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Peruntukan:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.normal),
                          ),
                          Text(
                            'RM ${(totalPeruntukan).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Perbelanjaan:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.normal),
                          ),
                          Text(
                            'RM ${(totalPerbelanjaan).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Baki:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.normal),
                          ),
                          Text(
                            'RM ${(totalPeruntukan - totalPerbelanjaan).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Peruntukan',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Peruntukan Table
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor: WidgetStateProperty.resolveWith(
                            (states) => Colors.white),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        dataRowColor: WidgetStateProperty.resolveWith(
                            (states) => Colors.white),
                        columns: const [
                          DataColumn(
                              label: Text('Amaun (RM)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Catatan',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Tarikh Diterima',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('File',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: peruntukanList.map((item) {
                          return DataRow(
                              onLongPress: () {
                                showEditDeleteDialog(context, item);
                              },
                              cells: [
                                DataCell(Text(item['amaun'] ?? 'N/A',
                                    style: const TextStyle(fontSize: 16))),
                                DataCell(Text(item['catatan'] ?? 'N/A',
                                    style: const TextStyle(fontSize: 16))),
                                DataCell(Text(item['tarikh_diterima'] ?? 'N/A',
                                    style: const TextStyle(fontSize: 16))),
                                DataCell(
                                  item['file'] == null || item['file'] == ''
                                      ? Text('Empty',
                                          style: TextStyle(fontSize: 16))
                                      : GestureDetector(
                                          onTap: () {
                                            _showImageDialog(
                                                context, item['file']);
                                          },
                                          child: Image.network(
                                            width: 200,
                                            height: 200,
                                            item['file'],
                                          ),
                                        ),
                                )
                              ]);
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Section Header
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Perbelanjaan',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Perbelanjaan Table
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor: WidgetStateProperty.resolveWith(
                            (states) => Colors.white),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        dataRowColor: WidgetStateProperty.resolveWith(
                            (states) => Colors.white),
                        columns: const [
                          DataColumn(
                              label: Text('Perkara',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Item',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Harga per Item',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Kuantiti',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Jumlah',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Tarikh',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: perbelanjaanList.map((item) {
                          return DataRow(
                              onLongPress: () {
                                showEditDeleteDialog(context, item);
                              },
                              cells: [
                                DataCell(Text(item['perkara'] ?? 'N/A',
                                    style: const TextStyle(fontSize: 16))),
                                DataCell(Text(item['item'] ?? 'N/A',
                                    style: const TextStyle(fontSize: 16))),
                                DataCell(Text(item['harga_per_item'] ?? 'N/A',
                                    style: const TextStyle(fontSize: 16))),
                                DataCell(Text(
                                    item['kuantiti']?.toString() ?? 'N/A',
                                    style: const TextStyle(fontSize: 16))),
                                DataCell(Text(item['jumlah'] ?? 'N/A',
                                    style: const TextStyle(fontSize: 16))),
                                DataCell(Text(item['tarikh'] ?? 'N/A',
                                    style: const TextStyle(fontSize: 16))),
                              ]);
                        }).toList(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
