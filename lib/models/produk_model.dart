class ProdukModel {
  final int? id;
  final String namaProduk;
  final String jenisProduk;
  final int stok;
  final String? deskripsi;
  final String? gambar;

  ProdukModel({
    this.id,
    required this.namaProduk,
    required this.jenisProduk,
    required this.stok,
    this.deskripsi,
    this.gambar,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      id: json['id'],
      namaProduk: json['nama_produk'] ?? '',
      jenisProduk: json['jenis_produk'] ?? '',
      stok: int.tryParse(json['stok'].toString()) ?? 0,
      deskripsi: json['deskripsi'],
      gambar: json['gambar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_produk': namaProduk,
      'jenis_produk': jenisProduk,
      'stok': stok,
      'deskripsi': deskripsi,
      'gambar': gambar,
    };
  }
}
