class KatalogModel {
  final int? id;
  final String judul;
  final String? deskripsi;
  final String? gambar;
  final String? createdAt;
  final List<String>? gallery;

  KatalogModel({
    this.id,
    required this.judul,
    this.deskripsi,
    this.gambar,
    this.createdAt,
    this.gallery,
  });

  factory KatalogModel.fromJson(Map<String, dynamic> json) {
    List<String>? gal;
    if (json['gambars'] != null) {
      gal = (json['gambars'] as List).map((e) => e['gambar'].toString()).toList();
    }
    return KatalogModel(
      id: json['id'],
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'],
      gambar: json['gambar'],
      createdAt: json['created_at'],
      gallery: gal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      'gambar': gambar,
    };
  }
}
