class Perkara {
  int? id;
  String description;

  Perkara(this.id, this.description);
  Perkara.withoutid(this.description);

  // A factory method to create a Perkara instance from a JSON object
  factory Perkara.fromJson(Map<String, dynamic> json) {
    return Perkara(
      json['id'],
      json['description'],
    );
  }
}
