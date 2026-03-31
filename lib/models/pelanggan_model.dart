class PelangganModel {
  final int? id;
  final String nama;
  final String noHp;
  final String? keterangan;

  // UKURAN BADAN (BLUS, KEMEJA, BLEZER)
  final String? bajuPu, bajuPi, bajuPa, bajuLt, bajuGn;
  final String? bajuLe, bajuDa, bajuPiLingkar, bajuPaLingkar;
  final String? bajuBh, bajuPuLebar, bajuDaLebar;
  final String? bajuAts, bajuSk, bajuBwh;
  final String? bajuA, bajuB;

  // UKURAN CELANA
  final String? celanaPi, celanaPa, celanaPh, celanaLt, celanaPsk;
  final String? celanaLtPanjang, celanaCln;

  // UKURAN ROK
  final String? rokPi, rokPa;
  final String? rokPaPanjang, rokLt, rokRok;

  PelangganModel({
    this.id,
    required this.nama,
    required this.noHp,
    this.keterangan,
    this.bajuPu, this.bajuPi, this.bajuPa, this.bajuLt, this.bajuGn,
    this.bajuLe, this.bajuDa, this.bajuPiLingkar, this.bajuPaLingkar,
    this.bajuBh, this.bajuPuLebar, this.bajuDaLebar,
    this.bajuAts, this.bajuSk, this.bajuBwh,
    this.bajuA, this.bajuB,
    this.celanaPi, this.celanaPa, this.celanaPh, this.celanaLt, this.celanaPsk,
    this.celanaLtPanjang, this.celanaCln,
    this.rokPi, this.rokPa,
    this.rokPaPanjang, this.rokLt, this.rokRok,
  });

  factory PelangganModel.fromJson(Map<String, dynamic> json) {
    return PelangganModel(
      id: json['id'],
      nama: json['nama']?.toString() ?? '',
      noHp: json['no_hp']?.toString() ?? '',
      keterangan: json['keterangan']?.toString(),
      bajuPu: json['baju_pu']?.toString(),
      bajuPi: json['baju_pi']?.toString(),
      bajuPa: json['baju_pa']?.toString(),
      bajuLt: json['baju_lt']?.toString(),
      bajuGn: json['baju_gn']?.toString(),
      bajuLe: json['baju_le']?.toString(),
      bajuDa: json['baju_da']?.toString(),
      bajuPiLingkar: json['baju_pi_lingkar']?.toString(),
      bajuPaLingkar: json['baju_pa_lingkar']?.toString(),
      bajuBh: json['baju_bh']?.toString(),
      bajuPuLebar: json['baju_pu_lebar']?.toString(),
      bajuDaLebar: json['baju_da_lebar']?.toString(),
      bajuAts: json['baju_ats']?.toString(),
      bajuSk: json['baju_sk']?.toString(),
      bajuBwh: json['baju_bwh']?.toString(),
      bajuA: json['baju_a']?.toString(),
      bajuB: json['baju_b']?.toString(),
      celanaPi: json['celana_pi']?.toString(),
      celanaPa: json['celana_pa']?.toString(),
      celanaPh: json['celana_ph']?.toString(),
      celanaLt: json['celana_lt']?.toString(),
      celanaPsk: json['celana_psk']?.toString(),
      celanaLtPanjang: json['celana_lt_panjang']?.toString(),
      celanaCln: json['celana_cln']?.toString(),
      rokPi: json['rok_pi']?.toString(),
      rokPa: json['rok_pa']?.toString(),
      rokPaPanjang: json['rok_pa_panjang']?.toString(),
      rokLt: json['rok_lt']?.toString(),
      rokRok: json['rok_rok']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'no_hp': noHp,
      'keterangan': keterangan,
      'baju_pu': bajuPu,
      'baju_pi': bajuPi,
      'baju_pa': bajuPa,
      'baju_lt': bajuLt,
      'baju_gn': bajuGn,
      'baju_le': bajuLe,
      'baju_da': bajuDa,
      'baju_pi_lingkar': bajuPiLingkar,
      'baju_pa_lingkar': bajuPaLingkar,
      'baju_bh': bajuBh,
      'baju_pu_lebar': bajuPuLebar,
      'baju_da_lebar': bajuDaLebar,
      'baju_ats': bajuAts,
      'baju_sk': bajuSk,
      'baju_bwh': bajuBwh,
      'baju_a': bajuA,
      'baju_b': bajuB,
      'celana_pi': celanaPi,
      'celana_pa': celanaPa,
      'celana_ph': celanaPh,
      'celana_lt': celanaLt,
      'celana_psk': celanaPsk,
      'celana_lt_panjang': celanaLtPanjang,
      'celana_cln': celanaCln,
      'rok_pi': rokPi,
      'rok_pa': rokPa,
      'rok_pa_panjang': rokPaPanjang,
      'rok_lt': rokLt,
      'rok_rok': rokRok,
    };
  }
}
