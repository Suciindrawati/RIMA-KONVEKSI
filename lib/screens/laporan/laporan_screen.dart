import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/transaksi_service.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final _transaksiService = TransaksiService();
  List<Map<String, dynamic>> _riwayatLaporan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final riwayatStr = prefs.getString('riwayat_laporan');
    if (riwayatStr != null) {
      final List decoded = jsonDecode(riwayatStr);
      _riwayatLaporan = decoded.cast<Map<String, dynamic>>();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveRiwayat(int bulan, int tahun, String path) async {
    final prefs = await SharedPreferences.getInstance();
    final item = {
      'bulan': bulan,
      'tahun': tahun,
      'path': path,
      'tanggal_unduh': DateTime.now().toIso8601String(),
    };
    
    // Insert at the beginning
    _riwayatLaporan.insert(0, item);
    
    // Keep only last 50 reports to prevent overflow
    if (_riwayatLaporan.length > 50) _riwayatLaporan.removeLast();
    
    await prefs.setString('riwayat_laporan', jsonEncode(_riwayatLaporan));
    setState(() {});
  }
  
  Future<void> _hapusSemuaRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('riwayat_laporan');
    setState(() => _riwayatLaporan.clear());
  }

  void _showDownloadLaporanDialog() {
    int selectedBulan = DateTime.now().month;
    int selectedTahun = DateTime.now().year;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Unduh Laporan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedBulan,
                    decoration: InputDecoration(
                      labelText: 'Bulan',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem(
                        value: month,
                        child: Text(DateFormat('MMMM', 'id_ID').format(DateTime(2024, month))),
                      );
                    }),
                    onChanged: (val) => setStateDialog(() => selectedBulan = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedTahun,
                    decoration: InputDecoration(
                      labelText: 'Tahun',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - 2 + index;
                      return DropdownMenuItem(value: year, child: Text(year.toString()));
                    }),
                    onChanged: (val) => setStateDialog(() => selectedTahun = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Tutup dialog pertama
                    
                    if (!mounted) return;
                    
                    showDialog(
                      context: this.context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    
                    try {
                      final path = await _transaksiService.downloadLaporanPdf(selectedBulan, selectedTahun);
                      
                      if (!mounted) return;
                      Navigator.pop(this.context); // Tutup dialog loading
                      
                      if (path != null) {
                        await _saveRiwayat(selectedBulan, selectedTahun, path);
                        final result = await OpenFile.open(path, type: 'application/pdf');
                        if (result.type != ResultType.done && mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(content: Text('Gagal membuka file: ${result.message}'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        Navigator.pop(this.context); // Tutup dialog loading
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Unduh & Buka', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Laporan Transaksi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          if (_riwayatLaporan.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Riwayat?'),
                    content: const Text('Apakah Anda yakin ingin menghapus semua riwayat laporan lokal? File PDF asli tidak akan terhapus.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _hapusSemuaRiwayat();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Hapus Riwayat',
            )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showDownloadLaporanDialog,
        backgroundColor: const Color(0xFFF97316),
        icon: const Icon(Icons.download_rounded, color: Colors.white),
        label: const Text('Laporan Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _riwayatLaporan.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_rounded, size: 64, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 16),
                      Text('Belum ada riwayat unduhan laporan.', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20).copyWith(bottom: 100),
                  itemCount: _riwayatLaporan.length,
                  itemBuilder: (context, index) {
                    final item = _riwayatLaporan[index];
                    final bulan = item['bulan'];
                    final tahun = item['tahun'];
                    final tanggalUnduh = DateTime.parse(item['tanggal_unduh']);
                    final path = item['path'];

                    final namaBulan = DateFormat('MMMM', 'id_ID').format(DateTime(2024, bulan));

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFF97316)),
                        ),
                        title: Text(
                          'Laporan $namaBulan $tahun',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: Text(
                          'Diunduh pada ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(tanggalUnduh)}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        trailing: const Icon(Icons.open_in_new_rounded, size: 20, color: Color(0xFFCBD5E1)),
                        onTap: () async {
                          try {
                            final result = await OpenFile.open(path, type: 'application/pdf');
                            if (result.type != ResultType.done && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal: ${result.message}')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gagal membuka file. Mungkin file sudah terhapus.')),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
