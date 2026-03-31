import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/katalog_model.dart';
import '../../services/katalog_service.dart';
import '../../services/auth_service.dart';
import '../../constants/api_constants.dart';

class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});
  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogFormDialog extends StatefulWidget {
  final Function() onSuccess;
  final KatalogModel? item;
  const _KatalogFormDialog({required this.onSuccess, this.item});

  @override
  State<_KatalogFormDialog> createState() => _KatalogFormDialogState();
}

class _KatalogFormDialogState extends State<_KatalogFormDialog> {
  final _service = KatalogService();
  final judulCtrl = TextEditingController();
  final deskCtrl = TextEditingController();
  Uint8List? imageBytes;
  String? imageName;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      judulCtrl.text = widget.item!.judul;
      deskCtrl.text = widget.item!.deskripsi ?? '';
    }
  }

  Future<void> _pick() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        imageBytes = bytes;
        imageName = picked.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Tambah Katalog Baru' : 'Edit Katalog'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulCtrl,
                decoration: const InputDecoration(labelText: 'Judul', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deskCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              if (imageBytes != null)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(image: MemoryImage(imageBytes!), fit: BoxFit.cover),
                  ),
                )
              else if (widget.item?.gambar != null)
                 Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage('${ApiConstants.baseUrl.replaceAll('/api', '')}/storage/${widget.item!.gambar}'),
                      fit: BoxFit.cover
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pick,
                icon: const Icon(Icons.image),
                label: Text(widget.item?.gambar != null ? 'Ganti Gambar' : 'Pilih Gambar'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: loading ? null : () async {
            if (judulCtrl.text.isEmpty) return;
            setState(() => loading = true);
            try {
              if (widget.item == null) {
                await _service.create(
                  KatalogModel(judul: judulCtrl.text.trim(), deskripsi: deskCtrl.text.trim()),
                  imageBytes: imageBytes,
                  imageName: imageName,
                );
              } else {
                await _service.update(
                  widget.item!.id!,
                  KatalogModel(judul: judulCtrl.text.trim(), deskripsi: deskCtrl.text.trim()),
                  imageBytes: imageBytes,
                  imageName: imageName,
                );
              }
              widget.onSuccess();
              if (mounted) Navigator.pop(context);
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
            } finally {
              if (mounted) setState(() => loading = false);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
          child: loading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
            : const Text('Simpan'),
        ),
      ],
    );
  }
}

class _KatalogScreenState extends State<KatalogScreen> {
  final _service = KatalogService();
  final _scrollController = ScrollController();
  final _searchCtrl = TextEditingController();
  
  List<KatalogModel> _list = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _isLastPage = false;
  int _page = 1;
  String _role = '';
  String _searchQuery = '';

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
    _searchCtrl.dispose();
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
      final role = await AuthService().getRole();
      final res = await _service.getPaginated(1, search: _searchQuery);
      final List data = res['data'];
      if (mounted) {
        setState(() {
          _role = role ?? '';
          _list = data.map((e) => KatalogModel.fromJson(e)).toList();
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
      final res = await _service.getPaginated(_page, search: _searchQuery);
      final List data = res['data'];
      if (mounted) {
        setState(() {
          _list.addAll(data.map((e) => KatalogModel.fromJson(e)).toList());
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

  void _onSearch(String val) {
    setState(() {
      _searchQuery = val;
    });
    _loadInitial();
  }

  void _showPreview(KatalogModel k, String? imgUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: imgUrl != null 
                      ? Image.network(imgUrl, fit: BoxFit.contain)
                      : const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(k.judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text(k.deskripsi ?? 'Tidak ada deskripsi', style: const TextStyle(color: Colors.black87)),
                        if (_role == 'admin') ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                showDialog(context: context, builder: (_) => _KatalogFormDialog(onSuccess: _loadInitial, item: k));
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('EDIT DATA'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(KatalogModel k) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Katalog'),
        content: Text('Yakin hapus "${k.judul}"?'),
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
        await _service.delete(k.id!);
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
        title: const Text('Katalog Model Pakaian'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadInitial)],
      ),
      floatingActionButton: _role == 'admin'
          ? FloatingActionButton.extended(
              onPressed: () => showDialog(context: context, builder: (_) => _KatalogFormDialog(onSuccess: _loadInitial)),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Tambah'),
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Cari katalog...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); _onSearch(''); }) 
                  : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _list.isEmpty
                     ? const Center(child: Text('Belum ada katalog'))
                     : RefreshIndicator(
                         onRefresh: _loadInitial,
                         child: ListView(
                           controller: _scrollController,
                           children: [
                             GridView.builder(
                               shrinkWrap: true,
                               physics: const NeverScrollableScrollPhysics(),
                               padding: const EdgeInsets.symmetric(horizontal: 12),
                               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                 crossAxisCount: 2,
                                 crossAxisSpacing: 10,
                                 mainAxisSpacing: 10,
                                 childAspectRatio: 0.75,
                               ),
                               itemCount: _list.length,
                               itemBuilder: (ctx, i) {
                                 final k = _list[i];
                                 final imgUrl = k.gambar != null
                                     ? '${ApiConstants.baseUrl.replaceAll('/api', '')}/storage/${k.gambar}'
                                     : null;
                                 return Card(
                                   clipBehavior: Clip.antiAlias,
                                   elevation: 2,
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                   child: InkWell(
                                     onTap: () => _showPreview(k, imgUrl),
                                     child: Stack(
                                       children: [
                                         Column(
                                           crossAxisAlignment: CrossAxisAlignment.stretch,
                                           children: [
                                             Expanded(
                                               child: imgUrl != null
                                                   ? Image.network(
                                                       imgUrl,
                                                       fit: BoxFit.cover,
                                                       errorBuilder: (_, __, ___) => const Center(
                                                           child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey)),
                                                     )
                                                   : Container(
                                                       color: Colors.grey.shade200,
                                                       child: const Center(child: Icon(Icons.checkroom, size: 40, color: Colors.grey)),
                                                     ),
                                             ),
                                             Padding(
                                               padding: const EdgeInsets.all(8),
                                               child: Column(
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                 children: [
                                                   Text(k.judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                   if (k.deskripsi != null && k.deskripsi!.isNotEmpty)
                                                     Text(k.deskripsi!, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                                                 ],
                                               ),
                                             ),
                                           ],
                                         ),
                                         if (_role == 'admin')
                                           Positioned(
                                             top: 4,
                                             right: 4,
                                             child: CircleAvatar(
                                               radius: 16,
                                               backgroundColor: Colors.red.withOpacity(0.85),
                                               child: IconButton(
                                                 icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                                                 onPressed: () => _delete(k),
                                                 padding: EdgeInsets.zero,
                                               ),
                                             ),
                                           ),
                                       ],
                                     ),
                                   ),
                                 );
                               },
                             ),
                             if (_loadingMore)
                               const Padding(
                                 padding: EdgeInsets.symmetric(vertical: 16),
                                 child: Center(child: CircularProgressIndicator()),
                               ),
                             if (_isLastPage && _list.isNotEmpty)
                               const Padding(
                                 padding: EdgeInsets.symmetric(vertical: 16),
                                 child: Center(child: Text('Semua data telah dimuat', style: TextStyle(color: Colors.grey))),
                               ),
                           ],
                         ),
                       ),
          ),
        ],
      ),
    );
  }
}
