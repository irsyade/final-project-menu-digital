<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Product;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
{
    public function dashboard()
    {
        // 1. Stats Cards
        $stats = [
            'totalOrdersToday' => Order::whereDate('created_at', now()->today())->count(),
            'totalIncomeToday' => Order::whereDate('created_at', now()->today())->sum('total_price'),
            'popularProduct' => \App\Models\OrderItem::select('product_id', DB::raw('SUM(quantity) as total'))
                ->groupBy('product_id')
                ->orderByDesc('total')
                ->with('product')
                ->first()?->product?->name ?? '-',
            'activeTables' => \App\Models\Table::where('status', 'occupied')->count(),
            'totalTables' => \App\Models\Table::count() ?: 15,
        ];

        // 2. Chart Data
        $filter = trim(request()->query('filter', 'daily'));
        $labels = [];
        $salesValues = [];

        if ($filter === 'weekly') {
            // Last 4 Weeks
            for ($i = 3; $i >= 0; $i--) {
                $start = now()->subWeeks($i)->startOfWeek();
                $end = now()->subWeeks($i)->endOfWeek();
                $labels[] = 'Pekan ' . (4 - $i);
                $salesValues[] = Order::whereBetween('created_at', [$start, $end])->sum('total_price');
            }
        } elseif ($filter === 'monthly') {
            // Last 12 Months
            for ($i = 11; $i >= 0; $i--) {
                $date = now()->subMonths($i);
                $labels[] = $date->isoFormat('MMM');
                $salesValues[] = Order::whereYear('created_at', $date->year)
                    ->whereMonth('created_at', $date->month)
                    ->sum('total_price');
            }
        } else {
            // Default: Daily (Last 7 Days)
            $chartData = Order::select(
                DB::raw('DATE(created_at) as date'),
                DB::raw('SUM(total_price) as total')
            )
            ->where('created_at', '>=', now()->subDays(6))
            ->groupBy('date')
            ->get()
            ->pluck('total', 'date');

            for ($i = 6; $i >= 0; $i--) {
                $date = now()->subDays($i)->format('Y-m-d');
                $labels[] = now()->subDays($i)->isoFormat('ddd');
                $salesValues[] = $chartData[$date] ?? 0;
            }
        }

        // 3. Recent Orders (Latest 5)
        $recentOrders = Order::with('items.product')->latest()->take(5)->get();

        // 4. Top 5 Popular Products
        $topProducts = \App\Models\OrderItem::select('product_id', DB::raw('SUM(quantity) as total_sold'))
            ->groupBy('product_id')
            ->orderByDesc('total_sold')
            ->with('product')
            ->take(5)
            ->get();

        if (request()->expectsJson()) {
            return response()->json([
                'stats' => $stats,
                'labels' => $labels,
                'salesValues' => $salesValues,
                'recentOrders' => $recentOrders,
                'topProducts' => $topProducts
            ]);
        }

        return view('admin.dashboard', compact('stats', 'labels', 'salesValues', 'recentOrders', 'topProducts'));
    }

    public function categories()
    {
        $categories = Category::all();
        return view('admin.categories', compact('categories'));
    }

    public function products()
    {
        $products = Product::with('category')->latest()->get();
        return view('admin.products', compact('products'));
    }

    public function toggleStatus(Product $product)
    {
        $product->update([
            'is_available' => !$product->is_available
        ]);
        return back()->with('success', 'Product status updated!');
    }

    public function orders(Request $request)
    {
        $status = $request->get('status');
        $query = Order::with('items.product')->latest();

        if ($status && $status !== 'semua') {
            $query->where('status', $status);
        }

        $orders = $query->get();

        if ($request->expectsJson()) {
            return response()->json($orders);
        }

        return view('admin.orders', compact('orders'));
    }

    public function updateOrderStatus(Order $order, Request $request)
    {
        $request->validate([
            'status' => 'required|in:pending,processing,completed,cancelled'
        ]);

        $order->update([
            'status' => $request->status
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Status pesanan berhasil diperbarui ke ' . $request->status
        ]);
    }
}
