import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/transaksi_model.dart';
import '../../models/pelanggan_model.dart';
import '../../models/produk_model.dart';
import '../../services/transaksi_service.dart';
import '../../services/pelanggan_service.dart';
import '../../services/produk_service.dart';
import '../../services/auth_service.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});
  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final _ts = TransaksiService();
  final _scrollController = ScrollController();
  final _auth = AuthService();
  
  List<TransaksiModel> _list = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _isLastPage = false;
  int _page = 1;
  String _role = '';
  dynamic _selectedStatus;
  
  final _searchController = TextEditingController();
  DateTime? _debounceTime;

  final List<Map<String, dynamic>> _statusFilters = [
    {'label': 'Semua', 'value': null},
    {'label': 'Dibuat', 'value': 'Pesanan Dibuat'},
    {'label': 'Proses', 'value': 'Diproses'},
    {'label': 'Selesai', 'value': ['Pesanan Selesai', 'Selesai']},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_loading && !_loadingMore && !_isLastPage) {
        _loadMore();
      }
    }
  }

  Future<void> _loadInitial() async {
    setState(() { _loading = true; _page = 1; _isLastPage = false; _list = []; });
    try {
      final role = await _auth.getRole();
      final res = await _ts.getPaginated(page: 1, search: _searchController.text, status: _selectedStatus);
      final List data = res['data'];
      if (mounted) {
        setState(() {
          _role = role ?? '';
          _list = data.map((e) => TransaksiModel.fromJson(e)).toList();
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
      final res = await _ts.getPaginated(page: _page, search: _searchController.text, status: _selectedStatus);
      final List data = res['data'];
      if (mounted) {
        setState(() {
          _list.addAll(data.map((e) => TransaksiModel.fromJson(e)).toList());
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

  void _onSearchChanged(String v) {
    if (_debounceTime?.isAfter(DateTime.now()) ?? false) return;
    _debounceTime = DateTime.now().add(const Duration(milliseconds: 600));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _loadInitial();
    });
  }

  Future<void> _updateStatus(TransaksiModel t) async {
    if (_role != 'admin') return;
    String newStatus = '';
    if (t.status == 'Pesanan Dibuat') newStatus = 'Diproses';
    else if (t.status == 'Diproses') newStatus = 'Selesai';
    else return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Update Status'),
        content: Text('Tandai pesanan ini sebagai "$newStatus"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Update')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        if (newStatus == 'Selesai') {
          final h = await _askHarga();
          if (h != null) {
            await _ts.update(t.id!, {'status': newStatus, 'total_harga': h});
            _loadInitial();
          }
        } else {
          await _ts.update(t.id!, {'status': newStatus});
          _loadInitial();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  Future<int?> _askHarga() async {
    final ctrl = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Input Harga Akhir'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Total Harga (Rp)', hintText: 'Contoh: 150000'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text)), child: const Text('Simpan')),
        ],
      ),
    );
  }

  String _formatCurrency(double? n) => NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(n ?? 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Riwayat Transaksi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadInitial)],
      ),
      floatingActionButton: _role == 'admin'
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/transaksi-form').then((_) => _loadInitial()),
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text('Pesanan Baru'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(hintText: 'Cari Pelanggan / Produk...', prefixIcon: Icon(Icons.search_rounded)),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: _statusFilters.map((f) {
                final isSelected = _selectedStatus == f['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f['label']!, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : const Color(0xFF64748B))),
                    selected: isSelected,
                    onSelected: (v) {
                      setState(() => _selectedStatus = f['value']);
                      _loadInitial();
                    },
                    selectedColor: const Color(0xFFF97316),
                    backgroundColor: Colors.white,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50), side: BorderSide(color: isSelected ? const Color(0xFFF97316) : const Color(0xFFE2E8F0))),
                  ),
                );
              }).toList(),
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
                              final t = _list[i];
                              return _buildTransactionCard(t);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransaksiModel t) {
    Color tagColor;
    Color textColor;
    Color bgColor;

    if (t.status.contains('Selesai')) {
      tagColor = const Color(0xFF10B981); // Green
      textColor = const Color(0xFF10B981);
      bgColor = const Color(0xFFF0FDF4);
    } else if (t.status == 'Diproses') {
      tagColor = const Color(0xFFF97316); // Orange
      textColor = const Color(0xFFF97316);
      bgColor = const Color(0xFFFFF7ED);
    } else {
      tagColor = const Color(0xFF3B82F6); // Blue for "Pesanan Dibuat"
      textColor = const Color(0xFF3B82F6);
      bgColor = const Color(0xFFEFF6FF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: InkWell(
        onTap: () => _updateStatus(t),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(t.tanggal ?? DateTime.now().toIso8601String())), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      t.status.toUpperCase(),
                      style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(t.namaPelanggan ?? '-', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 4),
              Text(t.namaProduk ?? '-', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const Divider(height: 32, color: Color(0xFFF1F5F9)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('JUMLAH', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text('${t.jumlah} Pcs', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('TOTAL HARGA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text(_formatCurrency(t.totalHarga), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFF1E293B), fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 180,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        ),
      ),
    );
  }

  Widget _buildMoreShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 150,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: Text('Semua riwayat telah dimuat', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
    );
  }

  Widget _emptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Icon(Icons.receipt_long_rounded, size: 64, color: Color(0xFFCBD5E1)),
        const SizedBox(height: 16),
        const Center(child: Text('Belum ada riwayat transaksi.', style: TextStyle(color: Color(0xFF64748B)))),
      ],
    );
  }
}

