import 'dart:io';
import 'dart:typed_data';

import 'package:calculator/model/Perbelanjaan.dart';
import 'package:calculator/model/Peruntukan.dart';
import 'package:calculator/services/PerbelanjaanService.dart';
import 'package:calculator/services/PeruntukanService.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

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
  double baki = 0.0;

  Uint8List? fileBytes;
  String? fileName;
  DateTime? tarikh1;

  FilePickerResult? filePickerResult;
  @override
  void initState() {
    super.initState();
    fetchData(
      tarikh1?.month.toString(),
      tarikh1?.year.toString(),
    );
  }

  Future<void> saveLaporanAsPdf(
      List<dynamic> perbelanjaanList, List<dynamic> peruntukanList) async {
    try {
      // Create a PDF document
      final pdf = pw.Document();

      // Add content to the PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Report Title
                  pw.Text(
                    'Laporan Peruntukan dan Perbelanjaan',
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Divider(thickness: 2),

                  // Subtitle with Date
                  pw.Text(
                    tarikh1 != null
                        ? 'Bulan: ${tarikh1?.month.toString()}, Tahun: ${tarikh1?.year.toString()}'
                        : 'Sepanjang Masa/Keseluruhan',
                    style: pw.TextStyle(
                        fontSize: 18, fontStyle: pw.FontStyle.italic),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 24),

                  // Section: Peruntukan
                  pw.Text(
                    'Peruntukan',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.TableHelper.fromTextArray(
                    headers: ['Tarikh Diterima', 'Amaun (RM)', 'Catatan'],
                    data: peruntukanList.map((item) {
                      return [
                        item['tarikh_diterima'] ?? 'N/A',
                        item['amaun'] ?? 'N/A',
                        item['catatan'] ?? 'N/A',
                      ];
                    }).toList(),
                    border: pw.TableBorder.all(),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                    cellStyle: pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 16),

                  // Section: Perbelanjaan
                  pw.Text(
                    'Perbelanjaan',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.TableHelper.fromTextArray(
                    headers: [
                      'Tarikh',
                      'Perkara',
                      'Item',
                      'Harga/Item (RM)',
                      'Kuantiti',
                      'Jumlah (RM)',
                    ],
                    data: perbelanjaanList.map((item) {
                      return [
                        item['tarikh'] ?? 'N/A',
                        item['perkara'] ?? 'N/A',
                        item['item'] ?? 'N/A',
                        item['harga_per_item'] ?? 'N/A',
                        item['kuantiti'] ?? 'N/A',
                        item['jumlah'] ?? 'N/A',
                      ];
                    }).toList(),
                    border: pw.TableBorder.all(),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                    cellStyle: pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 16),

                  // Summary Section
                  pw.Text(
                    'Ringkasan',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Jumlah Peruntukan: RM $totalPeruntukan',
                          style: pw.TextStyle(fontSize: 14),
                        ),
                        pw.Text(
                          'Jumlah Perbelanjaan: RM $totalPerbelanjaan',
                          style: pw.TextStyle(fontSize: 14),
                        ),
                        pw.Text(
                          'Baki: RM $baki',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 24),

                  // Footer
                  pw.Text(
                    'Laporan ini dihasilkan secara automatik.',
                    style: pw.TextStyle(
                        fontSize: 12, fontStyle: pw.FontStyle.italic),
                    textAlign: pw.TextAlign.center,
                  ),
                ]);
          },
        ),
      );

      // Save the PDF as bytes
      final Uint8List bytes = await pdf.save();

      // Trigger a file download in the browser
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.Url.revokeObjectUrl(url); // Clean up URL

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan downloaded!'),
          backgroundColor: Colors.green,
        ),
      );
      print('PDF download initiated.');
    } catch (e) {
      print('Error generating report: $e');
    }
  }

  Future<void> _showMonthYearPicker(BuildContext context) async {
    tarikh1 = await showMonthYearPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2030),
      locale: null,
    );
    setState(() {
      print(
          'Bulan: ${tarikh1?.month.toString()}, Year: ${tarikh1?.year.toString()}');
      fetchData(
        tarikh1?.month.toString(),
        tarikh1?.year.toString(),
      );
    });
  }

  double calculateTotal(List<dynamic> list, String key) {
    return list.fold(0.0, (sum, item) {
      double value = double.tryParse(item[key].toString()) ?? 0.0;
      return sum + value;
    });
  }

  void fetchData(String? month, String? year) async {
    // Fetch both lists and update the state
    List peruntukanData;
    List perbelanjaanData;
    try {
      if (month != null || year != null) {
        peruntukanData = await apiService.getByDate(month, year);
      } else {
        peruntukanData = await apiService.getPeruntukan();
      }

      setState(() {
        peruntukanList = peruntukanData;
        isLoading = false;
        totalPeruntukan = calculateTotal(peruntukanList, 'amaun');
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
    try {
      if (month != null || year != null) {
        perbelanjaanData =
            await perbelanjaanservice.getPerbelanjaanByDate(month, year);
      } else {
        perbelanjaanData = await perbelanjaanservice.getPerbelanjaan();
      }
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
    baki = totalPeruntukan - totalPerbelanjaan;
  }

  void clearFileState() {
    setState(() {
      fileName = null;
      fileBytes = null;
    });
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
                showEditDialog(context, item); // Open the edit form
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

  void _showConfirmationDelete(BuildContext context, item) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Confirm delete?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    item['jumlah'] != null
                        ? perbelanjaanservice.deleteFilePerbelanjaan(
                            context, item['id'])
                        : apiService.deleteFilePeruntukan(context, item['id']);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ));
  }

  void _showConfirmationDeleteMany(BuildContext context, item) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Confirm delete?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      perbelanjaanservice.deletePerbelanjaan(item);
                      perbelanjaanList
                          .removeWhere((item) => item['isSelected'] == true);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ));
  }

  void _showConfirmationDeleteManyPeruntukan(BuildContext context, item) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Confirm delete?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      apiService.deletePeruntukan(item);
                      peruntukanList
                          .removeWhere((item) => item['isSelected'] == true);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ));
  }

  void showEditDialog(BuildContext context, item) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    if (item['jumlah'] == null) {
      final TextEditingController _amountController = TextEditingController(
        text: item['amaun']?.toString() ??
            '', // Initialize with existing value if not null
      );
      final TextEditingController _tarikhDiterima = TextEditingController(
        text: item['tarikh_diterima']?.toString() ??
            '', // Initialize with existing value if not null
      );
      final TextEditingController _catatan = TextEditingController(
        text: item['catatan']?.toString() ??
            '', // Initialize with existing value if not null
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit Peruntukan ID: ${item['id']}'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Tarikh',
                            border: OutlineInputBorder(),
                          ),
                          controller: _tarikhDiterima,
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: 'Jumlah Peruntukan',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Sila masukkan jumlah';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Sila masukkan nombor yang sah';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Catatan',
                            border: OutlineInputBorder(),
                          ),
                          controller: _catatan,
                        ),
                        SizedBox(height: 15),
                        Text('Current File'),
                        item['file'] != null || fileBytes != null
                            ? Column(
                                children: [
                                  fileBytes != null
                                      ? Image.memory(
                                          fileBytes!,
                                          height: 200,
                                          width: 200,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(item['file']),
                                  OverflowBar(
                                    alignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      TextButton(
                                        child: Icon(Icons.edit),
                                        onPressed: () async {
                                          await getImageorVideoFromGallery();
                                          setDialogState(
                                              () {}); // Update dialog UI
                                        },
                                      ),
                                      TextButton(
                                        child: Icon(Icons.delete),
                                        onPressed: () {
                                          _showConfirmationDelete(
                                              context, item);
                                          setDialogState(() {
                                            fileName = null;
                                            fileBytes =
                                                null; // Clear selected file
                                            item['file'] =
                                                null; // Clear network URL
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              )
                            : Column(
                                children: [
                                  Text('No Image Available'),
                                  TextButton(
                                    onPressed: () async {
                                      await getImageorVideoFromGallery();
                                      setDialogState(() {}); // Update dialog UI
                                    },
                                    child: Icon(Icons.add),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    double? amount = double.parse(_amountController.text);
                    // Create the updated Peruntukan object
                    Peruntukan peruntukan = Peruntukan(
                      tarikhDiterima: _tarikhDiterima.text,
                      catatan: _catatan.text,
                      amaun: amount,
                      file: fileBytes,
                    );

                    try {
                      await apiService.updatePeruntukan(
                          context, item['id'], peruntukan);
                      fetchData(
                        tarikh1?.month.toString(),
                        tarikh1?.year.toString(),
                      );
                      Navigator.of(context).pop();
                    } catch (e) {
                      // Show an error message if the update fails
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save: $e')),
                      );
                    }
                  }
                },
                child: Text('Simpan'),
              ),
            ],
          );
        },
      );
    } else {
      final TextEditingController tarikh = TextEditingController(
        text: item['tarikh']?.toString() ??
            '', // Initialize with existing value if not null
      );
      final TextEditingController perkara = TextEditingController(
        text: item['perkara']?.toString() ??
            '', // Initialize with existing value if not null
      );
      final TextEditingController items = TextEditingController(
        text: item['item']?.toString() ??
            '', // Initialize with existing value if not null
      );
      final harga = TextEditingController(
        text: item['harga_per_item']?.toString() ??
            '', // Initialize with existing value if not null
      );
      final kuantiti = TextEditingController(
        text: item['kuantiti']?.toString() ??
            '', // Initialize with existing value if not null
      );
      double _jumlah = double.parse(item['jumlah']);
      void _calculateJumlah(StateSetter setDialogState) {
        setDialogState(() {
          _jumlah = (double.tryParse(harga.text) ?? 0) *
              (int.tryParse(kuantiti.text) ?? 0);
        });
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit Perbelanjaan ID: ${item['id']}'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Tarikh',
                            border: OutlineInputBorder(),
                          ),
                          controller: tarikh,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Perkara',
                            border: OutlineInputBorder(),
                          ),
                          controller: perkara,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Item',
                            border: OutlineInputBorder(),
                          ),
                          controller: items,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Harga',
                            border: OutlineInputBorder(),
                          ),
                          controller: harga,
                          onChanged: (_) => _calculateJumlah(setDialogState),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Kuantiti',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _calculateJumlah(setDialogState),
                          controller: kuantiti,
                        ),
                        _jumlah != 0
                            ? Text('Jumlah: RM$_jumlah')
                            : Text('Jumlah: RM${item['jumlah']}'),
                        SizedBox(height: 15),
                        Text('Current File'),
                        item['file'] != null || fileBytes != null
                            ? Column(
                                children: [
                                  fileBytes != null
                                      ? Image.memory(
                                          fileBytes!,
                                          height: 200,
                                          width: 200,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(item['file']),
                                  OverflowBar(
                                    alignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      TextButton(
                                        child: Icon(Icons.edit),
                                        onPressed: () async {
                                          await getImageorVideoFromGallery();
                                          setDialogState(() {});
                                        },
                                      ),
                                      TextButton(
                                        child: Icon(Icons.delete),
                                        onPressed: () {
                                          _showConfirmationDelete(
                                              context, item);
                                          setDialogState(() {
                                            fileName = null;
                                            fileBytes = null;
                                            item['file'] = null;
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              )
                            : Column(
                                children: [
                                  Text('No Image Available'),
                                  TextButton(
                                    onPressed: () async {
                                      await getImageorVideoFromGallery();
                                      setDialogState(() {});
                                    },
                                    child: Icon(Icons.add),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  double jumlah =
                      _jumlah != item['jumlah'] ? _jumlah : item['jumlah'];
                  Perbelanjaan perbelanjaan = Perbelanjaan(
                      perkara: perkara.text,
                      item: items.text,
                      tarikh: tarikh.text,
                      kuantiti: int.parse(kuantiti.text),
                      harga_per_item: double.parse(harga.text),
                      jumlah: jumlah,
                      file: fileBytes);

                  try {
                    await perbelanjaanservice.updatePerbelanjaan(
                        context, item['id'], perbelanjaan, clearFileState);
                    fetchData(
                      tarikh1?.month.toString(),
                      tarikh1?.year.toString(),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Show an error message if the update fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save: $e')),
                    );
                  }
                },
                child: Text('Simpan'),
              ),
            ],
          );
        },
      );
    }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Want to save Laporan as pdf?"),
                  actions: [
                    TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await saveLaporanAsPdf(
                            perbelanjaanList, peruntukanList);
                      },
                      child: Text('Yes'),
                    )
                  ],
                );
              });
        },
        backgroundColor: Colors.white,
        tooltip: 'Tambah Perkara',
        child: const Icon(Icons.picture_as_pdf),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 5,
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Label text
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.only(right: 8),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Peruntukan dan Perbelanjaan Pada:',
                              style: TextStyle(
                                fontSize:
                                    18, // Slightly reduced size for better fit
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.centerLeft,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              _showMonthYearPicker(context);
                            },
                            child: Text(
                              tarikh1 != null
                                  ? 'Bulan:${tarikh1?.month.toString()} Tahun:${tarikh1?.year.toString()}'
                                  : 'Select Bulan dan Tahun',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

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
                          Text('RM ${(baki).toStringAsFixed(2)}',
                              style: baki > 0
                                  ? const TextStyle(
                                      fontSize: 18, color: Colors.green)
                                  : const TextStyle(
                                      fontSize: 18, color: Colors.red)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Peruntukan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (peruntukanList
                            .any((item) => item['isSelected'] == true))
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .red, // Set button background color to red
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10, // Adjust padding
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                List<int> selectedIds = peruntukanList
                                    .where((item) => item['isSelected'] == true)
                                    .map<int>((item) => item['id'] as int)
                                    .toList();
                                _showConfirmationDeleteManyPeruntukan(
                                    context, selectedIds);
                              });
                            },
                            icon: const Icon(
                              Icons.delete, // Trash icon
                              color: Colors.white, // Set icon color to white
                            ),
                            label: const Text(
                              'Delete Selected',
                              style: TextStyle(
                                  color:
                                      Colors.white), // Set text color to white
                            ),
                          ),
                      ],
                    ),

                    // Peruntukan Table

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        showCheckboxColumn: true,
                        columnSpacing: 20,
                        headingRowColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.white,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        dataRowColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.white,
                        ),
                        columns: const [
                          DataColumn(
                            label: Text('Select',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Tarikh Diterima',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Amaun (RM)',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Catatan',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('File',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                        rows: peruntukanList != null &&
                                peruntukanList.isNotEmpty
                            ? peruntukanList.map((item) {
                                return DataRow(
                                  onLongPress: () {
                                    showEditDeleteDialog(context, item);
                                  },
                                  selected: item['isSelected'] ?? false,
                                  cells: [
                                    DataCell(
                                      Checkbox(
                                        value: item['isSelected'] ?? false,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            item['isSelected'] = value!;
                                          });
                                        },
                                        activeColor: Colors
                                            .grey, // Set checkbox active color to grey
                                        checkColor: Colors
                                            .white, // Set check color to white
                                      ),
                                    ),
                                    DataCell(Text(
                                        item['tarikh_diterima'] ?? 'N/A',
                                        style: const TextStyle(fontSize: 16))),
                                    DataCell(Text(item['amaun'] ?? 'N/A',
                                        style: const TextStyle(fontSize: 16))),
                                    DataCell(Text(item['catatan'] ?? 'N/A',
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
                                    ),
                                  ],
                                );
                              }).toList()
                            : [
                                DataRow(
                                  cells: [
                                    DataCell(Text(
                                      'No record',
                                      style: const TextStyle(fontSize: 16),
                                    )),
                                    DataCell(SizedBox
                                        .shrink()), // Empty cells for alignment
                                    DataCell(SizedBox.shrink()),
                                    DataCell(SizedBox.shrink()),
                                    DataCell(SizedBox.shrink()),
                                  ],
                                ),
                              ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Section Header
                    Row(
                      children: [
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Perbelanjaan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (perbelanjaanList
                            .any((item) => item['isSelected'] == true))
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .red, // Set button background color to red
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10, // Adjust padding
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                List<int> selectedIds = perbelanjaanList
                                    .where((item) => item['isSelected'] == true)
                                    .map<int>((item) => item['id'] as int)
                                    .toList();
                                _showConfirmationDeleteMany(
                                    context, selectedIds);
                              });
                            },
                            icon: const Icon(
                              Icons.delete, // Trash icon
                              color: Colors.white, // Set icon color to white
                            ),
                            label: const Text(
                              'Delete Selected',
                              style: TextStyle(
                                  color:
                                      Colors.white), // Set text color to white
                            ),
                          ),
                      ],
                    ),

                    // Perbelanjaan Table
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.white,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        dataRowColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.white,
                        ),
                        columns: const [
                          DataColumn(
                            label: Text('Select',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Tarikh',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Perkara',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Item',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Harga per Item',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Kuantiti',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Jumlah',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('File',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                        rows: perbelanjaanList != null &&
                                perbelanjaanList.isNotEmpty
                            ? perbelanjaanList.map((item) {
                                return DataRow(
                                  onLongPress: () {
                                    showEditDeleteDialog(context, item);
                                  },
                                  selected: item['isSelected'] ??
                                      false, // Track if the row is selected
                                  cells: [
                                    // Checkbox for selection
                                    DataCell(
                                      Checkbox(
                                        value: item['isSelected'] ?? false,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            item['isSelected'] = value!;
                                          });
                                        },
                                        activeColor: Colors
                                            .grey, // Set checkbox active color to grey
                                        checkColor: Colors
                                            .white, // Set check color to white
                                      ),
                                    ),
                                    DataCell(
                                      Text(item['tarikh'] ?? 'N/A',
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                    DataCell(
                                      Text(item['perkara'] ?? 'N/A',
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                    DataCell(
                                      Text(item['item'] ?? 'N/A',
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                    DataCell(
                                      Text(item['harga_per_item'] ?? 'N/A',
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                    DataCell(
                                      Text(
                                          item['kuantiti']?.toString() ?? 'N/A',
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                    DataCell(
                                      Text(item['jumlah'] ?? 'N/A',
                                          style: const TextStyle(fontSize: 16)),
                                    ),
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
                                    ),
                                  ],
                                );
                              }).toList()
                            : [
                                DataRow(
                                  cells: [
                                    DataCell(Text(
                                      'No record',
                                      style: const TextStyle(fontSize: 16),
                                    )),
                                    DataCell(SizedBox
                                        .shrink()), // Empty cells for alignment
                                    DataCell(SizedBox.shrink()),
                                    DataCell(SizedBox.shrink()),
                                    DataCell(SizedBox.shrink()),
                                    DataCell(SizedBox.shrink()),
                                    DataCell(SizedBox.shrink()),
                                    DataCell(SizedBox.shrink()),
                                  ],
                                ),
                              ],
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
