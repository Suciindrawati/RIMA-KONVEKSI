import 'package:flutter/material.dart';
import '../../models/pelanggan_model.dart';

class PelangganDetailScreen extends StatelessWidget {
  const PelangganDetailScreen({super.key});

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty || value == 'null') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> rows) {
    final visible = rows.where((w) => w is! SizedBox).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1565C0))),
            const Divider(),
            ...rows,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = ModalRoute.of(context)!.settings.arguments as PelangganModel;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.nama),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Data Umum', [
            _row('Nama', p.nama),
            _row('No. HP', p.noHp),
            _row('Keterangan', p.keterangan),
          ]),
          _section('Ukuran Baju / Kemeja / Blezer', [
            _row('PU / PI / PA', '${p.bajuPu ?? '-'} / ${p.bajuPi ?? '-'} / ${p.bajuPa ?? '-'}'),
            _row('LT / GN', '${p.bajuLt ?? '-'} / ${p.bajuGn ?? '-'}'),
            const Divider(),
            _row('LE / DA', '${p.bajuLe ?? '-'} / ${p.bajuDa ?? '-'}'),
            _row('PI / PA (Lingkar)', '${p.bajuPiLingkar ?? '-'} / ${p.bajuPaLingkar ?? '-'}'),
            const Divider(),
            _row('BH / PU (Lebar)', '${p.bajuBh ?? '-'} / ${p.bajuPuLebar ?? '-'}'),
            _row('DA (Lebar)', p.bajuDaLebar),
            const Divider(),
            _row('ATS / SK / BWH', '${p.bajuAts ?? '-'} / ${p.bajuSk ?? '-'} / ${p.bajuBwh ?? '-'}'),
            _row('Panjang Lengan A / B', '${p.bajuA ?? '-'} / ${p.bajuB ?? '-'}'),
          ]),
          _section('Ukuran Celana', [
            _row('PI / PA (Lingkar)', '${p.celanaPi ?? '-'} / ${p.celanaPa ?? '-'}'),
            _row('PH / LT / PSK', '${p.celanaPh ?? '-'} / ${p.celanaLt ?? '-'} / ${p.celanaPsk ?? '-'}'),
            _row('Panjang LT / CLN', '${p.celanaLtPanjang ?? '-'} / ${p.celanaCln ?? '-'}'),
          ]),
          _section('Ukuran Rok', [
            _row('PI / PA (Lingkar)', '${p.rokPi ?? '-'} / ${p.rokPa ?? '-'}'),
            _row('Panjang PA / LT', '${p.rokPaPanjang ?? '-'} / ${p.rokLt ?? '-'}'),
            _row('Panjang ROK', p.rokRok),
          ]),
        ],
      ),
    );
  }
}
