<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>QR Meja {{ $table->number }}</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: DejaVu Sans, sans-serif;
            text-align: center;
            background: #fff;
            padding-top: 60px;
        }

        .card {
            display: inline-block;
            padding: 32px 40px;
            border: 2px solid #e2e8f0;
            border-radius: 16px;
        }

        .brand {
            font-size: 14px;
            font-weight: bold;
            color: #f97316;
            letter-spacing: 1px;
            margin-bottom: 6px;
        }

        .table-number {
            font-size: 32px;
            font-weight: bold;
            color: #0f172a;
            margin-bottom: 4px;
        }

        .table-name {
            font-size: 14px;
            color: #64748b;
            margin-bottom: 20px;
        }

        /* The <img> tag from base64 — dompdf handles this correctly */
        .qr-wrap img {
            width: 280px;
            height: 280px;
            display: block;
            margin: 0 auto;
        }

        .scan-label {
            font-size: 14px;
            color: #334155;
            font-weight: bold;
            margin-top: 18px;
        }

        .url-label {
            font-size: 9px;
            color: #94a3b8;
            margin-top: 8px;
        }

        .info-row {
            margin-top: 20px;
            font-size: 12px;
            color: #64748b;
        }
    </style>
</head>
<body>
    @php
        $setting = \App\Models\Setting::first() ?? new \App\Models\Setting;
        $menuUrl  = 'https://menuku.icaadrm.my.id/menu?table=' . urlencode($table->number);
        $nameDisplay = $table->name ?? ('Meja ' . $table->number);
        $restaurantName = $setting->site_name ?? 'MENUKU';
    @endphp

    <div class="card">
        <div class="brand">{{ strtoupper($restaurantName) }}</div>
        <div class="table-number">Meja {{ $table->number }}</div>

        @if($nameDisplay !== 'Meja ' . $table->number)
            <div class="table-name">{{ $nameDisplay }}</div>
        @endif

        {{-- QR code as base64 PNG image — renders correctly in dompdf --}}
        <div class="qr-wrap">{!! $qrSvg !!}</div>

        <div class="scan-label">Scan untuk memesan</div>
        <div class="url-label">{{ $menuUrl }}</div>

        <div class="info-row">
            {{ $table->type }} &bull; {{ $table->capacity }} orang
        </div>
    </div>
</body>
</html>
