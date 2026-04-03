import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/transaksi_service.dart';
import '../../models/transaksi_model.dart';
import '../../models/pelanggan_model.dart';
import '../../constants/api_constants.dart';

class DashboardKaryawanScreen extends StatefulWidget {
  const DashboardKaryawanScreen({super.key});

  @override
  State<DashboardKaryawanScreen> createState() => _DashboardKaryawanScreenState();
}

class _DashboardKaryawanScreenState extends State<DashboardKaryawanScreen> {
  String _nama = '';
  final _ts = TransaksiService();
  List<TransaksiModel> _runningOrders = [];
  bool _loadingOrders = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loadingOrders = true);
    try {
      final nama = await AuthService().getNama();
      setState(() => _nama = nama ?? '');
      
      final res = await _ts.getPaginated(page: 1, status: ['Pesanan Dibuat', 'Diproses']);
      final List data = res['data'];
      
      if (mounted) {
        setState(() {
          _runningOrders = data.map((e) => TransaksiModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error load data home: $e');
    } finally {
      if (mounted) setState(() => _loadingOrders = false);
    }
  }

  void _showOrderDetail(TransaksiModel t) {
    final p = t.pelanggan;
    final pr = t.produk;
    final imgUrl = pr?.gambar != null ? '${ApiConstants.baseUrl.replaceAll('/api', '')}/storage/${pr!.gambar}' : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.all(16), width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                          child: imgUrl != null ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(imgUrl, fit: BoxFit.cover)) : const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                        const SizedBox(width: 20),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.namaProduk ?? 'Produk Tanpa Nama', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                              child: Text('${t.jumlah} PCS', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w900, fontSize: 10)),
                            ),
                          ],
                        ))
                      ],
                    ),
                    const Divider(height: 48, color: Color(0xFFF1F5F9)),
                    
                    Text('IDENTITAS PELANGGAN', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), fontSize: 11, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    Text(t.namaPelanggan ?? '-', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 20)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.message_rounded, color: Color(0xFF10B981), size: 16),
                        const SizedBox(width: 8),
                        Text(p?.noHp ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                      ],
                    ),
                    if (p?.keterangan != null && p!.keterangan!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFEDD5))),
                        child: Text('CATATAN: ${p.keterangan}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF9A3412))),
                      ),
                    ],

                    const Divider(height: 48, color: Color(0xFFF1F5F9)),
                    Text('PANDUAN UKURAN PRODUKSI (CM)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), fontSize: 11, letterSpacing: 1)),
                    const SizedBox(height: 16),
                    _buildSizeGroup('ATASAN / BAJU', p, isBaju: true),
                    _buildSizeGroup('BAWAHAN / CELANA', p, isCelana: true),
                    _buildSizeGroup('ROK', p, isRok: true),
                    
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('PAHAM, LANJUT PRODUKSI', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeGroup(String title, PelangganModel? p, {bool isBaju = false, bool isCelana = false, bool isRok = false}) {
    if (p == null) return const SizedBox.shrink();
    Map<String, String?> items = {};
    if (isBaju) {
      items = {'PU': p.bajuPu, 'PI': p.bajuPi, 'PA': p.bajuPa, 'LT': p.bajuLt, 'GN': p.bajuGn, 'LE': p.bajuLe, 'DA': p.bajuDa, 'PI (L)': p.bajuPiLingkar, 'PA (L)': p.bajuPaLingkar, 'BH': p.bajuBh, 'PU (Lebar)': p.bajuPuLebar, 'DA (Lebar)': p.bajuDaLebar, 'ATS': p.bajuAts, 'SK': p.bajuSk, 'BWH': p.bajuBwh, 'LGN A': p.bajuA, 'LGN B': p.bajuB};
    } else if (isCelana) {
      items = {'PI (L)': p.celanaPi, 'PA (L)': p.celanaPa, 'PH': p.celanaPh, 'LT': p.celanaLt, 'PSK': p.celanaPsk, 'P.LT': p.celanaLtPanjang, 'CLN': p.celanaCln};
    } else if (isRok) {
      items = {'PI (L)': p.rokPi, 'PA (L)': p.rokPa, 'P.PA': p.rokPaPanjang, 'LT': p.rokLt, 'ROK': p.rokRok};
    }

    final filtered = items.entries.where((e) => e.value != null && e.value!.isNotEmpty && e.value != 'null').toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: const Color(0xFFF97316))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: filtered.map((e) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${e.key}: ', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                Text(e.value!, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B))),
              ],
            ),
          )).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, $_nama!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 20)),
            const Text('Semangat bekerja hari ini!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20)),
            onPressed: _logout,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MENU UTAMA', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12, color: const Color(0xFF94A3B8), letterSpacing: 1)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _menuCard(context, Icons.people_alt_rounded, 'PELANGGAN', '/pelanggan', const Color(0xFFF97316))),
                  const SizedBox(width: 16),
                  Expanded(child: _menuCard(context, Icons.photo_library_rounded, 'KATALOG', '/katalog', const Color(0xFF1E293B))),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PESANAN MASUK', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12, color: const Color(0xFF94A3B8), letterSpacing: 1)),
                  if (!_loadingOrders && _runningOrders.isNotEmpty)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(6)), child: Text('${_runningOrders.length} AKTIF', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900))),
                ],
              ),
              const SizedBox(height: 16),
              if (_loadingOrders)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else if (_runningOrders.isEmpty)
                _emptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _runningOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final t = _runningOrders[index];
                    return Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: ListTile(
                        onTap: () => _showOrderDetail(t),
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.cut_rounded, color: Color(0xFFF97316)),
                        ),
                        title: Text(t.namaProduk ?? 'Pesanan Khusus', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('Pelanggan: ${t.namaPelanggan ?? "-"} • ${t.jumlah} Pcs', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCBD5E1)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.none)), // Transparent border or dotted?
      child: Column(
        children: [
          const Icon(Icons.task_alt_rounded, size: 48, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          const Text('Semua kerjaan beres!', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
          const Text('Tidak ada pesanan baru saat ini.', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _menuCard(BuildContext context, IconData icon, String label, String route, Color color) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 140,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
