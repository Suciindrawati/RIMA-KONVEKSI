<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hasil Lacak Pesanan - Rima Konveksi</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        :root {
            --brand: #f97316;
            --brand-light: #fff7ed;
            --primary: #1e293b;
            --secondary: #64748b;
            --bg: #f1f5f9;
            --surface: #ffffff;
            --border: #e2e8f0;
            --success: #10b981;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }
        body { background-color: var(--bg); color: var(--primary); padding-bottom: 5rem; }

        .top-nav { background: white; padding: 1rem 2rem; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid var(--border); sticky: top; z-index: 100; }
        .back-btn { display: flex; align-items: center; gap: 8px; color: var(--secondary); text-decoration: none; font-weight: 700; font-size: 0.9rem; transition: 0.3s; }
        .back-btn:hover { color: var(--brand); }

        .dashboard { max-width: 1100px; margin: 2rem auto; padding: 0 1rem; display: grid; grid-template-columns: 350px 1fr; gap: 2rem; }

        /* Sidebar Profile */
        .profile-card { background: white; border-radius: 28px; padding: 2.5rem; border: 1px solid var(--border); box-shadow: 0 4px 6px -1px rgba(0,0,0,0.02); height: fit-content; text-align: center; }
        .avatar-lg { width: 100px; height: 100px; background: var(--brand); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 2.5rem; font-weight: 800; margin: 0 auto 1.5rem; box-shadow: 0 10px 20px rgba(249, 115, 22, 0.2); }
        .profile-card h2 { font-size: 1.5rem; font-weight: 800; margin-bottom: 0.25rem; }
        .profile-card p { color: var(--secondary); font-weight: 600; margin-bottom: 2rem; }

        .contact-box { background: var(--bg); padding: 1.25rem; border-radius: 20px; text-align: left; }
        .contact-label { font-size: 0.7rem; font-weight: 800; color: var(--secondary); text-transform: uppercase; margin-bottom: 8px; display: block; }
        .contact-value { font-weight: 700; display: flex; align-items: center; gap: 8px; font-size: 0.95rem; }

        /* Main Content */
        .main-content { display: flex; flex-direction: column; gap: 2rem; }

        .section-card { background: white; border-radius: 28px; padding: 2.5rem; border: 1px solid var(--border); }
        .sect-title { display: flex; align-items: center; gap: 12px; margin-bottom: 2rem; }
        .sect-title i { color: var(--brand); }
        .sect-title h3 { font-size: 1.25rem; font-weight: 800; }

        /* Ukuran Grid */
        .ukuran-cats { display: flex; flex-direction: column; gap: 1.5rem; }
        .cat-group h4 { font-size: 0.8rem; font-weight: 800; color: var(--secondary); text-transform: uppercase; margin-bottom: 1rem; border-left: 3px solid var(--brand); padding-left: 10px; }
        .grid-uk { display: grid; grid-template-columns: repeat(auto-fill, minmax(130px, 1fr)); gap: 1rem; }
        .uk-item { background: #f8fafc; padding: 1rem; border-radius: 16px; border: 1px solid #f1f5f9; }
        .uk-lbl { font-size: 0.7rem; font-weight: 700; color: var(--secondary); margin-bottom: 4px; }
        .uk-val { font-size: 1.1rem; font-weight: 800; color: var(--primary); }

        /* History List */
        .order-history { display: flex; flex-direction: column; gap: 1.5rem; }
        .history-card { background: white; border: 1px solid var(--border); border-radius: 24px; padding: 2rem; position: relative; overflow: hidden; }
        .history-card::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 6px; background: #e2e8f0; }
        .history-card.active::before { background: var(--brand); }
        
        .h-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; }
        .h-info h4 { font-size: 1.3rem; font-weight: 800; margin-bottom: 4px; }
        .h-info p { color: var(--secondary); font-size: 0.85rem; font-weight: 600; }

        .h-progress { display: grid; grid-template-columns: 1fr auto 1fr; gap: 1rem; align-items: center; margin-bottom: 2.5rem; }
        .pg-bar-cont { width: 100%; height: 8px; background: #f1f5f9; border-radius: 4px; position: relative; margin: 1rem 0; overflow: hidden; }
        .pg-fill { height: 100%; background: var(--brand); border-radius: 4px; transition: 1.5s; width: 0; }
        .pg-pct { font-size: 1.7rem; font-weight: 800; color: var(--brand); text-align: center; }

        .timeline-row { display: flex; justify-content: space-between; position: relative; padding: 0 10%; }
        .timeline-row::after { content: ''; position: absolute; top: 8px; left: 10%; right: 10%; height: 2px; background: #f1f5f9; z-index: 1; }
        .t-node { width: 18px; height: 18px; border-radius: 50%; background: white; border: 3px solid #e2e8f0; position: relative; z-index: 2; transition: 0.5s 1s; }
        .t-node.done { border-color: var(--brand); background: var(--brand); box-shadow: 0 0 0 6px var(--brand-light); }
        .t-lbl { position: absolute; top: 30px; left: 50%; transform: translateX(-50%); white-space: nowrap; font-size: 0.75rem; font-weight: 800; color: var(--secondary); }
        .t-node.done .t-lbl { color: var(--brand); }

        .status-msg { background: #fffcf0; border: 1px solid #fef3c7; padding: 1.25rem; border-radius: 20px; display: flex; gap: 12px; margin-top: 2rem; }
        .status-msg p { font-size: 0.95rem; font-weight: 600; color: #92400e; }

        .price-tag { background: #f0fdf4; border: 1px solid #dcfce7; padding: 1.5rem; border-radius: 20px; display: flex; justify-content: space-between; align-items: center; margin-top: 1.5rem; }

        @media (max-width: 900px) {
            .dashboard { grid-template-columns: 1fr; }
            .profile-card { order: -1; }
            .h-progress { grid-template-columns: 1fr; text-align: center; }
        }
    </style>
</head>
<body>

    <nav class="top-nav">
        <a href="{{ route('cek-pesanan') }}" class="back-btn">
            <i data-lucide="arrow-left"></i> KEMBALI KE PENCARIAN
        </a>
        <div style="font-weight: 800; color: var(--brand);">RIMA KONVEKSI</div>
    </nav>

    <div class="dashboard">
        <!-- Profile Section -->
        <aside class="profile-card">
            <div class="avatar-lg">{{ strtoupper($p->nama[0]) }}</div>
            <h2>{{ $p->nama }}</h2>
            <p>ID Pelanggan: #{{ $p->id }}</p>

            <div class="contact-box">
                <span class="contact-label">Nomor WhatsApp</span>
                <div class="contact-value"><i data-lucide="phone"></i> {{ $p->no_hp }}</div>
            </div>

            <div style="margin-top: 2rem;">
                <p style="font-size: 0.8rem; margin-bottom: 1rem;">Ada pertanyaan mengenai pesanan atau ingin mengubah ukuran?</p>
                <a href="https://wa.me/{{ preg_replace('/[^0-9]/', '', $p->no_hp) }}" target="_blank" style="display:flex; align-items:center; justify-content:center; gap:8px; background: #10b981; color:white; text-decoration:none; padding: 1rem; border-radius:16px; font-weight:800;">
                    <i data-lucide="message-circle"></i> Chat Admin Sekarang
                </a>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="main-content">
            
            <!-- Measurements Section -->
            <section class="section-card">
                <div class="sect-title">
                    <i data-lucide="scissors"></i>
                    <h3>Data Ukuran Saya</h3>
                </div>
                
                @if(count($ukuran) > 0)
                    <div class="ukuran-cats">
                        @foreach($ukuran as $cat => $items)
                        <div class="cat-group">
                            <h4>Ukuran {{ $cat }} (Cm)</h4>
                            <div class="grid-uk">
                                @foreach($items as $label => $val)
                                <div class="uk-item">
                                    <div class="uk-lbl">{{ $label }}</div>
                                    <div class="uk-val">{{ $val }}</div>
                                </div>
                                @endforeach
                            </div>
                        </div>
                        @endforeach
                    </div>
                @else
                    <div style="text-align:center; padding: 2rem; color: var(--secondary);">
                        <p>Belum ada data ukuran pengerjaan tercatat.</p>
                    </div>
                @endif
            </section>

            <!-- Order History Section -->
            <section>
                <div class="sect-title" style="margin-bottom: 1.5rem;">
                    <i data-lucide="package"></i>
                    <h3>Riwayat Pesanan ({{ count($history) }})</h3>
                </div>

                <div class="order-history">
                    @foreach($history as $index => $t)
                    <div class="history-card {{ $t->step < 3 ? 'active' : '' }}">
                        <div class="h-header">
                            <div class="h-info">
                                <h4>{{ $t->produk }}</h4>
                                <p>No. Transaksi #{{ $t->id }} • Dipesan pada {{ $t->tanggal }}</p>
                            </div>
                            <div style="background: var(--brand-light); border: 2px solid var(--brand); color:var(--brand); padding: 0.5rem 1rem; border-radius: 12px; font-weight:800; font-size:0.8rem;">
                                {{ strtoupper($t->status) }}
                            </div>
                        </div>

                        <div class="h-progress">
                            <div class="pg-bar-cont">
                                <div class="pg-fill" style="width: {{ $t->progress }}%;"></div>
                            </div>
                            <div class="pg-pct">{{ $t->progress }}%</div>
                            <div style="font-weight: 700; color: var(--secondary); text-transform: uppercase; font-size: 0.7rem;">Telah Selesai</div>
                        </div>

                        <div class="timeline-row">
                            <div class="t-node {{ $t->step >= 1 ? 'done' : '' }}"><span class="t-lbl">Diterima</span></div>
                            <div class="t-node {{ $t->step >= 2 ? 'done' : '' }}"><span class="t-lbl">Diproses</span></div>
                            <div class="t-node {{ $t->step >= 3 ? 'done' : '' }}"><span class="t-lbl">Selesai</span></div>
                        </div>

                        <div class="status-msg">
                            <i data-lucide="info" style="color: #92400e;"></i>
                            <p>{{ $t->msg }}</p>
                        </div>

                        <div class="price-tag">
                            <span style="font-weight: 700; color: var(--secondary); font-size: 0.9rem;">TOTAL PEMBAYARAN</span>
                            <span style="font-weight: 900; font-size: 1.4rem; color: var(--success);">{{ $t->total_harga }}</span>
                        </div>
                    </div>
                    @endforeach
                </div>
            </section>

        </main>
    </div>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>
