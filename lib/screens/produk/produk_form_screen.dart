import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/produk_model.dart';
import '../../services/produk_service.dart';

class ProdukFormScreen extends StatefulWidget {
  const ProdukFormScreen({super.key});

  @override
  State<ProdukFormScreen> createState() => _ProdukFormScreenState();
}

class _ProdukFormScreenState extends State<ProdukFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProdukService();
  bool _loading = false;
  ProdukModel? _existing;

  final _namaCtrl = TextEditingController();
  final _jenisCtrl = TextEditingController();
  final _stokCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ProdukModel && _existing == null) {
      _existing = args;
      _namaCtrl.text = args.namaProduk;
      _jenisCtrl.text = args.jenisProduk;
      _stokCtrl.text = args.stok.toString();
      _deskripsiCtrl.text = args.deskripsi ?? '';
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = image.name;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final p = ProdukModel(
        namaProduk: _namaCtrl.text,
        jenisProduk: _jenisCtrl.text,
        stok: int.parse(_stokCtrl.text),
        deskripsi: _deskripsiCtrl.text,
      );
      if (_existing != null) {
        await _service.update(_existing!.id!, p, imageBytes: _imageBytes, fileName: _imageName);
      } else {
        await _service.create(p, imageBytes: _imageBytes, fileName: _imageName);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil disimpan')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? 'Tambah Produk' : 'Edit Produk'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Tambah Foto', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _namaCtrl,
              decoration: const InputDecoration(labelText: 'Nama Produk', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jenisCtrl,
              decoration: const InputDecoration(labelText: 'Jenis Produk (Baju/Celana/dst)', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stokCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stok', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Wajib' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deskripsiCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Deskripsi Produk', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('SIMPAN PRODUK', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
