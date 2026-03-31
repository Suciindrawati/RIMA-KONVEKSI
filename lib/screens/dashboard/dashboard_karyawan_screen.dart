import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class DashboardKaryawanScreen extends StatefulWidget {
  const DashboardKaryawanScreen({super.key});

  @override
  State<DashboardKaryawanScreen> createState() => _DashboardKaryawanScreenState();
}

class _DashboardKaryawanScreenState extends State<DashboardKaryawanScreen> {
  String _nama = '';

  @override
  void initState() {
    super.initState();
    _loadNama();
  }

  Future<void> _loadNama() async {
    final nama = await AuthService().getNama();
    if (mounted) setState(() => _nama = nama ?? '');
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
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menu Tersedia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _menuCard(context, Icons.people, 'Data Pelanggan', '/pelanggan', const Color(0xFF1565C0)),
                  _menuCard(context, Icons.receipt_long, 'Transaksi', '/transaksi', const Color(0xFF4CAF50)),
                  _menuCard(context, Icons.photo_library, 'Katalog Model', '/katalog', const Color(0xFFFF9800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, IconData icon, String label, String route, Color color) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
