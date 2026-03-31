import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/transaksi_service.dart';
import '../../models/transaksi_model.dart';
import '../../models/pelanggan_model.dart';
import '../../constants/api_constants.dart';
import 'package:intl/intl.dart';

class DashboardKaryawanScreen extends StatefulWidget {
  const DashboardKaryawanScreen({super.key});

  @override
  State<DashboardKaryawanScreen> createState() => _DashboardKaryawanScreenState();
}

class _DashboardKaryawanScreenState extends State<DashboardKaryawanScreen> {
  String _nama = '';
  final _transaksiService = TransaksiService();
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
      
      final res = await _transaksiService.getPaginated(page: 1, status: 'Pesanan Dibuat');
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
    final imgUrl = pr?.gambar != null
        ? '${ApiConstants.baseUrl.replaceAll('/api', '')}/storage/${pr!.gambar}'
        : null;

    // Cek apakah ada data ukuran sama sekali
    bool hasAnySize = false;
    if (p != null) {
      final allSizes = [
        p.bajuPu, p.bajuPi, p.bajuPa, p.bajuLt, p.bajuGn, p.bajuLe, p.bajuDa, p.bajuPiLingkar, p.bajuPaLingkar,
        p.celanaPi, p.celanaPa, p.celanaPh, p.celanaLt, p.celanaPsk,
        p.rokPi, p.rokPa, p.rokLt
      ];
      hasAnySize = allSizes.any((s) => s != null && s.isNotEmpty);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (imgUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(imgUrl, width: 80, height: 80, fit: BoxFit.cover),
                          )
                        else
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        const SizedBox(width: 16),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.namaProduk ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('Jumlah: ${t.jumlah} Pcs', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(t.status, style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ))
                      ],
                    ),
                    const Divider(height: 32),
                    const Text('DETAIL PELANGGAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(t.namaPelanggan ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(p?.noHp ?? '-', style: const TextStyle(color: Colors.grey)),
                    if (p?.keterangan != null && p!.keterangan!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Catatan: ${p.keterangan}', style: const TextStyle(fontStyle: FontStyle.italic)),
                    ],
                    const Divider(height: 32),
                    const Text('UKURAN BADAN (CM)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    if (!hasAnySize)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text('Data ukuran belum diisi untuk pelanggan ini.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        ),
                      )
                    else ...[
                      _buildSizeSection('BAJU / ATASAN', {
                        'PU': p?.bajuPu, 'PI': p?.bajuPi, 'PA': p?.bajuPa, 'LT': p?.bajuLt, 'GN': p?.bajuGn,
                        'LE': p?.bajuLe, 'DA': p?.bajuDa, 'PI (Lingkar)': p?.bajuPiLingkar, 'PA (Lingkar)': p?.bajuPaLingkar,
                        'BH': p?.bajuBh, 'PU (Lebar)': p?.bajuPuLebar, 'DA (Lebar)': p?.bajuDaLebar,
                      }),
                      _buildSizeSection('CELANA', {
                        'PI': p?.celanaPi, 'PA': p?.celanaPa, 'PH': p?.celanaPh, 'LT': p?.celanaLt, 'PSK': p?.celanaPsk,
                        'LT (Pjg)': p?.celanaLtPanjang, 'CLN': p?.celanaCln,
                      }),
                      _buildSizeSection('ROK', {
                        'PI': p?.rokPi, 'PA': p?.rokPa, 'LT': p?.rokLt, 'PA (Pjg)': p?.rokPaPanjang, 'ROK': p?.rokRok,
                      }),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSection(String title, Map<String, String?> sizes) {
    final validSizes = sizes.entries.where((e) => e.value != null && e.value!.isNotEmpty).toList();
    if (validSizes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: validSizes.map((e) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${e.key}: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(e.value!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          )).toList(),
        ),
        const SizedBox(height: 16),
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard Karyawan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Halo, $_nama', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Menu Utama',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _menuCard(context, Icons.people, 'Data Pelanggan', '/pelanggan', const Color(0xFF1565C0))),
                  const SizedBox(width: 12),
                  Expanded(child: _menuCard(context, Icons.photo_library, 'Katalog Model', '/katalog', const Color(0xFFFF9800))),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Pesanan Sedang Diproses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
              ),
              const SizedBox(height: 8),
              if (_loadingOrders)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else if (_runningOrders.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('Tidak ada pesanan aktif', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _runningOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final t = _runningOrders[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: InkWell(
                        onTap: () => _showOrderDetail(t),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.assignment_outlined, color: Color(0xFF1565C0)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.namaProduk ?? 'Produk tidak tersedia',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pelanggan: ${t.namaPelanggan ?? "-"}',
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                    ),
                                    Text(
                                      'Jumlah: ${t.jumlah} Pcs',
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'PROSES',
                                  style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, IconData icon, String label, String route, Color color) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
