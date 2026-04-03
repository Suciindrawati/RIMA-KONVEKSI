<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Katalog;
use App\Models\KatalogGambar;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class KatalogController extends Controller
{
    public function index(Request $request)
    {
        $query = Katalog::with('gambars');

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('judul', 'like', "%{$search}%")
                  ->orWhere('deskripsi', 'like', "%{$search}%");
            });
        }

        return response()->json($query->latest()->paginate(15));
    }

    public function store(Request $request)
    {
        $request->validate([
            'judul'  => 'required|string|max:255',
            'gambar' => 'nullable|image|max:5120', // Main cover image
            'gallery.*' => 'nullable|image|max:10240', // Multiple gallery images
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

        // Handle Gallery
        if ($request->hasFile('gallery')) {
            foreach ($request->file('gallery') as $img) {
                $path = $img->store('katalog_gallery', 'public');
                $katalog->gambars()->create(['gambar' => $path]);
            }
        }

        return response()->json(['message' => 'Katalog berhasil ditambahkan', 'data' => $katalog->load('gambars')], 201);
    }

    public function show($id)
    {
        return response()->json(['data' => Katalog::with('gambars')->findOrFail($id)]);
    }

    public function update(Request $request, $id)
    {
        $katalog = Katalog::findOrFail($id);
        $request->validate([
            'judul'  => 'required|string|max:255',
            'gambar' => 'nullable|image|max:5120',
            'gallery.*' => 'nullable|image|max:5120',
            'deleted_gallery' => 'nullable|array',
        ]);

        // Update Main Image
        if ($request->hasFile('gambar')) {
            if ($katalog->gambar) {
                Storage::disk('public')->delete($katalog->gambar);
            }
            $katalog->gambar = $request->file('gambar')->store('katalog', 'public');
        }

        $katalog->judul = $request->judul;
        $katalog->deskripsi = $request->deskripsi;
        $katalog->save();

        // Handle Gallery Deletions
        if ($request->has('deleted_gallery')) {
            foreach ($request->deleted_gallery as $imgId) {
                $g = KatalogGambar::find($imgId);
                if ($g && $g->katalog_id == $katalog->id) {
                    Storage::disk('public')->delete($g->gambar);
                    $g->delete();
                }
            }
        }

        // Handle New Gallery Images
        if ($request->hasFile('gallery')) {
            foreach ($request->file('gallery') as $img) {
                $path = $img->store('katalog_gallery', 'public');
                $katalog->gambars()->create(['gambar' => $path]);
            }
        }

        return response()->json(['message' => 'Katalog berhasil diperbarui', 'data' => $katalog->load('gambars')]);
    }

    public function destroy($id)
    {
        $katalog = Katalog::with('gambars')->findOrFail($id);

        // Delete Main Image
        if ($katalog->gambar) {
            Storage::disk('public')->delete($katalog->gambar);
        }

        // Delete Gallery Images
        foreach ($katalog->gambars as $g) {
            Storage::disk('public')->delete($g->gambar);
        }

        $katalog->delete();
        return response()->json(['message' => 'Katalog berhasil dihapus']);
    }
}
