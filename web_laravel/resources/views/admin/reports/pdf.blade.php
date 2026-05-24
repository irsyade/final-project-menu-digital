<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Laporan Penjualan - {{ ucfirst($period) }}</title>
    <style>
        body { font-family: sans-serif; font-size: 12px; color: #333; }
        .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #E8781A; padding-bottom: 10px; }
        .header h1 { margin: 0; color: #E8781A; font-size: 24px; }
        .header p { margin: 5px 0 0 0; color: #666; }
        .summary { margin-bottom: 20px; }
        .summary table { width: 100%; border-collapse: collapse; }
        .summary td { padding: 8px; border: 1px solid #ddd; }
        .summary .label { font-weight: bold; background-color: #f9f9f9; width: 30%; }
        .data-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .data-table th, .data-table td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        .data-table th { background-color: #f4f4f5; font-weight: bold; color: #333; }
        .data-table tr:nth-child(even) { background-color: #fafafa; }
        .text-right { text-align: right !important; }
        .text-center { text-align: center !important; }
        .footer { margin-top: 50px; font-size: 10px; color: #999; text-align: center; }
    </style>
</head>
<body>

    <div class="header">
        <h1>MenuKu Dashboard</h1>
        <p>Laporan Penjualan ({{ ucfirst($period) }})</p>
        <p>Periode: {{ $startDate->format('d M Y') }} - {{ $endDate->format('d M Y') }}</p>
    </div>

    <div class="summary">
        <table>
            <tr>
                <td class="label">Total Pendapatan</td>
                <td>Rp {{ number_format($totalRevenue, 0, ',', '.') }}</td>
            </tr>
            <tr>
                <td class="label">Jumlah Pesanan Berhasil</td>
                <td>{{ count($orders) }} Transaksi</td>
            </tr>
            <tr>
                <td class="label">Waktu Cetak Laporan</td>
                <td>{{ now()->format('d M Y H:i') }}</td>
            </tr>
        </table>
    </div>

    <h3>Rincian Transaksi</h3>
    <table class="data-table">
        <thead>
            <tr>
                <th class="text-center" width="5%">No</th>
                <th width="15%">ID Pesanan</th>
                <th width="20%">Tanggal</th>
                <th width="30%">Nama Pelanggan</th>
                <th width="15%">Status</th>
                <th class="text-right" width="15%">Total</th>
            </tr>
        </thead>
        <tbody>
            @forelse($orders as $index => $order)
                <tr>
                    <td class="text-center">{{ $index + 1 }}</td>
                    <td>#{{ $order->id }}</td>
                    <td>{{ $order->created_at->format('d/m/Y H:i') }}</td>
                    <td>{{ $order->name ?? 'Pelanggan Anonim' }}</td>
                    <td>{{ ucfirst($order->status) }}</td>
                    <td class="text-right">Rp {{ number_format($order->total_price, 0, ',', '.') }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="6" class="text-center" style="padding: 30px;">Tidak ada transaksi pada periode ini.</td>
                </tr>
            @endforelse
        </tbody>
    </table>

    <div class="footer">
        Dicetak secara otomatis oleh sistem MenuKu pada {{ now()->format('d M Y H:i') }}
    </div>

</body>
</html>
