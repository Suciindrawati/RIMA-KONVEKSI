<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaksi;
use App\Models\Pelanggan;
use App\Models\Produk;
use App\Models\Katalog;
use Illuminate\Http\Request;

class TransaksiController extends Controller
{
    public function index(Request $request)
    {
        $query = Transaksi::with(['pelanggan', 'produk']);

        if ($request->has('status')) {
            $status = $request->status;
            if (is_array($status)) {
                $query->whereIn('status', $status);
            } else {
                $query->where('status', $status);
            }
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->whereHas('pelanggan', function($pq) use ($search) {
                    $pq->where('nama', 'like', "%$search%");
                })->orWhereHas('produk', function($prq) use ($search) {
                    $prq->where('nama_produk', 'like', "%$search%");
                });
            });
        }

        $transaksi = $query->latest()->paginate(15);
        return response()->json($transaksi);
    }

    public function store(Request $request)
    {
        $request->validate([
            'pelanggan_id' => 'required|exists:pelanggan,id',
            'produk_id'    => 'required|exists:produk,id',
            'jumlah'       => 'required|integer|min:1',
        ]);

        $transaksi = Transaksi::create([
            'pelanggan_id' => $request->pelanggan_id,
            'produk_id'    => $request->produk_id,
            'jumlah'       => $request->jumlah,
            'status'       => 'Pesanan Dibuat',
            'tanggal'      => $request->tanggal ?? now()->toDateTimeString(),
        ]);

        $transaksi->load(['pelanggan', 'produk']);

        return response()->json(['message' => 'Pesanan Berhasil Dibuat', 'data' => $transaksi], 201);
    }

    public function update(Request $request, $id)
    {
        $transaksi = Transaksi::findOrFail($id);

        $request->validate([
            'status'      => 'sometimes|required|string',
            'total_harga' => 'nullable|numeric|min:0',
        ]);

        $oldStatus = $transaksi->status;
        $transaksi->update($request->only(['status', 'total_harga']));

        $message = "Transaksi diperbarui";
        if ($oldStatus != $transaksi->status) {
            $message = "Status Berubah: " . $transaksi->status;
        }

        return response()->json([
            'message' => $message,
            'data'    => $transaksi->load(['pelanggan', 'produk'])
        ]);
    }

    public function destroy($id)
    {
        Transaksi::findOrFail($id)->delete();
        return response()->json(['message' => 'Transaksi berhasil dihapus']);
    }

    public function dashboard()
    {
        // Hitung total pendapatan hanya dari pesanan yang sudah selesai
        $totalPendapatan = Transaksi::whereIn('status', ['Pesanan Selesai', 'Selesai'])->sum('total_harga');
        
        $totalTransaksi  = Transaksi::count();
        $totalPelanggan  = Pelanggan::count();
        $totalProduk     = Produk::count();
        
        // Hitung jumlah transaksi yang sudah selesai
        $transaksiSelesai = Transaksi::whereIn('status', ['Pesanan Selesai', 'Selesai'])->count();

        $totalKatalog  = Katalog::count();
        $recentTransaksi = Transaksi::with(['pelanggan', 'produk'])->latest()->limit(5)->get();

        return response()->json([
            'total_pendapatan'   => $totalPendapatan,
            'total_transaksi'    => $totalTransaksi,
            'transaksi_selesai'  => $transaksiSelesai,
            'total_pelanggan'    => $totalPelanggan,
            'total_produk'       => $totalProduk,
            'total_katalog'      => $totalKatalog,
            'recent_transaksi'   => $recentTransaksi,
        ]);
    }
}
