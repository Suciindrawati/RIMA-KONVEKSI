import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
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
  DateTime? _debounceTime;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_loading && !_loadingMore && !_isLastPage) {
        _loadMore();
      }
    }
  }

  void _onSearch(String v) {
    if (_debounceTime?.isAfter(DateTime.now()) ?? false) return;
    _debounceTime = DateTime.now().add(const Duration(milliseconds: 600));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _loadInitial();
    });
  }

  Future<void> _loadInitial() async {
    setState(() { _loading = true; _page = 1; _isLastPage = false; _list = []; });
    try {
      final role = await AuthService().getRole();
      final res = await _service.getPaginated(1, search: _searchCtrl.text);
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final res = await _service.getPaginated(_page, search: _searchCtrl.text);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Pelanggan'),
        content: Text('Yakin hapus data ${p.nama}? Seluruh riwayatnya mungkin akan berpengaruh.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _service.delete(p.id!);
        _loadInitial();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Database Pelanggan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadInitial)],
      ),
      floatingActionButton: _role == 'admin'
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/pelanggan-form').then((_) => _loadInitial()),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Tambah Pelanggan'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              decoration: const InputDecoration(hintText: 'Cari Nama / No WhatsApp...', prefixIcon: Icon(Icons.search_rounded), contentPadding: EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
          Expanded(
            child: _loading
                ? _buildInitialShimmer()
                : RefreshIndicator(
                    onRefresh: _loadInitial,
                    child: _list.isEmpty
                        ? _emptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _list.length + 1,
                            itemBuilder: (ctx, i) {
                              if (i == _list.length) {
                                return _loadingMore ? _buildMoreShimmer() : (_isLastPage && _list.isNotEmpty ? _buildFooter() : const SizedBox(height: 100));
                              }
                              final p = _list[i];
                              return _buildListItem(p);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(PelangganModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => Navigator.pushNamed(context, '/pelanggan-detail', arguments: p),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(p.nama.isNotEmpty ? p.nama[0].toUpperCase() : '?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFFF97316)))),
        ),
        title: Text(p.nama, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        subtitle: Text('WhatsApp: ${p.noHp}', style: const TextStyle(fontSize: 12)),
        trailing: _role == 'admin'
            ? PopupMenuButton<String>(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (v) {
                  if (v == 'edit') Navigator.pushNamed(context, '/pelanggan-form', arguments: p).then((_) => _loadInitial());
                  else _delete(p);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 18), SizedBox(width: 8), Text('Ubah Data')])),
                  const PopupMenuItem(value: 'hapus', child: Row(children: [Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
                ],
              )
            : const Icon(Icons.chevron_right_rounded, color: Color(0xFFE2E8F0)),
      ),
    );
  }

  Widget _buildInitialShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 8,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(height: 80, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
      ),
    );
  }

  Widget _buildMoreShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(height: 80, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
    );
  }

  Widget _buildFooter() {
    return const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: Text('Semua pelanggan telah dimuat', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))));
  }

  Widget _emptyState() {
    return ListView(children: [SizedBox(height: MediaQuery.of(context).size.height * 0.2), const Icon(Icons.person_off_rounded, size: 64, color: Color(0xFFCBD5E1)), const SizedBox(height: 16), const Center(child: Text('Belum ada data pelanggan.', style: TextStyle(color: Color(0xFF64748B))))]);
  }
}
