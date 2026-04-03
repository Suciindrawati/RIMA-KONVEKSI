<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Katalog Model - Rima Konveksi</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: #F8FAFC; }
        .orange-gradient { background: linear-gradient(135deg, #F97316 0%, #EA580C 100%); }
    </style>
</head>
<body class="text-slate-800">
    <!-- Navbar -->
    <nav class="bg-white border-b border-slate-200 py-4 px-6 sticky top-0 z-50">
        <div class="max-w-7xl mx-auto flex justify-between items-center">
            <a href="{{ route('cek-pesanan') }}" class="flex items-center gap-2">
                <span class="text-2xl font-extrabold text-orange-600 tracking-tighter">RIMA KONVEKSI</span>
            </a>
            <div class="flex gap-4">
                <a href="{{ route('cek-pesanan') }}" class="text-sm font-semibold text-slate-600 hover:text-orange-600">Lacak Pesanan</a>
                <a href="{{ route('katalog.index') }}" class="text-sm font-bold text-orange-600">Katalog</a>
            </div>
        </div>
    </nav>

    <!-- Header -->
    <header class="orange-gradient text-white py-16 px-6">
        <div class="max-w-7xl mx-auto text-center">
            <h1 class="text-4xl md:text-5xl font-extrabold mb-4">Katalog Model Pakaian</h1>
            <p class="text-orange-100 text-lg opacity-90">Inspirasi model terbaik untuk kebutuhan konveksi Anda</p>
        </div>
    </header>

    <!-- Grid Katalog -->
    <main class="max-w-7xl mx-auto py-12 px-6">
        @if($katalog->isEmpty())
            <div class="text-center py-24 bg-white rounded-3xl border border-slate-200">
                <p class="text-slate-500 font-medium">Belum ada koleksi katalog publik saat ini.</p>
            </div>
        @else
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                @foreach($katalog as $item)
                    <div class="bg-white rounded-[32px] overflow-hidden border border-slate-200 hover:shadow-2xl transition-all duration-300 group">
                        <div class="aspect-[4/5] bg-slate-100 relative overflow-hidden">
                            @if($item->gambar)
                                <img src="{{ asset('storage/' . $item->gambar) }}" alt="{{ $item->judul }}" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700">
                            @else
                                <div class="flex items-center justify-center h-full text-slate-300">
                                    <svg class="w-16 h-16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                                </div>
                            @endif
                            <div class="absolute inset-0 bg-gradient-to-t from-orange-600/60 to-transparent opacity-0 group-hover:opacity-100 transition-opacity flex items-end p-8">
                                <a href="{{ route('katalog.show', $item->id) }}" class="bg-white text-orange-600 px-6 py-3 rounded-2xl font-bold text-sm w-full text-center hover:bg-orange-50 transition-colors">LIHAT DETAIL</a>
                            </div>
                        </div>
                        <div class="p-8">
                            <h3 class="text-xl font-extrabold mb-2 text-slate-800">{{ $item->judul }}</h3>
                            <p class="text-slate-500 text-sm line-clamp-2">{{ $item->deskripsi ?? 'Koleksi model pakaian eksklusif Rima Konveksi.' }}</p>
                        </div>
                    </div>
                @endforeach
            </div>
        @endif
    </main>

    <footer class="bg-white border-t border-slate-200 py-12 mt-12">
        <div class="max-w-7xl mx-auto px-6 text-center">
            <p class="text-sm text-slate-400 font-semibold">&copy; 2024 Rima Konveksi. Seluruh Hak Cipta Dilindungi.</p>
        </div>
    </footer>
</body>
</html>
