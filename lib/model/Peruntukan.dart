import 'dart:io';
import 'dart:typed_data';

class Peruntukan {
  String? tarikhDiterima;
  String? catatan;
  double? amaun;
  Uint8List? file;

  Peruntukan({
    this.tarikhDiterima,
    this.catatan,
    this.amaun,
    this.file,
  });

  // Corrected factory constructor
  factory Peruntukan.fromJson(Map<String, dynamic> json) {
    return Peruntukan(
      tarikhDiterima: json['tarikhDiterima'],
      catatan: json['catatan'],
      amaun: json['amaun'],
      file: json['file'], // Ensure 'file' path is a valid File object
    );
  }
}
