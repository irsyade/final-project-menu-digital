<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>QR Meja {{ $table->number }}</title>
    <style>
        body { font-family: sans-serif; text-align: center; padding-top: 50px; }
        .qr-container { margin: 0 auto; display: inline-block; padding: 30px; border: 2px solid #334155; border-radius: 16px; }
        .table-name { font-size: 32px; font-weight: bold; margin-bottom: 20px; color: #0f172a; }
        .scan-text { font-size: 16px; color: #64748b; margin-top: 20px; font-weight: bold; }
        svg { width: 300px; height: 300px; }
    </style>
</head>
<body>
    <div class="qr-container">
        <div class="table-name">Meja {{ $table->number }}</div>
        <div>
            {!! $qrSvg !!}
        </div>
        <div class="scan-text">Scan untuk melihat menu</div>
    </div>
</body>
</html>
