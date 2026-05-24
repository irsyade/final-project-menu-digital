<?php

namespace App\Http\Controllers;

use App\Models\Order;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        $period = (string) $request->get('period', 'day');
        $now = Carbon::now();
        $startDate = $now->copy()->startOfDay();
        $endDate = $now->copy()->endOfDay();
        $divisor = 1;

        if ($period === 'day') {
            $startDate = $now->copy()->startOfDay();
            $divisor = 1;
        } elseif ($period === 'week') {
            $startDate = $now->copy()->subDays(6)->startOfDay();
            $divisor = 7;
        } elseif ($period === 'month') {
            $startDate = $now->copy()->startOfMonth();
            $divisor = $now->day;
        } elseif ($period === 'custom') {
            $startDate = Carbon::parse($request->get('start_date'))->startOfDay();
            $endDate = Carbon::parse($request->get('end_date'))->endOfDay();
            $divisor = $startDate->diffInDays($endDate) + 1;
        }

        $query = Order::where('status', 'completed')->whereBetween('created_at', [$startDate, $endDate]);
        
        $totalRevenue = (float) $query->sum('total_price');
        $totalOrders = $query->count();
        $averagePerDay = $divisor > 0 ? $totalRevenue / $divisor : 0;

        // Chart Data
        $labels = [];
        $data = [];

        if ($period === 'day') {
            $salesData = Order::where('status', 'completed')
                ->whereBetween('created_at', [$startDate, $endDate])
                ->select(DB::raw('HOUR(created_at) as hour_key'), DB::raw('SUM(total_price) as total'))
                ->groupBy('hour_key')
                ->pluck('total', 'hour_key')->toArray();
            
            for ($i = 0; $i <= 23; $i++) {
                $labels[] = str_pad($i, 2, '0', STR_PAD_LEFT) . ':00';
                // Force key to be integer or string matching database return
                $data[] = (float) ($salesData[$i] ?? ($salesData[(string)$i] ?? 0));
            }
        } else {
            // week, month, custom
            $salesData = Order::where('status', 'completed')
                ->whereBetween('created_at', [$startDate, $endDate])
                ->select(DB::raw('DATE_FORMAT(created_at, "%Y-%m-%d") as date_key'), DB::raw('SUM(total_price) as total'))
                ->groupBy('date_key')
                ->pluck('total', 'date_key')->toArray();
            
            $diffInDays = $startDate->diffInDays($endDate);
            for ($i = 0; $i <= $diffInDays; $i++) {
                $date = $startDate->copy()->addDays($i);
                
                if ($period === 'week') {
                    $labels[] = $date->translatedFormat('D');
                } else {
                    $labels[] = $date->format('d/m');
                }
                
                $dateStr = $date->format('Y-m-d');
                $data[] = (float) ($salesData[$dateStr] ?? 0);
            }
        }
        $topMenus = DB::table('order_items')
            ->join('orders', 'order_items.order_id', '=', 'orders.id')
            ->join('products', 'order_items.product_id', '=', 'products.id')
            ->where('orders.status', 'completed')
            ->whereBetween('orders.created_at', [$startDate, $endDate])
            ->select('products.name', DB::raw('SUM(order_items.quantity) as total_qty'),
             DB::raw('SUM(order_items.price * order_items.quantity) as total_revenue'))
            ->groupBy('products.id', 'products.name')
            ->orderByDesc('total_qty')
            ->take(5)->get();
        $reportData = [
            'totalRevenue' => $totalRevenue,
            'totalOrders' => $totalOrders,
            'averagePerDay' => $averagePerDay,
            'topMenuName' => $topMenus->first()->name ?? '-',
            'chartLabels' => $labels,
            'chartData' => $data,
            'topMenus' => $topMenus->map(function($m) {
                return [
                    'name' => $m->name,
                    'qty' => (int) $m->total_qty,
                    'revenue' => (float) $m->total_revenue
                ];
            })
        ];

        if ($request->expectsJson()) {
            return response()->json($reportData);
        }

        return view('admin.reports.index', compact('reportData', 'period'));
    }

    public function exportCsv(Request $request)
    {
        $period = $request->get('period', 'day');
        $now = Carbon::now();
        $startDate = $now->copy();
        $endDate = $now->copy()->endOfDay();

        if ($period == 'day') $startDate = $now->copy()->startOfDay();
        elseif ($period == 'week') $startDate = $now->copy()->subDays(6)->startOfDay();
        elseif ($period == 'custom') {
            $startDate = Carbon::parse($request->get('start_date'))->startOfDay();
            $endDate = Carbon::parse($request->get('end_date'))->endOfDay();
        }
        else $startDate = $now->copy()->startOfMonth();

        $orders = Order::where('status', 'completed')->whereBetween('created_at', [$startDate, $endDate])->latest()->get();

        $headers = [
            "Content-type"        => "text/csv",
            "Content-Disposition" => "attachment; filename=laporan-penjualan-$period.csv",
            "Pragma"              => "no-cache",
            "Cache-Control"       => "must-revalidate, post-check=0, pre-check=0",
            "Expires"             => "0"
        ];

        $columns = ['ID Pesanan', 'Tanggal', 'Nama Pelanggan', 'Status', 'Total Pendapatan'];

        $callback = function() use($orders, $columns) {
            $file = fopen('php://output', 'w');
            fputcsv($file, $columns);

            foreach ($orders as $order) {
                fputcsv($file, [
                    $order->id,
                    $order->created_at->format('Y-m-d H:i'),
                    $order->name ?? 'Pelanggan',
                    $order->status,
                    $order->total_price
                ]);
            }
            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }

    public function exportPdf(Request $request)
    {
        $period = $request->get('period', 'day');
        $now = Carbon::now();
        $startDate = $now->copy();
        $endDate = $now->copy()->endOfDay();

        if ($period == 'day') $startDate = $now->copy()->startOfDay();
        elseif ($period == 'week') $startDate = $now->copy()->subDays(6)->startOfDay();
        elseif ($period == 'custom') {
            $startDate = Carbon::parse($request->get('start_date'))->startOfDay();
            $endDate = Carbon::parse($request->get('end_date'))->endOfDay();
        }
        else $startDate = $now->copy()->startOfMonth();

        $orders = Order::where('status', 'completed')->whereBetween('created_at', [$startDate, $endDate])->latest()->get();
        $totalRevenue = $orders->sum('total_price');

        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('admin.reports.pdf', compact('orders', 'totalRevenue', 'period', 'startDate', 'endDate'));
        return $pdf->download("laporan-penjualan-$period.pdf");
    }
}
