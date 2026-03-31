<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Katalog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class KatalogController extends Controller
{
    public function index(Request $request)
    {
        $query = Katalog::query();

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('judul', 'like', "%{$search}%")
                  ->orWhere('deskripsi', 'like', "%{$search}%");
            });
        }

        return response()->json($query->latest()->paginate(10));
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

    public function update(Request $request, $id)
    {
        $katalog = Katalog::findOrFail($id);
        $request->validate([
            'judul'  => 'required|string|max:255',
            'gambar' => 'nullable|max:10240',
        ]);

        if ($request->hasFile('gambar')) {
            if ($katalog->gambar) {
                Storage::disk('public')->delete($katalog->gambar);
            }
            $katalog->gambar = $request->file('gambar')->store('katalog', 'public');
        }

        $katalog->judul = $request->judul;
        $katalog->deskripsi = $request->deskripsi;
        $katalog->save();

        return response()->json(['message' => 'Katalog berhasil diperbarui', 'data' => $katalog]);
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
