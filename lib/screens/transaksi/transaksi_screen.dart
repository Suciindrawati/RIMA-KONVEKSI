import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final _transaksiService = TransaksiService();
  final _scrollController = ScrollController();
  final _auth = AuthService();
  
  List<TransaksiModel> _list = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _isLastPage = false;
  int _page = 1;
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _page = 1;
      _isLastPage = false;
      _list = [];
    });
    try {
      final role = await _auth.getRole();
      final res = await _transaksiService.getPaginated(page: 1);
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _isLastPage) return;
    setState(() => _loadingMore = true);
    try {
      final res = await _transaksiService.getPaginated(page: _page);
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

  String _formatCurrency(double? val) {
    if (val == null) return '-';
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(val);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pesanan Selesai': return Colors.green;
      case 'Sedang Dalam Pengerjaan': return Colors.orange;
      default: return Colors.blue;
    }
  }

  void _showStatusDialog(TransaksiModel t) {
    if (_role != 'admin') return; 
    if (t.status == 'Pesanan Selesai') return; 

    showDialog(
      context: context,
      builder: (ctx) {
        final hargaCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('Update Status Pesanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (t.status == 'Pesanan Dibuat')
                ListTile(
                  leading: const Icon(Icons.build, color: Colors.orange),
                  title: const Text('Mulai Pengerjaan'),
                  onTap: () async {
                    await _transaksiService.update(t.id!, {'status': 'Sedang Dalam Pengerjaan'});
                    Navigator.pop(ctx);
                    _loadInitial();
                  },
                ),
              if (t.status == 'Sedang Dalam Pengerjaan' || t.status == 'Pesanan Dibuat')
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Selesaikan Pesanan'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (sc) => AlertDialog(
                        title: const Text('Input Harga Selesai'),
                        content: TextField(
                          controller: hargaCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Total Harga Pesanan', prefixText: 'Rp '),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(sc), child: const Text('Batal')),
                          ElevatedButton(
                            onPressed: () async {
                              final price = double.tryParse(hargaCtrl.text) ?? 0;
                              await _transaksiService.update(t.id!, {
                                'status': 'Pesanan Selesai',
                                'total_harga': price,
                              });
                              Navigator.pop(sc);
                              Navigator.pop(ctx);
                              _loadInitial();
                            },
                            child: const Text('Simpan & Selesai'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Daftar Transaksi / Orderan'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadInitial)],
      ),
      floatingActionButton: _role == 'admin'
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.pushNamed(context, '/transaksi-form');
                _loadInitial();
              },
              icon: const Icon(Icons.add),
              label: const Text('Buat Pesanan'),
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _list.isEmpty
                    ? const Center(child: Text('Belum ada transaksi'))
                    : RefreshIndicator(
                        onRefresh: _loadInitial,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: _list.length + (_isLastPage ? 1 : 0),
                          itemBuilder: (ctx, i) {
                            if (i == _list.length) {
                               return const Padding(
                                 padding: EdgeInsets.symmetric(vertical: 20),
                                 child: Center(child: Text('Semua data telah dimuat', style: TextStyle(color: Colors.grey))),
                               );
                            }
                            final t = _list[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                onTap: _role == 'admin' ? () => _showStatusDialog(t) : null,
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(t.status).withOpacity(0.1),
                                  child: Icon(
                                    t.status == 'Pesanan Selesai' ? Icons.check_circle : (t.status == 'Sedang Dalam Pengerjaan' ? Icons.build : Icons.receipt_long),
                                    color: _getStatusColor(t.status),
                                    size: 20,
                                  ),
                                ),
                                title: Text(t.namaPelanggan ?? 'Pelanggan'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${t.namaProduk ?? 'Produk'} x${t.jumlah}'),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(t.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(t.status, style: TextStyle(fontSize: 10, color: _getStatusColor(t.status), fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(_formatCurrency(t.totalHarga), style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
                                    if (_role == 'admin' && t.status != 'Pesanan Selesai')
                                      const Text('Klik utk Update', style: TextStyle(fontSize: 9, color: Colors.grey)),
                                  ],
                                ),
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

class TransaksiFormScreen extends StatefulWidget {
  const TransaksiFormScreen({super.key});
  @override
  State<TransaksiFormScreen> createState() => _TransaksiFormScreenState();
}

class _TransaksiFormScreenState extends State<TransaksiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _transaksiService = TransaksiService();
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
      await _transaksiService.create(t);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan Berhasil Dibuat')));
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
      appBar: AppBar(title: const Text('Buat Pesanan Baru'), backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                   const Text('Input data untuk pesanan baru. Harga akan diinput oleh Admin setelah pesanan selesai.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<PelangganModel>(
                    decoration: const InputDecoration(labelText: 'Nama Pelanggan', border: OutlineInputBorder()),
                    value: _selectedPelanggan,
                    items: _pelangganList.map((p) => DropdownMenuItem(value: p, child: Text(p.nama))).toList(),
                    onChanged: (v) => setState(() => _selectedPelanggan = v),
                    validator: (v) => v == null ? 'Wajib pilih pelanggan' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ProdukModel>(
                    decoration: const InputDecoration(labelText: 'Produk Konveksi', border: OutlineInputBorder()),
                    value: _selectedProduk,
                    items: _produkList.map((p) => DropdownMenuItem(value: p, child: Text(p.namaProduk))).toList(),
                    onChanged: (v) => setState(() => _selectedProduk = v),
                    validator: (v) => v == null ? 'Wajib pilih produk' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _jumlahCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Jumlah Pesanan', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
                      child: Text(_loading ? 'Menyimpan...' : 'BUAT PESANAN SEKARANG'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
