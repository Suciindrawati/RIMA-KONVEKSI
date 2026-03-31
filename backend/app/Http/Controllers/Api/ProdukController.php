<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Produk;
use Illuminate\Http\Request;

class ProdukController extends Controller
{
    public function index()
    {
        return response()->json(['data' => Produk::latest()->get()]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama_produk'  => 'required|string|max:255',
            'jenis_produk' => 'required|string|max:255',
            'stok'         => 'required|integer|min:0',
            'gambar'       => 'nullable|max:10240',
        ]);

        $data = $request->only(['nama_produk', 'jenis_produk', 'stok', 'deskripsi']);

        if ($request->hasFile('gambar')) {
            $data['gambar'] = $request->file('gambar')->store('produk', 'public');
        }

        $produk = Produk::create($data);

        return response()->json(['message' => 'Produk berhasil ditambahkan', 'data' => $produk], 201);
    }

    public function show($id)
    {
        return response()->json(['data' => Produk::findOrFail($id)]);
    }

    public function update(Request $request, $id)
    {
        $produk = Produk::findOrFail($id);

        $request->validate([
            'nama_produk'  => 'sometimes|required|string|max:255',
            'jenis_produk' => 'sometimes|required|string|max:255',
            'stok'         => 'sometimes|required|integer|min:0',
            'gambar'       => 'nullable|max:10240',
        ]);

        $data = $request->only(['nama_produk', 'jenis_produk', 'stok', 'deskripsi']);

        if ($request->hasFile('gambar')) {
            // Hapus gambar lama jika ada
            if ($produk->gambar) {
                \Illuminate\Support\Facades\Storage::disk('public')->delete($produk->gambar);
            }
            $data['gambar'] = $request->file('gambar')->store('produk', 'public');
        }

        $produk->update($data);

        return response()->json(['message' => 'Produk berhasil diupdate', 'data' => $produk]);
    }

    public function destroy($id)
    {
        Produk::findOrFail($id)->delete();
        return response()->json(['message' => 'Produk berhasil dihapus']);
    }
}
