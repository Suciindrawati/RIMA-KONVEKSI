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
      nama: json['nama'] ?? '',
      noHp: json['no_hp'] ?? '',
      keterangan: json['keterangan'],
      bajuPu: json['baju_pu'],
      bajuPi: json['baju_pi'],
      bajuPa: json['baju_pa'],
      bajuLt: json['baju_lt'],
      bajuGn: json['baju_gn'],
      bajuLe: json['baju_le'],
      bajuDa: json['baju_da'],
      bajuPiLingkar: json['baju_pi_lingkar'],
      bajuPaLingkar: json['baju_pa_lingkar'],
      bajuBh: json['baju_bh'],
      bajuPuLebar: json['baju_pu_lebar'],
      bajuDaLebar: json['baju_da_lebar'],
      bajuAts: json['baju_ats'],
      bajuSk: json['baju_sk'],
      bajuBwh: json['baju_bwh'],
      bajuA: json['baju_a'],
      bajuB: json['baju_b'],
      celanaPi: json['celana_pi'],
      celanaPa: json['celana_pa'],
      celanaPh: json['celana_ph'],
      celanaLt: json['celana_lt'],
      celanaPsk: json['celana_psk'],
      celanaLtPanjang: json['celana_lt_panjang'],
      celanaCln: json['celana_cln'],
      rokPi: json['rok_pi'],
      rokPa: json['rok_pa'],
      rokPaPanjang: json['rok_pa_panjang'],
      rokLt: json['rok_lt'],
      rokRok: json['rok_rok'],
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
