import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/pelanggan_service.dart';
import '../../models/pelanggan_model.dart';

class PelangganScreen extends StatefulWidget {
  const PelangganScreen({super.key});

  @override
  State<PelangganScreen> createState() => _PelangganScreenState();
}

class _PelangganScreenState extends State<PelangganScreen> {
  final _service = PelangganService();
  List<PelangganModel> _list = [];
  List<PelangganModel> _filtered = [];
  bool _loading = true;
  String _role = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _list.where((p) => p.nama.toLowerCase().contains(q) || p.noHp.contains(q)).toList();
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final role = await AuthService().getRole();
      final list = await _service.getAll();
      if (mounted) setState(() { _role = role ?? ''; _list = list; _filtered = list; });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(PelangganModel p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pelanggan'),
        content: Text('Yakin hapus ${p.nama}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _service.delete(p.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Data Pelanggan'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: _role == 'admin'
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.pushNamed(context, '/pelanggan-form');
                _load();
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari nama / no HP...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('Belum ada data pelanggan'))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) {
                            final p = _filtered[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF1565C0),
                                  child: Text(
                                    p.nama.isNotEmpty ? p.nama[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(p.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('HP: ${p.noHp}'),
                                isThreeLine: false,
                                trailing: _role == 'admin'
                                    ? PopupMenuButton<String>(
                                        onSelected: (v) {
                                          if (v == 'edit') {
                                            Navigator.pushNamed(context, '/pelanggan-form',
                                                arguments: p).then((_) => _load());
                                          } else {
                                            _delete(p);
                                          }
                                        },
                                        itemBuilder: (_) => [
                                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                          const PopupMenuItem(value: 'hapus', child: Text('Hapus')),
                                        ],
                                      )
                                    : null,
                                onTap: () => Navigator.pushNamed(context, '/pelanggan-detail', arguments: p),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
