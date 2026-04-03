import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/auth_service.dart';
import '../../services/katalog_service.dart';
import '../../models/katalog_model.dart';
import '../../constants/api_constants.dart';

class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  final _service = KatalogService();
  final _scrollController = ScrollController();
  
  List<KatalogModel> _list = [];
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

  Future<void> _loadInitial() async {
    setState(() { _loading = true; _page = 1; _isLastPage = false; _list = []; });
    try {
      final role = await AuthService().getRole();
      final res = await _service.getPaginated(1, search: _searchCtrl.text);
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

  void _onSearch(String v) {
    if (_debounceTime?.isAfter(DateTime.now()) ?? false) return;
    _debounceTime = DateTime.now().add(const Duration(milliseconds: 600));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _loadInitial();
    });
  }

  void _showForm([KatalogModel? k]) {
    showDialog(context: context, builder: (_) => KatalogFormDialog(existing: k)).then((v) {
      if (v == true) _loadInitial();
    });
  }

  Future<void> _delete(KatalogModel k) async {
    final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), title: const Text('Hapus Model'), content: Text('Hapus katalog ${k.judul}?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Hapus'))]));
    if (confirm == true) {
      try { await _service.delete(k.id!); _loadInitial(); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'))); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: Text('Katalog Model', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)), actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadInitial)]),
      floatingActionButton: _role == 'admin' ? FloatingActionButton.extended(onPressed: _showForm, icon: const Icon(Icons.add_photo_alternate_rounded), label: const Text('Mode Baru')) : null,
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(20), child: TextField(controller: _searchCtrl, onChanged: _onSearch, decoration: const InputDecoration(hintText: 'Cari Model / Kode...', prefixIcon: Icon(Icons.search_rounded)))),
          Expanded(
            child: _loading
                ? _buildInitialShimmer()
                : RefreshIndicator(
                    onRefresh: _loadInitial,
                    child: _list.isEmpty
                        ? _emptyState()
                        : ListView(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75),
                                itemCount: _list.length,
                                itemBuilder: (ctx, i) => _buildGridItem(_list[i]),
                              ),
                              if (_loadingMore) _buildMoreShimmer(),
                              if (_isLastPage && _list.isNotEmpty) _buildFooter(),
                              const SizedBox(height: 100),
                            ],
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(KatalogModel k) {
    final imgUrl = k.gambar != null ? '${ApiConstants.baseUrl}/storage/${k.gambar}' : null;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: InkWell(
        onTap: () => _showDetail(k),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
                child: imgUrl != null ? ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), child: Image.network(imgUrl, fit: BoxFit.cover)) : const Icon(Icons.image_not_supported, color: Color(0xFFCBD5E1)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(k.judul, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${k.gallery?.length ?? 0} Foto Galeri', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
            ),
            if (_role == 'admin') ...[
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(onPressed: () => _showForm(k), icon: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF64748B))),
                  IconButton(onPressed: () => _delete(k), icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetail(KatalogModel k) {
    final imgUrl = k.gambar != null ? '${ApiConstants.baseUrl}/storage/${k.gambar}' : null;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          String activeUrl = imgUrl ?? '';
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
            child: Column(
              children: [
                Container(margin: const EdgeInsets.all(16), width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Photo Viewer
                        Container(
                          height: 350, 
                          width: double.infinity, 
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24)), 
                          child: activeUrl.isNotEmpty 
                            ? ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(activeUrl, fit: BoxFit.cover)) 
                            : const Icon(Icons.image_not_supported, size: 60)
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Gallery Selector
                        if (k.gallery != null && k.gallery!.isNotEmpty)
                          SizedBox(
                            height: 80,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                // Thumbnail Utama
                                _buildThumbnail(imgUrl!, activeUrl == imgUrl, () => setModalState(() => activeUrl = imgUrl)),
                                // Thumbnails Gallery
                                ...k.gallery!.map((g) {
                                  final gUrl = '${ApiConstants.baseUrl}/storage/$g';
                                  return _buildThumbnail(gUrl, activeUrl == gUrl, () => setModalState(() => activeUrl = gUrl));
                                }).toList(),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),
                        Text(k.judul, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900)),
                        const Text('Katalog Eksklusif Rima Konveksi', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 12)),
                        const Divider(height: 48),
                        const Text('Deskripsi Model', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(k.deskripsi ?? 'Tidak ada deskripsi tambahan untuk model ini.', style: const TextStyle(color: Color(0xFF64748B))),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildThumbnail(String url, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? const Color(0xFFF97316) : Colors.transparent, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(url, fit: BoxFit.cover, opacity: isActive ? null : const AlwaysStoppedAnimation(0.6)),
        ),
      ),
    );
  }

  Widget _buildInitialShimmer() {
    return GridView.builder(padding: const EdgeInsets.all(20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75), itemCount: 6, itemBuilder: (_, __) => Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)))));
  }

  Widget _buildMoreShimmer() {
    return Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(height: 100, margin: const EdgeInsets.only(top: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))));
  }

  Widget _buildFooter() {
    return const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: Text('Semua katalog telah dimuat', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))));
  }

  Widget _emptyState() {
    return ListView(children: [SizedBox(height: MediaQuery.of(context).size.height * 0.2), const Icon(Icons.photo_library_rounded, size: 64, color: Color(0xFFCBD5E1)), const SizedBox(height: 16), const Center(child: Text('Katalog model belum diisi.', style: TextStyle(color: Color(0xFF64748B))))]);
  }
}

