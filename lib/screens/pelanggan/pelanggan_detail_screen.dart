import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pelanggan_model.dart';

class PelangganDetailScreen extends StatelessWidget {
  const PelangganDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = ModalRoute.of(context)!.settings.arguments as PelangganModel;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(p.nama, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _headerCard(p),
          const SizedBox(height: 24),
          _measurementSection(
            'Ukuran Baju / Kemeja / Blazer',
            Icons.checkroom_rounded,
            [
              _gridRow([_item('PU', p.bajuPu), _item('PI', p.bajuPi), _item('PA', p.bajuPa)]),
              _gridRow([_item('LT', p.bajuLt), _item('GN', p.bajuGn)]),
              _divider(),
              _gridRow([_item('LE', p.bajuLe), _item('DA', p.bajuDa)]),
              _gridRow([_item('PI (Lingkar)', p.bajuPiLingkar), _item('PA (Lingkar)', p.bajuPaLingkar)]),
              _divider(),
              _gridRow([_item('BH', p.bajuBh), _item('PU (Lebar)', p.bajuPuLebar), _item('DA (Lebar)', p.bajuDaLebar)]),
              _divider(),
              _gridRow([_item('ATS', p.bajuAts), _item('SK', p.bajuSk), _item('BWH', p.bajuBwh)]),
              _gridRow([_item('Lengan A', p.bajuA), _item('Lengan B', p.bajuB)]),
            ],
          ),
          const SizedBox(height: 24),
          _measurementSection(
            'Ukuran Celana',
            Icons.straighten_rounded,
            [
              _gridRow([_item('PI (Lingkar)', p.celanaPi), _item('PA (Lingkar)', p.celanaPa)]),
              _gridRow([_item('PH', p.celanaPh), _item('LT', p.celanaLt), _item('PSK', p.celanaPsk)]),
              _gridRow([_item('Panjang LT', p.celanaLtPanjang), _item('Panjang CLN', p.celanaCln)]),
            ],
          ),
          const SizedBox(height: 24),
          _measurementSection(
            'Ukuran Rok',
            Icons.accessibility_new_rounded,
            [
              _gridRow([_item('PI (Lingkar)', p.rokPi), _item('PA (Lingkar)', p.rokPa)]),
              _gridRow([_item('Panjang PA', p.rokPaPanjang), _item('Panjang LT', p.rokLt)]),
              _gridRow([_item('Panjang ROK', p.rokRok)]),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _headerCard(PelangganModel p) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.nama, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                    Text('ID Pelanggan: #${p.id}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white12)),
          Row(
            children: [
              const Icon(Icons.message_rounded, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Text(p.noHp, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          if (p.keterangan != null && p.keterangan!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'CATATAN: ${p.keterangan}',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ]
        ],
      ),
    );
  }

  Widget _measurementSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFF97316), size: 20),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _gridRow(List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: items.map((w) => Expanded(child: w)).toList()),
    );
  }

  Widget _item(String label, String? val) {
    final displayVal = (val == null || val == 'null' || val.isEmpty) ? '-' : val;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
        const SizedBox(height: 4),
        Text(displayVal, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: const Color(0xFF1E293B))),
      ],
    );
  }

  Widget _divider() => const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Color(0xFFF1F5F9)));
}
