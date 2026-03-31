class KatalogModel {
  final int? id;
  final String judul;
  final String? deskripsi;
  final String? gambar;
  final String? createdAt;

  KatalogModel({
    this.id,
    required this.judul,
    this.deskripsi,
    this.gambar,
    this.createdAt,
  });

  factory KatalogModel.fromJson(Map<String, dynamic> json) {
    return KatalogModel(
      id: json['id'],
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'],
      gambar: json['gambar'],
      createdAt: json['created_at'],
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
