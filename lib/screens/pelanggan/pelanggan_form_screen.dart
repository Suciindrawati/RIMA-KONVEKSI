import 'package:flutter/material.dart';
import '../../models/pelanggan_model.dart';
import '../../services/pelanggan_service.dart';

class PelangganFormScreen extends StatefulWidget {
  const PelangganFormScreen({super.key});

  @override
  State<PelangganFormScreen> createState() => _PelangganFormScreenState();
}

class _PelangganFormScreenState extends State<PelangganFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = PelangganService();
  bool _loading = false;
  PelangganModel? _existing;

  // Controllers - Data Umum
  final _namaCtrl = TextEditingController();
  final _hpCtrl = TextEditingController();
  final _ketCtrl = TextEditingController();

  // Controllers - Baju
  final _bajuPu = TextEditingController(); final _bajuPi = TextEditingController(); final _bajuPa = TextEditingController();
  final _bajuLt = TextEditingController(); final _bajuGn = TextEditingController();
  final _bajuLe = TextEditingController(); final _bajuDa = TextEditingController();
  final _bajuPiLingkar = TextEditingController(); final _bajuPaLingkar = TextEditingController();
  final _bajuBh = TextEditingController(); final _bajuPuLebar = TextEditingController(); final _bajuDaLebar = TextEditingController();
  final _bajuAts = TextEditingController(); final _bajuSk = TextEditingController(); final _bajuBwh = TextEditingController();
  final _bajuA = TextEditingController(); final _bajuB = TextEditingController();

  // Controllers - Celana
  final _celanaPi = TextEditingController(); final _celanaPa = TextEditingController(); final _celanaPh = TextEditingController();
  final _celanaLt = TextEditingController(); final _celanaPsk = TextEditingController();
  final _celanaLtPanjang = TextEditingController(); final _celanaCln = TextEditingController();

  // Controllers - Rok
  final _rokPi = TextEditingController(); final _rokPa = TextEditingController();
  final _rokPaPanjang = TextEditingController(); final _rokLt = TextEditingController(); final _rokRok = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is PelangganModel && _existing == null) {
      _existing = args;
      _namaCtrl.text = args.nama;
      _hpCtrl.text = args.noHp;
      _ketCtrl.text = args.keterangan ?? '';
      
      // Baju
      _bajuPu.text = args.bajuPu ?? ''; _bajuPi.text = args.bajuPi ?? ''; _bajuPa.text = args.bajuPa ?? '';
      _bajuLt.text = args.bajuLt ?? ''; _bajuGn.text = args.bajuGn ?? '';
      _bajuLe.text = args.bajuLe ?? ''; _bajuDa.text = args.bajuDa ?? '';
      _bajuPiLingkar.text = args.bajuPiLingkar ?? ''; _bajuPaLingkar.text = args.bajuPaLingkar ?? '';
      _bajuBh.text = args.bajuBh ?? ''; _bajuPuLebar.text = args.bajuPuLebar ?? ''; _bajuDaLebar.text = args.bajuDaLebar ?? '';
      _bajuAts.text = args.bajuAts ?? ''; _bajuSk.text = args.bajuSk ?? ''; _bajuBwh.text = args.bajuBwh ?? '';
      _bajuA.text = args.bajuA ?? ''; _bajuB.text = args.bajuB ?? '';

      // Celana
      _celanaPi.text = args.celanaPi ?? ''; _celanaPa.text = args.celanaPa ?? ''; _celanaPh.text = args.celanaPh ?? '';
      _celanaLt.text = args.celanaLt ?? ''; _celanaPsk.text = args.celanaPsk ?? '';
      _celanaLtPanjang.text = args.celanaLtPanjang ?? ''; _celanaCln.text = args.celanaCln ?? '';

      // Rok
      _rokPi.text = args.rokPi ?? ''; _rokPa.text = args.rokPa ?? '';
      _rokPaPanjang.text = args.rokPaPanjang ?? ''; _rokLt.text = args.rokLt ?? ''; _rokRok.text = args.rokRok ?? '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final p = PelangganModel(
        id: _existing?.id,
        nama: _namaCtrl.text.trim(),
        noHp: _hpCtrl.text.trim(),
        keterangan: _ketCtrl.text.trim(),
        bajuPu: _bajuPu.text, bajuPi: _bajuPi.text, bajuPa: _bajuPa.text, bajuLt: _bajuLt.text, bajuGn: _bajuGn.text,
        bajuLe: _bajuLe.text, bajuDa: _bajuDa.text, bajuPiLingkar: _bajuPiLingkar.text, bajuPaLingkar: _bajuPaLingkar.text,
        bajuBh: _bajuBh.text, bajuPuLebar: _bajuPuLebar.text, bajuDaLebar: _bajuDaLebar.text,
        bajuAts: _bajuAts.text, bajuSk: _bajuSk.text, bajuBwh: _bajuBwh.text,
        bajuA: _bajuA.text, bajuB: _bajuB.text,
        celanaPi: _celanaPi.text, celanaPa: _celanaPa.text, celanaPh: _celanaPh.text, celanaLt: _celanaLt.text, celanaPsk: _celanaPsk.text,
        celanaLtPanjang: _celanaLtPanjang.text, celanaCln: _celanaCln.text,
        rokPi: _rokPi.text, rokPa: _rokPa.text,
        rokPaPanjang: _rokPaPanjang.text, rokLt: _rokLt.text, rokRok: _rokRok.text,
      );
      if (_existing != null) {
        await _service.update(_existing!.id!, p);
      } else {
        await _service.create(p);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1565C0))),
          const Divider(thickness: 1.5),
        ],
      ),
    );
  }

  Widget _inputGrid(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: children,
    );
  }

  Widget _field(TextEditingController ctrl, String label, {bool required = false, VoidCallback? onTap}) {
    return TextFormField(
      controller: ctrl,
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        suffixIcon: onTap != null ? const Icon(Icons.calendar_today, size: 16) : null,
      ),
      validator: required ? (v) => v == null || v.isEmpty ? 'Wajib' : null : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? 'Tambah Pelanggan' : 'Edit Pelanggan'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionHeader('Data Umum'),
            _field(_namaCtrl, 'Nama Lengkap', required: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _field(_hpCtrl, 'Nomor HP', required: true)),
              ],
            ),
            const SizedBox(height: 12),
            _field(_ketCtrl, 'Keterangan'),

            _sectionHeader('Ukuran Baju / Kemeja / Blezer'),
            const Text('Panjang', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            _inputGrid([
              _field(_bajuPu, 'PU'), _field(_bajuPi, 'PI'), _field(_bajuPa, 'PA'),
              _field(_bajuLt, 'LT'), _field(_bajuGn, 'GN'),
            ]),
            const SizedBox(height: 12),
            const Text('Lingkar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            _inputGrid([
              _field(_bajuLe, 'LE'), _field(_bajuDa, 'DA'), _field(_bajuPiLingkar, 'PI'), _field(_bajuPaLingkar, 'PA'),
            ]),
            const SizedBox(height: 12),
            const Text('Lebar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            _inputGrid([
              _field(_bajuBh, 'BH'), _field(_bajuPuLebar, 'PU'), _field(_bajuDaLebar, 'DA'),
            ]),
            const SizedBox(height: 12),
            const Text('Lingkar Kerung Lengan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            _inputGrid([
              _field(_bajuAts, 'ATS'), _field(_bajuSk, 'SK'), _field(_bajuBwh, 'BWH'),
            ]),
            const SizedBox(height: 12),
            const Text('Panjang Lengan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            _inputGrid([
              _field(_bajuA, 'A'), _field(_bajuB, 'B'),
            ]),

            _sectionHeader('Ukuran Celana'),
            const Text('Lingkar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            _inputGrid([
              _field(_celanaPi, 'PI'), _field(_celanaPa, 'PA'), _field(_celanaPh, 'PH'),
              _field(_celanaLt, 'LT'), _field(_celanaPsk, 'PSK'),
            ]),
            const SizedBox(height: 12),
            const Text('Panjang', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            _inputGrid([
              _field(_celanaLtPanjang, 'LT'), _field(_celanaCln, 'CLN'),
            ]),

            _sectionHeader('Ukuran Rok'),
            const Text('Lingkar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            _inputGrid([
              _field(_rokPi, 'PI'), _field(_rokPa, 'PA'),
            ]),
            const SizedBox(height: 12),
            const Text('Panjang', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            _inputGrid([
              _field(_rokPaPanjang, 'PA'), _field(_rokLt, 'LT'), _field(_rokRok, 'ROK'),
            ]),

            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('SIMPAN SEMUA DATA', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
