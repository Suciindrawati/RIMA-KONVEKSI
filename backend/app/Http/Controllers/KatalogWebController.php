<?php

namespace App\Http\Controllers;

use App\Models\Katalog;
use Illuminate\Http\Request;

class KatalogWebController extends Controller
{
    public function index()
    {
        $katalog = Katalog::with('gambars')->latest()->get();
        return view('katalog.index', compact('katalog'));
    }

    public function show($id)
    {
        $item = Katalog::with('gambars')->findOrFail($id);
        return view('katalog.show', compact('item'));
    }
}
