import 'dart:typed_data';

class Perbelanjaan {
  String? perkara, item, tarikh;
  int? kuantiti;
  double? harga_per_item, jumlah;
  Uint8List? file;

  Perbelanjaan(
      {this.perkara,
      this.item,
      this.tarikh,
      this.kuantiti,
      this.harga_per_item,
      this.jumlah,
      this.file});

  factory Perbelanjaan.fromJson(Map<String, dynamic> json) {
    return Perbelanjaan(
        perkara: json['perkara'],
        item: json['item'],
        tarikh: json['tarikh'],
        kuantiti: json['kuantiti'],
        harga_per_item: json['harga_per_item'],
        jumlah: json['jumlah'],
        file: json['file']);
  }
}
