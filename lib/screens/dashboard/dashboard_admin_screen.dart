import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/transaksi_service.dart';
import '../../models/transaksi_model.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  final _transaksiService = TransaksiService();
  final _authService = AuthService();
  Map<String, dynamic>? _dashData;
  bool _loading = true;
  String _nama = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final nama = await _authService.getNama();
      final data = await _transaksiService.getDashboard();
      if (mounted) {
        setState(() {
          _dashData = data;
          _nama = nama ?? 'Admin';
        });
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  String _formatCurrency(dynamic val) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return f.format(double.tryParse(val.toString()) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final List recentTransaksi = _dashData?['recent_transaksi'] ?? [];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RIMA KONVEKSI',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: const Color(0xFFF97316),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Dashboard Admin • $_nama',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
            onPressed: _load,
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Welcome Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF97316).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
                        const SizedBox(height: 16),
                        Text(
                          'Total Pendapatan Selesai',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(_dashData?['total_pendapatan'] ?? 0),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Summary Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _summaryCard(
                        'Transaksi',
                        '${_dashData?['total_transaksi'] ?? 0}',
                        Icons.receipt_long_rounded,
                        const Color(0xFF3B82F6),
                        subtitle: '${_dashData?['transaksi_selesai'] ?? 0} Selesai',
                      ),
                      _summaryCard(
                        'Pelanggan',
                        '${_dashData?['total_pelanggan'] ?? 0}',
                        Icons.people_alt_rounded,
                        const Color(0xFF10B981),
                      ),
                      _summaryCard(
                        'Katalog Produk',
                        '${_dashData?['total_produk'] ?? 0}',
                        Icons.inventory_2_rounded,
                        const Color(0xFF8B5CF6),
                      ),
                      _summaryCard(
                        'Model Pakaian',
                        '${_dashData?['total_katalog'] ?? 0}',
                        Icons.auto_fix_high_rounded,
                        const Color(0xFFF97316),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaksi Terbaru',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/transaksi'),
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (recentTransaksi.isEmpty)
                    _emptyState('Belum ada transaksi terbaru.')
                  else
                    ...recentTransaksi.map((t) {
                      final trx = TransaksiModel.fromJson(t);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFF97316)),
                          ),
                          title: Text(
                            trx.namaPelanggan ?? 'Tanpa Nama',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(trx.namaProduk ?? '-', style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: trx.status.contains('Selesai') ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  trx.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: trx.status.contains('Selesai') ? const Color(0xFF10B981) : const Color(0xFFF97316),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            _formatCurrency(trx.totalHarga),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 9, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
            ),
          ]
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, size: 48, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.content_cut_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'RIMA KONVEKSI',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: const Color(0xFFF97316),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _drawerItem(context, Icons.dashboard_rounded, 'Dashboard Utama', '/dashboard-admin'),
                _drawerItem(context, Icons.people_rounded, 'Manajemen Pelanggan', '/pelanggan'),
                _drawerItem(context, Icons.inventory_2_rounded, 'Stok Produk & Bahan', '/produk'),
                _drawerItem(context, Icons.receipt_rounded, 'Riwayat Transaksi', '/transaksi'),
                _drawerItem(context, Icons.auto_fix_high_rounded, 'Katalog Model', '/katalog'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Color(0xFFF1F5F9)),
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: Text(
                    'Keluar Aplikasi',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.redAccent),
                  ),
                  onTap: _logout,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, String route) {
    final bool isSelected = ModalRoute.of(context)?.settings.name == route;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFFF97316) : const Color(0xFF64748B)),
      title: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? const Color(0xFFF97316) : const Color(0xFF1E293B),
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFFFFF7ED),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) Navigator.pushNamed(context, route);
      },
    );
  }
}
