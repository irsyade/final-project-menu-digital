<?php

namespace App\Http\Controllers;

use App\Models\Table;
use Illuminate\Http\Request;
use Barryvdh\DomPDF\Facade\Pdf;

class TableController extends Controller
{
    public function index()
    {
        $tables = Table::orderBy('number')->get();
        return view('admin.tables.index', compact('tables'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'number' => 'required|string|unique:tables,number',
            'name' => 'nullable|string|max:255',
            'type' => 'required|string|max:50',
            'capacity' => 'required|integer|min:1',
            'customer_name' => 'nullable|string|max:255',
            'is_active' => 'boolean',
        ]);

        $data['is_active'] = $request->has('is_active');
        if (!isset($data['status'])) {
            $data['status'] = 'available'; // Default status for POS
        }

        Table::create($data);
        return back()->with('success', 'Table added successfully!');
    }

    public function update(Request $request, Table $table)
    {
        $data = $request->validate([
            'number' => 'required|string|unique:tables,number,' . $table->id,
            'name' => 'nullable|string|max:255',
            'type' => 'required|string|max:50',
            'capacity' => 'required|integer|min:1',
            'status' => 'required|string|in:available,occupied,booked',
            'customer_name' => 'nullable|string|max:255',
            'is_active' => 'boolean',
        ]);

        $data['is_active'] = $request->has('is_active');

        $table->update($data);
        return back()->with('success', 'Table updated successfully!');
    }

    public function toggleStatus(Table $table)
    {
        $table->update([
            'is_active' => !$table->is_active
        ]);
        
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
            $url = url('/menu?meja=' . urlencode($table->number));
            if (class_exists(\SimpleSoftwareIO\QrCode\Facades\QrCode::class)) {
                $qrSvg = \SimpleSoftwareIO\QrCode\Facades\QrCode::format('svg')->size(150)->generate($url);
            } else {
                $qrImage = file_get_contents('https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=' . urlencode($url));
                $qrSvg = '<img src="data:image/png;base64,' . base64_encode($qrImage) . '" width="150" height="150">';
            }
            $qrs[] = [
                'table' => $table,
                'svg' => $qrSvg,
            ];
        }

        $pdf = Pdf::loadView('admin.tables.qr-pdf-all', compact('qrs'));
        $pdf->setPaper('A4', 'portrait');
        
        return $pdf->download('Semua_QR_Meja.pdf');
    }

    public function downloadQr(Table $table)
    {
        $url = url('/menu?meja=' . urlencode($table->number));
        
        if (class_exists(\SimpleSoftwareIO\QrCode\Facades\QrCode::class)) {
            $qrSvg = \SimpleSoftwareIO\QrCode\Facades\QrCode::format('svg')->size(300)->generate($url);
        } else {
            $qrImage = file_get_contents('https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=' . urlencode($url));
            $qrSvg = '<img src="data:image/png;base64,' . base64_encode($qrImage) . '" width="300" height="300">';
        }

        $pdf = Pdf::loadView('admin.tables.qr-pdf', compact('table', 'qrSvg'));
        $pdf->setPaper('A4', 'portrait');

        $filename = 'QR_Meja_' . preg_replace('/[^A-Za-z0-9\-]/', '_', $table->number) . '.pdf';
        return $pdf->download($filename);
    }
}
