import 'pelanggan_model.dart';
import 'produk_model.dart';

class TransaksiModel {
  final int? id;
  final int pelangganId;
  final int produkId;
  final int jumlah;
  final double? totalHarga;
  final String status;
  final String? tanggal;
  final String? namaPelanggan;
  final String? namaProduk;
  final PelangganModel? pelanggan;
  final ProdukModel? produk;

  TransaksiModel({
    this.id,
    required this.pelangganId,
    required this.produkId,
    required this.jumlah,
    this.totalHarga,
    required this.status,
    this.tanggal,
    this.namaPelanggan,
    this.namaProduk,
    this.pelanggan,
    this.produk,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    return TransaksiModel(
      id: json['id'],
      pelangganId: json['pelanggan_id'] ?? 0,
      produkId: json['produk_id'] ?? 0,
      jumlah: int.tryParse(json['jumlah'].toString()) ?? 0,
      totalHarga: json['total_harga'] != null ? double.tryParse(json['total_harga'].toString()) : null,
      status: json['status'] ?? 'Pesanan Dibuat',
      tanggal: json['tanggal'] ?? json['created_at'],
      namaPelanggan: json['pelanggan']?['nama'],
      namaProduk: json['produk']?['nama_produk'],
      pelanggan: json['pelanggan'] != null ? PelangganModel.fromJson(json['pelanggan']) : null,
      produk: json['produk'] != null ? ProdukModel.fromJson(json['produk']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pelanggan_id': pelangganId,
      'produk_id': produkId,
      'jumlah': jumlah,
      'total_harga': totalHarga,
      'status': status,
      'tanggal': tanggal,
    };
  }
}
