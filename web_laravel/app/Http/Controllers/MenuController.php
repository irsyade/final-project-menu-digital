<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Product;
use App\Models\Promo;
use App\Models\Setting;
use App\Models\Table;
use Illuminate\Http\Request;

class MenuController extends Controller
{
    public function index(Request $request)
    {
        $setting    = Setting::first();
        $restoName  = $setting->site_name ?? 'MenuKu';
        $categories = Category::all();
        $products   = Product::all();
        $tables     = Table::all();

        // Baca parameter ?table= (dari QR baru) ATAU ?meja= (legacy)
        $tableParam = $request->query('table') ?? $request->query('meja');

        // Cari meja dari database berdasarkan nomor
        $tableModel = null;
        if ($tableParam) {
            $tableModel = Table::where('number', $tableParam)
                ->orWhere('name', $tableParam)
                ->first();
        }

        // Bangun label yang ditampilkan: "Meja 01 • VIP" atau "Meja 01"
        if ($tableModel) {
            $tableLabel = 'Meja ' . $tableModel->number;
            if ($tableModel->name && $tableModel->name !== 'Meja ' . $tableModel->number) {
                $tableLabel .= ' • ' . $tableModel->name;
            }
        } elseif ($tableParam) {
            // Fallback jika QR valid tapi meja tidak ada di DB
            $tableLabel = 'Meja ' . $tableParam;
        } else {
            $tableLabel = '';
        }

        $now    = \Carbon\Carbon::now();
        $promos = Promo::where('is_active', true)
            ->where(function ($q) use ($now) {
                $q->whereNull('start_date')->orWhere('start_date', '<=', $now->copy()->addMinutes(5));
            })
            ->where(function ($q) use ($now) {
                $q->whereNull('end_date')->orWhere('end_date', '>=', $now->copy()->subMinutes(5));
            })
            ->orderBy('is_banner', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        // $tableName dipakai oleh Livewire Cart component
        $tableName = $tableLabel;

        return view('menu', compact('categories', 'products', 'tables', 'restoName', 'tableName', 'promos'));
    }
}
