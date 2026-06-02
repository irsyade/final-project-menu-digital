<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Semua QR Meja</title>
    <style>
        body { font-family: sans-serif; text-align: center; }
        .header { margin-bottom: 30px; }
        .header h2 { color: #0f172a; margin: 0; }
        .header p { color: #64748b; margin: 5px 0 0 0; font-size: 14px; }
        .grid { width: 100%; text-align: center; }
        .qr-card { 
            display: inline-block; 
            width: 25%; 
            margin: 10px; 
            padding: 15px; 
            border: 2px dashed #cbd5e1; 
            border-radius: 12px; 
            text-align: center;
            vertical-align: top;
        }
        .table-name { font-size: 18px; font-weight: bold; margin-bottom: 12px; color: #1e293b; }
        .scan-text { font-size: 11px; color: #94a3b8; margin-top: 10px; font-weight: bold; }
        svg { width: 150px; height: 150px; }
        .page-break { page-break-after: always; }
    </style>
</head>
<body>
    <div class="header">
        <h2>Semua QR Code Meja</h2>
        <p>Cetak dokumen ini untuk diletakkan di setiap meja.</p>
    </div>
    
    <div class="grid">
        @foreach($qrs as $index => $item)
            <div class="qr-card">
                <div class="table-name">Meja {{ $item['table']->number }}</div>
                <div>{!! $item['svg'] !!}</div>
                <div class="scan-text">Scan menu</div>
            </div>
            
            @if(($index + 1) % 9 == 0 && ($index + 1) != count($qrs))
                </div><div class="page-break"></div><div class="grid">
            @endif
        @endforeach
    </div>
</body>
</html>
