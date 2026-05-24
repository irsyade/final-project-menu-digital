<?php

namespace App\Livewire\Admin;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Table;
use Illuminate\Support\Facades\DB;
use Livewire\Component;

class Dashboard extends Component
{
    public string $chartFilter = 'daily';
    public array $stats = [];
    public array $labels = [];
    public array $salesValues = [];
    public $recentOrders;
    public $topProducts;

    public function mount(): void
    {
        $this->loadStats();
        $this->loadChartData();
        $this->loadRecentOrders();
        $this->loadTopProducts();
    }

    public function setChartFilter(string $filter): void
    {
        $this->chartFilter = $filter;
        $this->loadChartData();
        $this->dispatch('chartUpdated', labels: $this->labels, values: $this->salesValues);
    }

    public function refresh(): void
    {
        $this->loadStats();
        $this->loadChartData();
        $this->loadRecentOrders();
        $this->loadTopProducts();
        $this->dispatch('chartUpdated', labels: $this->labels, values: $this->salesValues);
    }

    private function loadStats(): void
    {
        $popularProduct = OrderItem::select('product_id', DB::raw('SUM(quantity) as total'))
            ->groupBy('product_id')
            ->orderByDesc('total')
            ->with('product')
            ->first()?->product?->name ?? '-';

        $this->stats = [
            'totalOrdersToday' => Order::whereDate('created_at', now()->today())->count(),
            'totalIncomeToday' => Order::whereDate('created_at', now()->today())->sum('total_price'),
            'popularProduct'   => $popularProduct,
            'activeTables'     => Table::where('status', 'occupied')->count(),
            'totalTables'      => Table::count() ?: 15,
        ];
    }

    private function loadChartData(): void
    {
        $this->labels = [];
        $this->salesValues = [];

        if ($this->chartFilter === 'weekly') {
            for ($i = 3; $i >= 0; $i--) {
                $start = now()->subWeeks($i)->startOfWeek();
                $end   = now()->subWeeks($i)->endOfWeek();
                $this->labels[]      = 'Pekan ' . (4 - $i);
                $this->salesValues[] = Order::whereBetween('created_at', [$start, $end])->sum('total_price');
            }
        } elseif ($this->chartFilter === 'monthly') {
            for ($i = 11; $i >= 0; $i--) {
                $date = now()->subMonths($i);
                $this->labels[]      = $date->isoFormat('MMM');
                $this->salesValues[] = Order::whereYear('created_at', $date->year)
                    ->whereMonth('created_at', $date->month)
                    ->sum('total_price');
            }
        } else {
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
                $this->labels[]      = now()->subDays($i)->isoFormat('ddd');
                $this->salesValues[] = $chartData[$date] ?? 0;
            }
        }
    }

    private function loadRecentOrders(): void
    {
        $this->recentOrders = Order::with('items.product')->latest()->take(5)->get();
    }

    private function loadTopProducts(): void
    {
        $this->topProducts = OrderItem::select('product_id', DB::raw('SUM(quantity) as total_sold'))
            ->groupBy('product_id')
            ->orderByDesc('total_sold')
            ->with('product')
            ->take(5)
            ->get();
    }

    public function render()
    {
        return view('livewire.admin.dashboard');
    }
}
