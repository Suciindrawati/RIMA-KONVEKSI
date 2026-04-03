import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      
      _bajuPu.text = args.bajuPu ?? ''; _bajuPi.text = args.bajuPi ?? ''; _bajuPa.text = args.bajuPa ?? '';
      _bajuLt.text = args.bajuLt ?? ''; _bajuGn.text = args.bajuGn ?? '';
      _bajuLe.text = args.bajuLe ?? ''; _bajuDa.text = args.bajuDa ?? '';
      _bajuPiLingkar.text = args.bajuPiLingkar ?? ''; _bajuPaLingkar.text = args.bajuPaLingkar ?? '';
      _bajuBh.text = args.bajuBh ?? ''; _bajuPuLebar.text = args.bajuPuLebar ?? ''; _bajuDaLebar.text = args.bajuDaLebar ?? '';
      _bajuAts.text = args.bajuAts ?? ''; _bajuSk.text = args.bajuSk ?? ''; _bajuBwh.text = args.bajuBwh ?? '';
      _bajuA.text = args.bajuA ?? ''; _bajuB.text = args.bajuB ?? '';

      _celanaPi.text = args.celanaPi ?? ''; _celanaPa.text = args.celanaPa ?? ''; _celanaPh.text = args.celanaPh ?? '';
      _celanaLt.text = args.celanaLt ?? ''; _celanaPsk.text = args.celanaPsk ?? '';
      _celanaLtPanjang.text = args.celanaLtPanjang ?? ''; _celanaCln.text = args.celanaCln ?? '';

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil pelanggan berhasil disimpan')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _sectionLabel(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 20),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF97316).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFFF97316), size: 18)),
          const SizedBox(width: 12),
          Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: const Color(0xFF1E293B))),
          const SizedBox(width: 12),
          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        ],
      ),
    );
  }

  Widget _grid(List<Widget> children) {
    return GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.5, children: children);
  }

  Widget _input(TextEditingController ctrl, String label, {bool required = false}) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      keyboardType: TextInputType.text,
      validator: required ? (v) => v!.isEmpty ? 'Wajib' : null : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_existing == null ? 'Registrasi Pelanggan' : 'Ubah Profil Pelanggan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          children: [
            _sectionLabel('INFORMASI DASAR', Icons.person_outline_rounded),
            _input(_namaCtrl, 'Nama Lengkap Pelanggan', required: true),
            const SizedBox(height: 16),
            _input(_hpCtrl, 'Nomor HP / WhatsApp', required: true),
            const SizedBox(height: 16),
            _input(_ketCtrl, 'Keterangan Tambahan / Karakter Pelanggan'),

            _sectionLabel('UKURAN BAJU / KEMEJA / JAS', Icons.checkroom_rounded),
            const Text('Panjang (Cm)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)),
            const SizedBox(height: 12),
            _grid([ _input(_bajuPu, 'PU'), _input(_bajuPi, 'PI'), _input(_bajuPa, 'PA'), _input(_bajuLt, 'LT'), _input(_bajuGn, 'GN') ]),
            const SizedBox(height: 20),
            const Text('Lingkar (Cm)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)),
            const SizedBox(height: 12),
            _grid([ _input(_bajuLe, 'LE'), _input(_bajuDa, 'DA'), _input(_bajuPiLingkar, 'L.PI'), _input(_bajuPaLingkar, 'L.PA') ]),
            const SizedBox(height: 20),
            const Text('Lebar (Cm)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)),
            const SizedBox(height: 12),
            _grid([ _input(_bajuBh, 'BH'), _input(_bajuPuLebar, 'L.PU'), _input(_bajuDaLebar, 'L.DA') ]),
            const SizedBox(height: 20),
            const Text('Lengan & Bahu (Cm)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)),
            const SizedBox(height: 12),
            _grid([ _input(_bajuAts, 'ATS'), _input(_bajuSk, 'SK'), _input(_bajuBwh, 'BWH'), _input(_bajuA, 'A'), _input(_bajuB, 'B') ]),

            _sectionLabel('UKURAN CELANA', Icons.straighten_rounded),
            _grid([ _input(_celanaPi, 'PI'), _input(_celanaPa, 'PA'), _input(_celanaPh, 'PH'), _input(_celanaLt, 'LT'), _input(_celanaPsk, 'PSK'), _input(_celanaLtPanjang, 'P.LT'), _input(_celanaCln, 'CLN') ]),

            _sectionLabel('UKURAN ROK', Icons.accessibility_new_rounded),
            _grid([ _input(_rokPi, 'PI'), _input(_rokPa, 'PA'), _input(_rokPaPanjang, 'P.PA'), _input(_rokLt, 'LT'), _input(_rokRok, 'ROK') ]),

            const SizedBox(height: 56),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('SIMPAN PROFIL & UKURAN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