class KatalogFormDialog extends StatefulWidget {
  final KatalogModel? existing;
  const KatalogFormDialog({super.key, this.existing});
  @override
  State<KatalogFormDialog> createState() => _KatalogFormDialogState();
}

class _KatalogFormDialogState extends State<KatalogFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _service = KatalogService();
  bool _loading = false;
  final _namaCtrl = TextEditingController();
  final _deskCtrl = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageName;

  // Gallery
  final List<Uint8List> _galleryBytes = [];
  final List<String> _galleryNames = [];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) { _namaCtrl.text = widget.existing!.judul; _deskCtrl.text = widget.existing!.deskripsi ?? ''; }
  }

  Future<void> _pickMain() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) { final bytes = await img.readAsBytes(); setState(() { _imageBytes = bytes; _imageName = img.name; }); }
  }

  Future<void> _pickGallery() async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      for (var img in images) {
        final bytes = await img.readAsBytes();
        setState(() {
          _galleryBytes.add(bytes);
          _galleryNames.add(img.name);
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final k = KatalogModel(judul: _namaCtrl.text, deskripsi: _deskCtrl.text);
      if (widget.existing != null) 
        await _service.update(widget.existing!.id!, k, imageBytes: _imageBytes, imageName: _imageName, galleryBytes: _galleryBytes, galleryNames: _galleryNames);
      else 
        await _service.create(k, imageBytes: _imageBytes, imageName: _imageName, galleryBytes: _galleryBytes, galleryNames: _galleryNames);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(widget.existing == null ? 'Model Baru' : 'Ubah Model', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Foto Sampul Utama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickMain,
                child: Container(width: double.infinity, height: 160, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))), child: _imageBytes != null ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.memory(_imageBytes!, fit: BoxFit.cover)) : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, color: Color(0xFFF97316)), SizedBox(height: 8), Text('Tambah Foto Utama', style: TextStyle(fontSize: 10))])),
              ),
              const SizedBox(height: 24),
              const Text('Foto Galeri Tambahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickGallery,
                      child: Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFFEDD5))), child: const Icon(Icons.add_to_photos_rounded, color: Color(0xFFF97316), size: 20)),
                    ),
                    ...List.generate(_galleryBytes.length, (i) => Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 80, height: 80, 
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(_galleryBytes[i], fit: BoxFit.cover)),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(controller: _namaCtrl, decoration: const InputDecoration(labelText: 'Nama Model'), validator: (v) => v!.isEmpty ? 'Wajib' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _deskCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Deskripsi')),
            ],
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')), ElevatedButton(onPressed: _loading ? null : _save, child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('SIMPAN'))],
    );
  }
}