class TransaksiFormScreen extends StatefulWidget {
  const TransaksiFormScreen({super.key});
  @override
  State<TransaksiFormScreen> createState() => _TransaksiFormScreenState();
}

class _TransaksiFormScreenState extends State<TransaksiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ts = TransaksiService();
  final _pelangganService = PelangganService();
  final _produkService = ProdukService();

  List<PelangganModel> _pelangganList = [];
  List<ProdukModel> _produkList = [];
  PelangganModel? _selectedPelanggan;
  ProdukModel? _selectedProduk;
  final _jumlahCtrl = TextEditingController(text: '1');
  bool _loading = false;
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final p = await _pelangganService.getAll();
      final pr = await _produkService.getAll();
      if (mounted) setState(() { _pelangganList = p; _produkList = pr; _loadingData = false; });
    } catch (e) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); setState(() => _loadingData = false); }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPelanggan == null || _selectedProduk == null) return;
    setState(() => _loading = true);
    try {
      final t = TransaksiModel(
        pelangganId: _selectedPelanggan!.id!,
        produkId: _selectedProduk!.id!,
        jumlah: int.parse(_jumlahCtrl.text),
        status: 'Pesanan Dibuat',
        tanggal: DateTime.now().toIso8601String(),
      );
      await _ts.create(t);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan Berhasil Dibuat!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: Text('Input Pesanan Baru', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFFFEDD5))),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: Color(0xFFF97316)),
                        const SizedBox(width: 16),
                        Expanded(child: Text('Simpan pesanan untuk mulai produksi. Harga akhir akan ditentukan setelah penjahitan selesai.', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF9A3412)))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  DropdownButtonFormField<PelangganModel>(
                    decoration: const InputDecoration(labelText: 'Pilih Pelanggan', prefixIcon: Icon(Icons.person_search_rounded)),
                    value: _selectedPelanggan,
                    items: _pelangganList.map((p) => DropdownMenuItem(value: p, child: Text(p.nama, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))).toList(),
                    onChanged: (v) => setState(() => _selectedPelanggan = v),
                    validator: (v) => v == null ? 'Pilih pelanggan' : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<ProdukModel>(
                    decoration: const InputDecoration(labelText: 'Model / Jenis Bahan', prefixIcon: Icon(Icons.inventory_2_rounded)),
                    value: _selectedProduk,
                    items: _produkList.map((p) => DropdownMenuItem(value: p, child: Text(p.namaProduk, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))).toList(),
                    onChanged: (v) => setState(() => _selectedProduk = v),
                    validator: (v) => v == null ? 'Pilih produk' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _jumlahCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Jumlah Pesanan (Pcs)', prefixIcon: Icon(Icons.add_shopping_cart_rounded)),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _save,
                      child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('BUAT PESANAN SEKARANG', style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
