<?php

namespace App\Http\Controllers;

use App\Models\Katalog;
use App\Models\Pelanggan;
use App\Models\Transaksi;
use Illuminate\Http\Request;

class CekPesananController extends Controller
{
    public function index(Request $request)
    {
        $search = $request->query('search');
        $pelanggan = null;

        if ($search) {
            $pelanggan = Pelanggan::where('nama', 'like', "%$search%")
                ->orWhere('no_hp', 'like', "%$search%")
                ->latest()
                ->get();
        }

        $katalog = Katalog::latest()->take(6)->get();

        return view('cek-pesanan', compact('pelanggan', 'search', 'katalog'));
    }

    public function verify(Request $request)
    {
        $p = Pelanggan::findOrFail($request->id);

        if ($request->no_hp != $p->no_hp) {
            return response()->json(['success' => false, 'message' => 'Nomor WhatsApp tidak cocok!']);
        }

        // Simpan tanda verifikasi di session
        session(["verified_customer_{$p->id}" => true]);

        return response()->json([
            'success' => true,
            'redirect' => route('cek-pesanan.hasil', $p->id)
        ]);
    }

    public function showHasil($id)
    {
        // Pastikan sudah verifikasi via session
        if (!session("verified_customer_{$id}")) {
            return redirect()->route('cek-pesanan')->with('error', 'Silakan verifikasi nomor HP Anda terlebih dahulu.');
        }

        $p = Pelanggan::with(['transaksi.produk'])->findOrFail($id);

        // Format history
        $history = $p->transaksi->map(function($t) {
            $progress = 0;
            $step = 0;
            $msg = "";
            if ($t->status == 'Pesanan Dibuat') { 
                $progress = 30; $step = 1; 
                $msg = "Pesanan sedang dalam antrean potong kain.";
            } elseif ($t->status == 'Sedang Dalam Pengerjaan') { 
                $progress = 70; $step = 2; 
                $msg = "Tim penjahit sedang mengerjakan pesanan Anda.";
            } elseif (in_array($t->status, ['Pesanan Selesai', 'Selesai'])) { 
                $progress = 100; $step = 3; 
                $msg = "Pesanan siap dijemput di outlet Rima Konveksi.";
            }

            return (object) [
                'id' => $t->id,
                'produk' => $t->produk->nama_produk,
                'jumlah' => $t->jumlah,
                'status' => $t->status,
                'progress' => $progress,
                'step' => $step,
                'msg' => $msg,
                'tanggal' => $t->created_at->format('d M Y'),
                'total_harga' => in_array($t->status, ['Pesanan Selesai', 'Selesai']) 
                    ? 'Rp ' . number_format($t->total_harga, 0, ',', '.') 
                    : 'Menunggu Selesai'
            ];
        });

        // Ukuran
        $ukuran = [];
        $fields = [
            'Baju' => [
                'baju_pu' => 'Pundak',
                'baju_pi' => 'Pinggang',
                'baju_pa' => 'Panggul',
                'baju_lt' => 'Lengan',
                'baju_gn' => 'Geni/Sikut',
                'baju_le' => 'Leher',
                'baju_da' => 'Dada'
            ],
            'Celana' => [
                'celana_pi' => 'Pinggang',
                'celana_pa' => 'Panggul',
                'celana_ph' => 'Paha',
                'celana_lt' => 'Lutut'
            ]
        ];
        
        foreach($fields as $cat => $map) {
            foreach($map as $key => $label) {
                if($p->$key) $ukuran[$cat][$label] = $p->$key;
            }
        }

        return view('detail-pesanan', compact('p', 'history', 'ukuran'));
    }
}
