import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      setState(() { _imageBytes = bytes; _imageName = image.name; });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final p = ProdukModel(
        namaProduk: _namaCtrl.text,
        jenisProduk: _jenisCtrl.text,
        stok: int.tryParse(_stokCtrl.text) ?? 0,
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_existing == null ? 'Tambah Produk' : 'Ubah Data Produk', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.memory(_imageBytes!, fit: BoxFit.cover))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.add_a_photo_rounded, size: 30, color: Color(0xFFF97316))),
                            const SizedBox(height: 12),
                            const Text('Foto Produk', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _namaCtrl,
              decoration: const InputDecoration(labelText: 'Nama Produk / Jenis Bahan'),
              validator: (v) => v!.isEmpty ? 'Nama harus diisi' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _jenisCtrl,
              decoration: const InputDecoration(labelText: 'Kategori (Baju/Celana/Jas/dst)'),
              validator: (v) => v!.isEmpty ? 'Kategori harus diisi' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _stokCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah Stok (Roll/Pcs)'),
              validator: (v) => v!.isEmpty ? 'Stok wajib diisi' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _deskripsiCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Keterangan Tambahan'),
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('SIMPAN PRODUK', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
