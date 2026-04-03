<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $item->judul }} - Rima Konveksi</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: #F8FAFC; }
    </style>
</head>
<body class="text-slate-800">
    <nav class="bg-white border-b border-slate-200 py-4 px-6 sticky top-0 z-50">
        <div class="max-w-6xl mx-auto flex justify-between items-center">
            <a href="{{ route('katalog.index') }}" class="flex items-center gap-2 text-slate-500 hover:text-orange-600 transition-colors font-bold">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 19l-7-7 7-7"></path></svg>
                Katalog Model
            </a>
            <span class="text-slate-200">|</span>
            <span class="text-orange-600 font-extrabold tracking-tighter">RIMA KONVEKSI</span>
        </div>
    </nav>

    <main class="max-w-6xl mx-auto py-12 px-6">
        <div class="flex flex-col lg:flex-row gap-12">
            <!-- Image Section -->
            <div class="flex-1 space-y-6">
                <!-- Main Image -->
                <div class="bg-white rounded-[40px] overflow-hidden border border-slate-200 shadow-sm aspect-square overflow-hidden group">
                    <img id="main-photo" src="{{ asset('storage/' . $item->gambar) }}" alt="{{ $item->judul }}" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700">
                </div>

                <!-- Gallery Thumbnails -->
                <div class="grid grid-cols-4 gap-4">
                    <div class="aspect-square rounded-2xl overflow-hidden cursor-pointer active-thumbnail ring-2 ring-orange-500 ring-offset-2 transition-all opacity-100" onclick="changePhoto(this, '{{ asset('storage/' . $item->gambar) }}')">
                        <img src="{{ asset('storage/' . $item->gambar) }}" class="w-full h-full object-cover">
                    </div>
                    @foreach($item->gambars as $gallery)
                        <div class="aspect-square rounded-2xl overflow-hidden cursor-pointer opacity-60 hover:opacity-100 transition-all" onclick="changePhoto(this, '{{ asset('storage/' . $gallery->gambar) }}')">
                            <img src="{{ asset('storage/' . $gallery->gambar) }}" class="w-full h-full object-cover">
                        </div>
                    @endforeach
                </div>
            </div>

            <!-- Content Section -->
            <div class="flex-1 py-4">
                <div class="bg-white p-8 md:p-12 rounded-[40px] border border-slate-200 h-full">
                    <div class="mb-8">
                        <h1 class="text-3xl md:text-4xl font-extrabold text-slate-900 leading-tight mb-4">{{ $item->judul }}</h1>
                        <div class="inline-block px-4 py-2 bg-orange-50 text-orange-600 font-extrabold text-xs rounded-full uppercase tracking-wider">Model Katalog Rima</div>
                    </div>

                    <div class="space-y-6 text-slate-600 leading-relaxed text-lg mb-12">
                        <p>{{ $item->deskripsi ?? 'Koleksi model pakaian eksklusif Rima Konveksi. Jahitan rapi, bahan premium, dan desain yang selalu mengikuti tren terkini.' }}</p>
                    </div>

                    <div class="pt-8 border-t border-slate-100">
                        <p class="text-sm font-bold text-slate-400 mb-6 uppercase tracking-widest">Pesan Model Ini?</p>
                        <a href="https://wa.me/628123456789?text=Halo%20Rima%20Konveksi,%20saya%20tertarik%20dengan%20model%3A%20{{ urlencode($item->judul) }}" target="_blank" class="flex items-center justify-center gap-3 w-full bg-slate-900 text-white rounded-3xl py-5 font-bold hover:bg-orange-600 transition-all group scale-100 hover:scale-[1.02] shadow-xl shadow-slate-200 hover:shadow-orange-200">
                            <svg class="w-6 h-6 border-2 border-white rounded-full p-1" fill="white" viewBox="0 0 24 24"><path d="M.057 24l1.687-6.163c-1.041-1.804-1.588-3.849-1.587-5.946.003-6.556 5.338-11.891 11.893-11.891 3.181.001 6.167 1.24 8.413 3.488 2.246 2.248 3.484 5.232 3.484 8.412-.003 6.557-5.338 11.892-11.893 11.892-1.997-.001-3.951-.5-5.688-1.448l-6.309 1.656zm6.29-4.143c1.559.924 3.476 1.488 5.598 1.49 5.485 0 9.946-4.461 9.948-9.948.001-2.656-1.033-5.155-2.908-7.03s-4.375-2.912-7.033-2.913c-5.485 0-9.946 4.461-9.948 9.948-.001 1.956.574 3.86 1.662 5.474l-.998 3.646 3.731-.979zm11.354-6.401c-.272-.136-1.606-.791-1.854-.881-.248-.091-.43-.136-.61.136-.181.272-.701.881-.859 1.066-.158.185-.316.208-.588.072-.272-.136-1.15-.423-2.19-1.352-.809-.722-1.356-1.613-1.515-1.886-.158-.272-.017-.419.119-.554.122-.122.272-.318.408-.477.136-.159.181-.272.272-.454.091-.181.045-.341-.023-.477-.068-.136-.61-1.477-.837-2.022-.222-.531-.444-.458-.61-.466-.157-.008-.337-.01-.518-.01-.181 0-.476.068-.725.341-.249.272-.952.931-.952 2.272 0 1.341.975 2.636 1.111 2.818.136.182 1.92 2.932 4.652 4.113.65.28 1.157.447 1.554.573.654.208 1.25.179 1.721.109.525-.078 1.606-.657 1.834-1.293.228-.636.228-1.181.16-1.293-.069-.113-.25-.181-.522-.317z"/></svg>
                            TANYA KONSULTASI MODEL
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script>
        function changePhoto(el, url) {
            document.getElementById('main-photo').src = url;
            // Reset thumbnails
            const thumbnails = el.parentElement.children;
            for (let t of thumbnails) {
                t.classList.remove('ring-2', 'ring-orange-500', 'ring-offset-2', 'opacity-100');
                t.classList.add('opacity-60');
            }
            // Highlight active
            el.classList.add('ring-2', 'ring-orange-500', 'ring-offset-2', 'opacity-100');
            el.classList.remove('opacity-60');
        }
    </script>
</body>
</html>
