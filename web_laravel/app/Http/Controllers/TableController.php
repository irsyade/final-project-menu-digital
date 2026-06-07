<?php

namespace App\Http\Controllers;

use App\Models\Table;
use Illuminate\Http\Request;
use Barryvdh\DomPDF\Facade\Pdf;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class TableController extends Controller
{
    /**
     * Generate QR SVG sebagai base64 string menggunakan simple-qrcode (tanpa Imagick).
     * URL yang di-encode: https://menuku.icaadrm.my.id/menu?table={number}
     */
    private function generateQrBase64(string $tableNumber, int $size = 200): string
    {
        $url = 'https://menuku.icaadrm.my.id/menu?table=' . urlencode($tableNumber);

        $svgString = QrCode::size($size)
            ->color(15, 23, 42)
            ->backgroundColor(255, 255, 255)
            ->margin(1)
            ->generate($url);

        return base64_encode((string)$svgString);
    }

    public function index()
    {
        $tables = Table::orderBy('number')->get();
        return view('admin.tables.index', compact('tables'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'number'        => 'required|string|unique:tables,number',
            'name'          => 'nullable|string|max:255',
            'type'          => 'required|string|max:50',
            'capacity'      => 'required|integer|min:1',
            'customer_name' => 'nullable|string|max:255',
            'is_active'     => 'boolean',
        ]);

        $data['is_active'] = $request->has('is_active');
        if (!isset($data['status'])) {
            $data['status'] = 'available';
        }

        Table::create($data);
        return back()->with('success', 'Table added successfully!');
    }

    public function update(Request $request, Table $table)
    {
        $data = $request->validate([
            'number'        => 'required|string|unique:tables,number,' . $table->id,
            'name'          => 'nullable|string|max:255',
            'type'          => 'required|string|max:50',
            'capacity'      => 'required|integer|min:1',
            'status'        => 'required|string|in:available,occupied,booked',
            'customer_name' => 'nullable|string|max:255',
            'is_active'     => 'boolean',
        ]);

        $data['is_active'] = $request->has('is_active');

        $table->update($data);
        return back()->with('success', 'Table updated successfully!');
    }

    public function toggleStatus(Table $table)
    {
        $table->update(['is_active' => !$table->is_active]);

        if (request()->expectsJson()) {
            return response()->json(['success' => true, 'is_active' => $table->is_active]);
        }
        return back()->with('success', 'Table status updated!');
    }

    public function destroy(Table $table)
    {
        $table->delete();

        if (request()->expectsJson()) {
            return response()->json(['success' => true]);
        }
        return back()->with('success', 'Table removed successfully!');
    }

    public function downloadAllQr()
    {
        $tables = Table::where('is_active', true)->get();

        if ($tables->isEmpty()) {
            return back()->with('error', 'Tidak ada meja aktif untuk didownload.');
        }

        $qrs = [];
        foreach ($tables as $table) {
            $b64   = $this->generateQrBase64($table->number, 200);
            $qrImg = '<img src="data:image/svg+xml;base64,' . $b64
                   . '" width="150" height="150" style="display:block;margin:0 auto;">';

            $qrs[] = [
                'table' => $table,
                'svg'   => $qrImg,   // field name 'svg' dipertahankan agar blade tidak perlu diubah
            ];
        }

        $pdf = Pdf::loadView('admin.tables.qr-pdf-all', compact('qrs'));
        $pdf->setPaper('A4', 'portrait');

        return $pdf->download('Semua_QR_Meja.pdf');
    }

    public function downloadQr(Table $table)
    {
        $b64   = $this->generateQrBase64($table->number, 350);
        $qrSvg = '<img src="data:image/svg+xml;base64,' . $b64
               . '" width="300" height="300" style="display:block;margin:0 auto;">';

        $pdf = Pdf::loadView('admin.tables.qr-pdf', compact('table', 'qrSvg'));
        $pdf->setPaper('A4', 'portrait');

        $filename = 'QR_Meja_' . preg_replace('/[^A-Za-z0-9\-]/', '_', $table->number) . '.pdf';
        return $pdf->download($filename);
    }
}
