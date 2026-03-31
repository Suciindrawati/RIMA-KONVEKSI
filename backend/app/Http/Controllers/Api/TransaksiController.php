<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaksi;
use App\Models\Pelanggan;
use App\Models\Produk;
use Illuminate\Http\Request;

class TransaksiController extends Controller
{
    public function index()
    {
        $transaksi = Transaksi::with(['pelanggan', 'produk'])->latest()->get();
        return response()->json(['data' => $transaksi]);
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
        $totalPendapatan = Transaksi::where('status', 'Pesanan Selesai')->sum('total_harga');
        $totalTransaksi  = Transaksi::count();
        $totalPelanggan  = Pelanggan::count();
        $totalProduk     = Produk::count();
        $recentTransaksi = Transaksi::with(['pelanggan', 'produk'])->latest()->limit(10)->get();

        return response()->json([
            'total_pendapatan'  => $totalPendapatan,
            'total_transaksi'   => $totalTransaksi,
            'total_pelanggan'   => $totalPelanggan,
            'total_produk'      => $totalProduk,
            'recent_transaksi'  => $recentTransaksi,
        ]);
    }
}
