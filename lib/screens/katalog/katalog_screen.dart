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

class _StatefulAddDialog extends StatefulWidget {
  final Function() onSuccess;
  const _StatefulAddDialog({required this.onSuccess});

  @override
  State<_StatefulAddDialog> createState() => _StatefulAddDialogState();
}

class _StatefulAddDialogState extends State<_StatefulAddDialog> {
  final _service = KatalogService();
  final judulCtrl = TextEditingController();
  final deskCtrl = TextEditingController();
  Uint8List? imageBytes;
  String? imageName;
  bool uploading = false;

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
      title: const Text('Tambah Katalog Baru'),
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
                maxLines: 2,
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
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pick,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: uploading ? null : () async {
            if (judulCtrl.text.isEmpty) return;
            setState(() => uploading = true);
            try {
              await _service.create(
                KatalogModel(judul: judulCtrl.text.trim(), deskripsi: deskCtrl.text.trim()),
                imageBytes: imageBytes,
                imageName: imageName,
              );
              widget.onSuccess();
              if (mounted) Navigator.pop(context);
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
            } finally {
              if (mounted) setState(() => uploading = false);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
          child: uploading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Simpan'),
        ),
      ],
    );
  }
}

class _KatalogScreenState extends State<KatalogScreen> {
  final _service = KatalogService();
  List<KatalogModel> _list = [];
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
      await _service.delete(k.id!);
      _load();
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
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: _role == 'admin'
          ? FloatingActionButton.extended(
              onPressed: () => showDialog(context: context, builder: (_) => _StatefulAddDialog(onSuccess: _load)),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Tambah'),
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
               ? const Center(child: Text('Belum ada katalog'))
               : RefreshIndicator(
                   onRefresh: _load,
                   child: GridView.builder(
                     padding: const EdgeInsets.all(12),
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
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                         child: Stack(
                           children: [
                             Column(
                               children: [
                                 Expanded(
                                   child: imgUrl != null
                                       ? Image.network(
                                           imgUrl,
                                           fit: BoxFit.cover,
                                           width: double.infinity,
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
                       );
                     },
                   ),
                 ),
    );
  }
}
