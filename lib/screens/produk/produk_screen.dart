import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/produk_model.dart';
import '../../services/auth_service.dart';
import '../../services/produk_service.dart';
import '../../constants/api_constants.dart';

class ProdukScreen extends StatefulWidget {
  const ProdukScreen({super.key});

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  final _service = ProdukService();
  List<ProdukModel> _list = [];
  bool _loading = true;
  String _role = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final role = await AuthService().getRole();
      final list = await _service.getAll();
      if (mounted) setState(() { _role = role ?? ''; _list = list; });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(ProdukModel p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin hapus ${p.namaProduk}?'),
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
        title: const Text('Data Produk'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: _role == 'admin'
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.pushNamed(context, '/produk-form');
                _load();
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const Center(child: Text('Belum ada data produk'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _list.length,
                    itemBuilder: (ctx, i) {
                      final p = _list[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF9C27B0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: p.gambar != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      '${ApiConstants.baseUrl.replaceAll('/api', '')}/storage/${p.gambar}',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
                                    ),
                                  )
                                : const Icon(Icons.inventory_2, color: Color(0xFF9C27B0)),
                          ),
                          title: Text(p.namaProduk, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Jenis: ${p.jenisProduk}'),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: p.stok > 0 ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Stok: ${p.stok}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: p.stok > 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: _role == 'admin'
                              ? PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') {
                                      Navigator.pushNamed(context, '/produk-form', arguments: p)
                                          .then((_) => _load());
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
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
