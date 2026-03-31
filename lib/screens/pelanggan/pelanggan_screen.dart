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
  final _scrollController = ScrollController();
  
  List<PelangganModel> _list = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _isLastPage = false;
  int _page = 1;
  String _role = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _searchCtrl.addListener(_onSearch);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    // Note: Search implementation might need to be server-side for large data
    // For now we keep local filter for current loaded items
    setState(() {});
  }

  List<PelangganModel> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _list;
    return _list.where((p) => p.nama.toLowerCase().contains(q) || p.noHp.contains(q)).toList();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _page = 1;
      _isLastPage = false;
      _list = [];
    });
    try {
      final role = await AuthService().getRole();
      final res = await _service.getPaginated(1);
      final List data = res['data'];
      if (mounted) {
        setState(() {
          _role = role ?? '';
          _list = data.map((e) => PelangganModel.fromJson(e)).toList();
          _isLastPage = res['current_page'] >= res['last_page'];
          _page = 2;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _isLastPage) return;
    setState(() => _loadingMore = true);
    try {
      final res = await _service.getPaginated(_page);
      final List data = res['data'];
      if (mounted) {
        setState(() {
          _list.addAll(data.map((e) => PelangganModel.fromJson(e)).toList());
          _isLastPage = res['current_page'] >= res['last_page'];
          _page++;
        });
      }
    } catch (e) {
      debugPrint('Error load more: $e');
    } finally {
      if (mounted) setState(() => _loadingMore = false);
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
      try {
        await _service.delete(p.id!);
        _loadInitial();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
      }
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
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadInitial)],
      ),
      floatingActionButton: _role == 'admin'
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.pushNamed(context, '/pelanggan-form');
                _loadInitial();
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
                        onRefresh: _loadInitial,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filtered.length + (_isLastPage ? 1 : 0),
                          itemBuilder: (ctx, i) {
                            if (i == _filtered.length) {
                               return const Padding(
                                 padding: EdgeInsets.symmetric(vertical: 20),
                                 child: Center(child: Text('Semua data telah dimuat', style: TextStyle(color: Colors.grey))),
                               );
                            }
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
                                                arguments: p).then((_) => _loadInitial());
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
          if (_loadingMore)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

