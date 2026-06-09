<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lacak Pesanan - Rima Konveksi</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        :root {
            --brand: #f97316;
            --brand-dark: #ea580c;
            --brand-light: #fff7ed;
            --primary: #1e293b;
            --secondary: #64748b;
            --surface: #ffffff;
            --bg: #f8fafc;
            --border: #e2e8f0;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }
        body { background-color: var(--bg); color: var(--primary); line-height: 1.6; }

        .hero-section { background: linear-gradient(135deg, #fff 0%, #fff7ed 100%); padding: 5rem 1rem 7rem; text-align: center; border-bottom: 1px solid var(--border); position: relative; }
        .hero-section::after { content: ''; position: absolute; bottom: 0; left: 0; right: 0; height: 100px; background: linear-gradient(to bottom, transparent, var(--bg)); }

        .brand-logo { display: flex; align-items: center; justify-content: center; gap: 12px; margin-bottom: 1.5rem; }
        .brand-logo h1 { font-size: 2.5rem; font-weight: 800; color: var(--brand); letter-spacing: -1px; text-transform: uppercase; }
        .hero-title { font-size: 1.25rem; font-weight: 600; color: var(--secondary); max-width: 600px; margin: 0 auto; }

        .search-container { max-width: 700px; margin: -4rem auto 4rem; padding: 0 1rem; position: relative; z-index: 10; }
        .search-card { background: var(--surface); padding: 1.5rem; border-radius: 24px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05); border: 1px solid var(--border); }
        .search-input-group { display: flex; gap: 12px; }
        .input-relative { flex: 1; position: relative; }
        .input-relative i { position: absolute; left: 1.25rem; top: 50%; transform: translateY(-50%); color: var(--secondary); }
        .search-field { width: 100%; padding: 1.25rem 1.25rem 1.25rem 3.5rem; border: 2px solid #f1f5f9; border-radius: 16px; font-size: 1.1rem; font-weight: 500; outline: none; transition: 0.3s; background: #f8fafc; }
        .search-field:focus { border-color: var(--brand); background: #fff; box-shadow: 0 0 0 4px var(--brand-light); }
        .btn-search { background: var(--brand); color: #fff; border: none; padding: 0 2rem; border-radius: 16px; font-weight: 700; font-size: 1.1rem; cursor: pointer; transition: 0.3s; }

        .results-section { max-width: 700px; margin: 0 auto 6rem; padding: 0 1rem; }
        .customer-card { background: var(--surface); padding: 1.5rem; border-radius: 20px; margin-bottom: 1rem; border: 1px solid var(--border); cursor: pointer; transition: 0.3s; display: flex; align-items: center; gap: 1rem; }
        .customer-card:hover { border-color: var(--brand); transform: translateY(-4px); box-shadow: 0 10px 20px rgba(0,0,0,0.05); }
        .avatar-circle { width: 50px; height: 50px; background: var(--brand-light); color: var(--brand); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 1.25rem; }

        /* Modal */
        .modal-overlay { position: fixed; inset: 0; background: rgba(15, 23, 42, 0.82); backdrop-filter: blur(8px); z-index: 1000; display: none; align-items: center; justify-content: center; padding: 1.5rem; }
        .modal-body { background: white; width: 100%; max-width: 500px; border-radius: 32px; padding: 3rem; position: relative; animation: modalPop 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); }
        @keyframes modalPop { from { transform: scale(0.9); opacity:0; } to { transform: scale(1); opacity:1; } }
        .modal-close { position: absolute; right: 1.5rem; top: 1.5rem; color: var(--secondary); cursor: pointer; }

        footer { padding: 4rem 1rem; text-align: center; color: var(--secondary); font-size: 0.9rem; }
        
        .loading-overlay { display:none; position:fixed; inset:0; background:rgba(255,255,255,0.8); z-index:2000; align-items:center; justify-content:center; flex-direction:column; gap:1rem; }
    </style>
</head>
<body>

    <!-- Navigation -->
    <nav style="background: white; border-bottom: 1px solid var(--border); padding: 1.25rem 2rem; position: sticky; top: 0; z-index: 100; display: flex; justify-content: space-between; align-items: center;">
        <a href="{{ route('cek-pesanan') }}" style="text-decoration: none; display: flex; align-items: center; gap: 8px;">
            <div style="background: var(--brand); color: white; border-radius: 8px; padding: 4px;"><i data-lucide="scissors" style="width: 18px; height: 18px;"></i></div>
            <span style="font-weight: 800; color: var(--brand); font-size: 1.25rem; tracking: -0.5px;">RIMA KONVEKSI</span>
        </a>
        <div style="display: flex; gap: 1.5rem;">
            <a href="{{ route('cek-pesanan') }}" style="text-decoration: none; color: var(--brand); font-weight: 700; font-size: 0.9rem;">Lacak Pesanan</a>
            <a href="{{ route('katalog.index') }}" style="text-decoration: none; color: var(--secondary); font-weight: 600; font-size: 0.9rem;">Katalog Model</a>
        </div>
    </nav>

    <section class="hero-section" style="padding-top: 4rem;">
        <div class="brand-logo" style="margin-bottom: 1rem;">
            <h1 style="font-size: 3rem;">MODEL TERBARU</h1>
        </div>
        <p class="hero-title">Temukan inspirasi model pakaian terbaik untuk tim atau komunitas Anda di Rima Konveksi.</p>
    </section>

    <div class="search-container">
        <div class="search-card">
            <form action="{{ route('cek-pesanan') }}" method="GET">
                <div class="search-input-group">
                    <div class="input-relative">
                        <i data-lucide="search"></i>
                        <input type="text" name="search" class="search-field" placeholder="Ketik Nama Lengkap Anda..." value="{{ $search }}" required>
                    </div>
                    <button type="submit" class="btn-search">Lacak</button>
                </div>
            </form>
        </div>
    </div>

    <section class="results-section">
        @if($search)
            @if($pelanggan && $pelanggan->count() > 0)
                <h2 style="font-size: 1rem; color: var(--secondary); margin-bottom: 2rem; font-weight: 700;">Ditemukan {{ $pelanggan->count() }} Nama yang Sesuai:</h2>
                @foreach($pelanggan as $p)
                    <div class="customer-card" onclick="openVerification({{ $p->id }}, '{{ $p->nama }}')">
                        <div class="avatar-circle">{{ strtoupper($p->nama[0]) }}</div>
                        <div style="flex:1">
                            <h4 style="font-weight: 800; font-size: 1.15rem;">{{ $p->nama }}</h4>
                            <p style="color: var(--secondary); font-size: 0.9rem;">Lihat Riwayat & Ukuran Saya</p>
                        </div>
                        <div style="background: var(--brand-light); color: var(--brand); padding: 8px; border-radius: 12px;"><i data-lucide="arrow-right"></i></div>
                    </div>
                @endforeach
            @else
                <div style="text-align: center; padding: 4rem 1rem; background:white; border-radius:24px; border: 1px solid var(--border);">
                    <i data-lucide="user-x" style="width: 60px; height: 60px; color: #cbd5e1; margin-bottom: 1.5rem;"></i>
                    <h3 style="font-size: 1.25rem; font-weight: 800; margin-bottom: 0.5rem;">Nama Belum Terdaftar</h3>
                    <p style="color: var(--secondary); max-width: 300px; margin: 0 auto;">Pastikan penulisan nama benar, atau <a href="https://wa.me/6282251423232" target="_blank" style="color: var(--brand); font-weight: 700; text-decoration: none;">hubungi Admin Rima Konveksi di 0822-5142-3232</a>.</p>
                </div>
            @endif
        @else
            <div style="background: white; padding: 3rem; border-radius: 32px; border: 1px dashed var(--border); text-align: center; color: var(--secondary);">
                <i data-lucide="search" style="width: 40px; margin-bottom: 1rem; opacity: 0.3;"></i>
                <p style="font-weight: 600;">Masukkan nama pemesan untuk mulai melacak.</p>
            </div>
        @endif
    </section>

    <!-- Modal Verify -->
    <div id="modalOverlay" class="modal-overlay">
        <div class="modal-body">
            <i data-lucide="x" class="modal-close" onclick="closeModal()"></i>
            <div style="text-align:center; margin-bottom: 2.5rem;">
                <div style="background: #fdf2f0; width: 64px; height: 64px; border-radius: 20px; display: flex; align-items:center; justify-content:center; margin: 0 auto 1.5rem; color: var(--brand);"><i data-lucide="shield-check" style="width: 32px; height: 32px;"></i></div>
                <h2 style="font-size: 1.5rem; font-weight: 800; margin-bottom: 0.5rem;">Verifikasi Keamanan</h2>
                <p style="color: var(--secondary); font-size: 0.95rem;">Halo <b><span id="targetName"></span></b>, masukkan nomor WhatsApp Anda untuk membuka data.</p>
            </div>
            <div style="margin-bottom: 2rem;">
                <label style="display:block; font-size: 0.85rem; font-weight: 800; color:var(--primary); margin-bottom: 0.75rem;">NOMOR WHATSAPP</label>
                <input type="text" id="inputNoHp" class="search-field" style="padding-left: 1.25rem; background: #f8fafc;" placeholder="Contoh: 0812xxxx" onkeypress="if(event.key==='Enter') submitVerify()">
            </div>
            <button class="btn-search" style="width: 100%; padding: 1.25rem; font-size: 1.15rem;" id="btnSubmit" onclick="submitVerify()">Lihat Status Pesanan</button>
        </div>
    </div>

    <!-- Loading -->
    <div id="loadingOverlay" class="loading-overlay">
        <div style="width: 40px; height: 40px; border: 4px solid var(--brand-light); border-top-color: var(--brand); border-radius: 50%; animation: spin 0.8s linear infinite;"></div>
        <p style="font-weight: 700; color: var(--brand);">Memverifikasi Data...</p>
    </div>

    <style> @keyframes spin { to { transform: rotate(360deg); } } </style>

    <!-- Katalog Section -->
    <section style="max-width: 1200px; margin: 4rem auto; padding: 0 2rem;">
        <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 2.5rem; border-left: 6px solid var(--brand); padding-left: 1.5rem;">
            <div>
                <h2 style="font-size: 2rem; font-weight: 800; color: var(--primary); letter-spacing: -0.5px;">Katalog Model Terbaru</h2>
                <p style="color: var(--secondary); font-weight: 500;">Inspirasi desain pakaian berkualitas untuk tim & komunitas.</p>
            </div>
            <a href="{{ route('katalog.index') }}" style="color: var(--brand); font-weight: 700; text-decoration: none; display: flex; align-items: center; gap: 4px; font-size: 0.95rem;">
                Lihat Semua <i data-lucide="chevron-right" style="width: 18px;"></i>
            </a>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1.5rem;">
            @foreach($katalog as $k)
                <div style="background: white; border-radius: 24px; border: 1px solid var(--border); overflow: hidden; transition: 0.3s; cursor: pointer;" 
                     onmouseover="this.style.borderColor='var(--brand)'; this.style.transform='translateY(-8px)'; this.style.boxShadow='0 20px 25px -5px rgba(0,0,0,0.05)'"
                     onmouseout="this.style.borderColor='var(--border)'; this.style.transform='none'; this.style.boxShadow='none'"
                     onclick="window.location.href='{{ route('katalog.show', $k->id) }}'">
                    <div style="aspect-ratio: 4/5; background: #f8fafc; overflow: hidden; position: relative;">
                        @if($k->gambar)
                            <img src="{{ asset('storage/'.$k->gambar) }}" style="width: 100%; h-full; object-fit: cover;" alt="{{ $k->judul }}">
                        @else
                            <div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #cbd5e1;">
                                <i data-lucide="image" style="width: 48px; height: 48px;"></i>
                            </div>
                        @endif
                        <div style="position: absolute; bottom: 12px; left: 12px; background: rgba(255,255,255,0.9); padding: 4px 12px; border-radius: 12px; font-size: 0.75rem; font-weight: 700; color: var(--brand); backdrop-filter: blur(4px);">
                            MODEL TERBARU
                        </div>
                    </div>
                    <div style="padding: 1.5rem;">
                        <h3 style="font-weight: 800; font-size: 1.1rem; margin-bottom: 0.5rem; color: var(--primary);">{{ $k->judul }}</h3>
                        <p style="color: var(--secondary); font-size: 0.85rem; line-height: 1.5; height: 2.5rem; overflow: hidden;">{{ $k->deskripsi ?? 'Koleksi eksklusif model pakaian Rima Konveksi.' }}</p>
                    </div>
                </div>
            @endforeach
        </div>
    </section>

    <footer>
        <p>&copy; {{ date('Y') }} Rima Konveksi. Seluruh Hak Cipta Dilindungi.</p>
    </footer>

    <script>
        lucide.createIcons();
        let currentPid = null;

        function openVerification(id, name) {
            currentPid = id;
            document.getElementById('targetName').innerText = name;
            document.getElementById('modalOverlay').style.display = 'flex';
            document.body.style.overflow = 'hidden';
            setTimeout(() => document.getElementById('inputNoHp').focus(), 100);
        }

        function closeModal() {
            document.getElementById('modalOverlay').style.display = 'none';
            document.body.style.overflow = 'auto';
            document.getElementById('inputNoHp').value = '';
        }

        async function submitVerify() {
            const val = document.getElementById('inputNoHp').value;
            if(!val) return;

            document.getElementById('loadingOverlay').style.display = 'flex';

            try {
                const res = await fetch(`/verify`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' },
                    body: JSON.stringify({ id: currentPid, no_hp: val })
                });
                const r = await res.json();
                if (r.success) {
                    window.location.href = r.redirect;
                } else {
                    document.getElementById('loadingOverlay').style.display = 'none';
                    alert(r.message);
                }
            } catch (e) { 
                document.getElementById('loadingOverlay').style.display = 'none';
                alert('Terjadi kesalahan jaringan.'); 
            }
        }
    </script>
</body>
</html>
