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
        $setting = Setting::first();
        $restoName = $setting->site_name ?? 'MenuKu'; 
        $categories = Category::all();
        $products = Product::all();
        $tables = Table::all();
        $tableName = $request->query('meja', 'Meja Default');
        $now = \Carbon\Carbon::now();
        $promos = Promo::where('is_active', true)
            ->where(function($q) use ($now) {
                $q->whereNull('start_date')->orWhere('start_date', '<=', $now->copy()->addMinutes(5));
            })
            ->where(function($q) use ($now) {
                $q->whereNull('end_date')->orWhere('end_date', '>=', $now->copy()->subMinutes(5));
            })
            ->orderBy('is_banner', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();
        return view('menu', compact('categories', 'products', 'tables', 'restoName', 'tableName', 'promos'));
    }
}
