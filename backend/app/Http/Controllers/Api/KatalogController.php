<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Katalog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class KatalogController extends Controller
{
    public function index()
    {
        return response()->json(['data' => Katalog::latest()->get()]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'judul'  => 'required|string|max:255',
            'gambar' => 'nullable|max:10240', // dinaikkan ke 10MB agar lebih aman
        ]);

        $gambarPath = null;
        if ($request->hasFile('gambar')) {
            $gambarPath = $request->file('gambar')->store('katalog', 'public');
        }

        $katalog = Katalog::create([
            'judul'     => $request->judul,
            'deskripsi' => $request->deskripsi,
            'gambar'    => $gambarPath,
        ]);

        return response()->json(['message' => 'Katalog berhasil ditambahkan', 'data' => $katalog], 201);
    }

    public function show($id)
    {
        return response()->json(['data' => Katalog::findOrFail($id)]);
    }

    public function destroy($id)
    {
        $katalog = Katalog::findOrFail($id);

        if ($katalog->gambar) {
            Storage::disk('public')->delete($katalog->gambar);
        }

        $katalog->delete();
        return response()->json(['message' => 'Katalog berhasil dihapus']);
    }
}
