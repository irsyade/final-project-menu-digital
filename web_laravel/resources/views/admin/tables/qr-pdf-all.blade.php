<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Semua QR Meja</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: DejaVu Sans, sans-serif; text-align: center; background: #fff; }

        .header { margin-bottom: 24px; padding-top: 20px; }
        .header h2 { color: #0f172a; font-size: 22px; margin-bottom: 4px; }
        .header p  { color: #64748b; font-size: 12px; }

        /* dompdf uses a table-based layout for multi-column grids */
        table.grid { width: 100%; border-collapse: collapse; }
        td.qr-cell {
            width: 25%;
            padding: 12px;
            vertical-align: top;
            text-align: center;
        }

        .qr-card {
            border: 2px dashed #cbd5e1;
            border-radius: 10px;
            padding: 14px 10px 10px 10px;
            display: inline-block;
            width: 100%;
        }

        .table-label {
            font-size: 13px;
            font-weight: bold;
            color: #1e293b;
            margin-bottom: 8px;
        }
        .table-name {
            font-size: 11px;
            color: #64748b;
            margin-bottom: 10px;
        }
        .qr-img img {
            width: 130px;
            height: 130px;
            display: block;
            margin: 0 auto;
        }
        .scan-text {
            font-size: 10px;
            color: #94a3b8;
            margin-top: 8px;
            font-weight: bold;
            letter-spacing: 0.5px;
        }
        .url-text {
            font-size: 7px;
            color: #cbd5e1;
            margin-top: 4px;
            word-break: break-all;
        }

        .page-break { page-break-after: always; }
    </style>
</head>
<body>
    @php
        $setting = \App\Models\Setting::first() ?? new \App\Models\Setting;
        $restaurantName = $setting->site_name ?? 'MenuKu Dashboard';
    @endphp

    <div class="header">
        <h2>Semua QR Code Meja - {{ $restaurantName }}</h2>
        <p>Cetak dokumen ini untuk diletakkan di setiap meja.</p>
    </div>

    {{-- dompdf renders floats and inline-block poorly — use <table> for grid --}}
    <table class="grid">
        <tr>
        @foreach($qrs as $index => $item)
            @php
                $menuUrl = 'https://menuku.icaadrm.my.id/menu?table=' . urlencode($item['table']->number);
                $displayName = $item['table']->name ?? 'Meja ' . $item['table']->number;
            @endphp

            <td class="qr-cell">
                <div class="qr-card">
                    <div class="table-label">Meja {{ $item['table']->number }}</div>
                    @if($displayName !== 'Meja ' . $item['table']->number)
                        <div class="table-name">{{ $displayName }}</div>
                    @endif
                    <div class="qr-img">{!! $item['svg'] !!}</div>
                    <div class="scan-text">Scan untuk memesan</div>
                    <div class="url-text">{{ $menuUrl }}</div>
                </div>
            </td>

            {{-- 4 columns per row; close and open new row --}}
            @if(($index + 1) % 4 == 0 && ($index + 1) != count($qrs))
                </tr>
                @if(($index + 1) % 16 == 0)
                    </table>
                    <div class="page-break"></div>
                    <table class="grid">
                @endif
                <tr>
            @endif

        @endforeach

        {{-- Pad the last row with empty cells to keep alignment --}}
        @php $remainder = count($qrs) % 4; @endphp
        @if($remainder !== 0)
            @for($i = 0; $i < (4 - $remainder); $i++)
                <td class="qr-cell"></td>
            @endfor
        @endif
        </tr>
    </table>

</body>
</html>
