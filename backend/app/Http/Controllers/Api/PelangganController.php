<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pelanggan;
use Illuminate\Http\Request;

class PelangganController extends Controller
{
    public function index()
    {
        $pelanggan = Pelanggan::latest()->get();
        return response()->json(['data' => $pelanggan]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama'  => 'required|string|max:255',
            'no_hp' => 'required|string|max:20',
        ]);

        $pelanggan = Pelanggan::create($request->all());

        return response()->json(['message' => 'Pelanggan berhasil ditambahkan', 'data' => $pelanggan], 201);
    }

    public function show($id)
    {
        $pelanggan = Pelanggan::findOrFail($id);
        return response()->json(['data' => $pelanggan]);
    }

    public function update(Request $request, $id)
    {
        $pelanggan = Pelanggan::findOrFail($id);

        $request->validate([
            'nama'  => 'sometimes|required|string|max:255',
            'no_hp' => 'sometimes|required|string|max:20',
        ]);

        $pelanggan->update($request->all());

        return response()->json(['message' => 'Pelanggan berhasil diupdate', 'data' => $pelanggan]);
    }

    public function destroy($id)
    {
        $pelanggan = Pelanggan::findOrFail($id);
        $pelanggan->delete();
        return response()->json(['message' => 'Pelanggan berhasil dihapus']);
    }
}
