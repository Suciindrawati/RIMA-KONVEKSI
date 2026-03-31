import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/transaksi_service.dart';
import '../../models/transaksi_model.dart';

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
    setState(() => _loading = true);
    try {
      final nama = await _authService.getNama();
      final data = await _transaksiService.getDashboard();
      if (mounted) setState(() { _dashData = data; _nama = nama ?? ''; });
    } catch (e) {
      // ignore on dashboard
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Halo, $_nama', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary Cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _summaryCard(
                        'Total Pendapatan',
                        _formatCurrency(_dashData?['total_pendapatan'] ?? 0),
                        Icons.attach_money,
                        const Color(0xFF4CAF50),
                      ),
                      _summaryCard(
                        'Total Transaksi',
                        '${_dashData?['total_transaksi'] ?? 0}',
                        Icons.receipt_long,
                        const Color(0xFF2196F3),
                      ),
                      _summaryCard(
                        'Total Pelanggan',
                        '${_dashData?['total_pelanggan'] ?? 0}',
                        Icons.people,
                        const Color(0xFFFF9800),
                      ),
                      _summaryCard(
                        'Total Produk',
                        '${_dashData?['total_produk'] ?? 0}',
                        Icons.inventory_2,
                        const Color(0xFF9C27B0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Transaksi Terbaru',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (recentTransaksi.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('Belum ada transaksi')),
                      ),
                    )
                  else
                    ...recentTransaksi.map((t) {
                      final trx = TransaksiModel.fromJson(t);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1565C0),
                            child: Text(
                              '${trx.jumlah}',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          title: Text(trx.namaPelanggan ?? 'Pelanggan'),
                          subtitle: Text(trx.namaProduk ?? 'Produk'),
                          trailing: Text(
                            _formatCurrency(trx.totalHarga),
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
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

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1565C0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.checkroom, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text('Rima Konveksi', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Admin Panel', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          _drawerItem(context, Icons.dashboard, 'Dashboard', '/dashboard-admin'),
          _drawerItem(context, Icons.people, 'Data Pelanggan', '/pelanggan'),
          _drawerItem(context, Icons.inventory_2, 'Data Produk', '/produk'),
          _drawerItem(context, Icons.receipt_long, 'Data Transaksi', '/transaksi'),
          _drawerItem(context, Icons.photo_library, 'Katalog Model', '/katalog'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  ListTile _drawerItem(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1565C0)),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}
