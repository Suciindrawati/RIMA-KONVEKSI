<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Laporan Transaksi</title>
    <style>
        body {
            font-family: sans-serif;
            font-size: 12px;
        }
        .header {
            text-align: center;
            margin-bottom: 20px;
        }
        .header h2 {
            margin: 0;
        }
        .header p {
            margin: 5px 0 0 0;
            color: #555;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        th, td {
            border: 1px solid #000;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        .text-right {
            text-align: right;
        }
        .text-center {
            text-align: center;
        }
        .total-row {
            font-weight: bold;
            background-color: #f9f9f9;
        }
    </style>
</head>
<body>
    <div class="header">
        <h2>RIMA KONVEKSI</h2>
        <p>Laporan Transaksi Bulanan</p>
        <p>Bulan: {{ $bulan }} / Tahun: {{ $tahun }}</p>
    </div>

    <table>
        <thead>
            <tr>
                <th class="text-center">No</th>
                <th>Tanggal</th>
                <th>Pelanggan</th>
                <th>Produk</th>
                <th class="text-center">Jumlah</th>
                <th class="text-center">Status</th>
                <th class="text-right">Total Harga</th>
            </tr>
        </thead>
        <tbody>
            @php $grandTotal = 0; @endphp
            @forelse ($transaksi as $index => $item)
                @php $grandTotal += $item->total_harga ?? 0; @endphp
                <tr>
                    <td class="text-center">{{ $index + 1 }}</td>
                    <td>{{ \Carbon\Carbon::parse($item->tanggal ?? $item->created_at)->format('d-m-Y H:i') }}</td>
                    <td>{{ $item->pelanggan->nama ?? '-' }}</td>
                    <td>{{ $item->produk->nama_produk ?? '-' }}</td>
                    <td class="text-center">{{ $item->jumlah }}</td>
                    <td class="text-center">{{ $item->status }}</td>
                    <td class="text-right">Rp {{ number_format($item->total_harga ?? 0, 0, ',', '.') }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="7" class="text-center">Tidak ada transaksi pada bulan ini.</td>
                </tr>
            @endforelse
        </tbody>
        <tfoot>
            <tr class="total-row">
                <td colspan="6" class="text-right">Total Pendapatan:</td>
                <td class="text-right">Rp {{ number_format($grandTotal, 0, ',', '.') }}</td>
            </tr>
        </tfoot>
    </table>
</body>
</html>
