<div>
<div wire:poll.10s="refresh">
    {{-- Stats Cards Row --}}
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
        {{-- Card 1: Total Orders Today --}}
        <div class="bg-white p-6 rounded-[2rem] border border-slate-200 shadow-sm group hover:shadow-md transition">
            <div class="flex items-center justify-between mb-4">
                <div class="w-10 h-10 bg-brand/10 text-brand rounded-xl flex items-center justify-center">
                    <i data-lucide="shopping-bag" class="w-5 h-5"></i>
                </div>
                <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Hari Ini</span>
            </div>
            <span class="block text-3xl font-black text-slate-900 leading-none mb-1">
                {{ number_format($stats['totalOrdersToday'] ?? 0) }}
            </span>
            <p class="text-xs font-bold text-slate-500">Total Pesanan</p>
        </div>

        {{-- Card 2: Income Today --}}
        <div class="bg-white p-6 rounded-[2rem] border border-slate-200 shadow-sm group hover:shadow-md transition">
            <div class="flex items-center justify-between mb-4">
                <div class="w-10 h-10 bg-emerald-100 text-emerald-600 rounded-xl flex items-center justify-center">
                    <i data-lucide="wallet" class="w-5 h-5"></i>
                </div>
                <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Income</span>
            </div>
            <span class="block text-2xl font-black text-slate-900 leading-none mb-1">
                Rp {{ number_format($stats['totalIncomeToday'] ?? 0, 0, ',', '.') }}
            </span>
            <p class="text-xs font-bold text-slate-500">Pendapatan Hari Ini</p>
        </div>

        {{-- Card 3: Best Selling Product --}}
        <div class="bg-white p-6 rounded-[2rem] border border-slate-200 shadow-sm group hover:shadow-md transition">
            <div class="flex items-center justify-between mb-4">
                <div class="w-10 h-10 bg-blue-100 text-blue-600 rounded-xl flex items-center justify-center">
                    <i data-lucide="heart" class="w-5 h-5"></i>
                </div>
                <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Favorite</span>
            </div>
            <span class="block text-xl font-black text-slate-900 leading-none mb-1 line-clamp-1">
                {{ $stats['popularProduct'] ?? '-' }}
            </span>
            <p class="text-xs font-bold text-slate-500">Menu Terlaris</p>
        </div>

        {{-- Card 4: Table Occupancy --}}
        <div class="bg-white p-6 rounded-[2rem] border border-slate-200 shadow-sm group hover:shadow-md transition">
            <div class="flex items-center justify-between mb-4">
                <div class="w-10 h-10 bg-amber-100 text-amber-600 rounded-xl flex items-center justify-center">
                    <i data-lucide="armchair" class="w-5 h-5"></i>
                </div>
                <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Occupancy</span>
            </div>
            <span class="block text-3xl font-black text-slate-900 leading-none mb-1">
                {{ $stats['activeTables'] ?? 0 }}
                <span class="text-lg text-slate-400 font-medium">/ {{ $stats['totalTables'] ?? 0 }}</span>
            </span>
            <p class="text-xs font-bold text-slate-500">Meja Aktif</p>
        </div>
    </div>

    {{-- Sales Chart --}}
    <div class="bg-white p-8 rounded-[2.5rem] border border-slate-200 shadow-sm mb-10">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
            <div>
                <h3 class="text-xl font-black text-slate-900 tracking-tight">Grafik Penjualan</h3>
                <p class="text-xs text-slate-500 font-bold uppercase tracking-widest mt-1">Pantau tren performa bisnismu</p>
            </div>
            <div class="flex p-1 bg-slate-100 rounded-xl">
                <button
                    wire:click="setChartFilter('daily')"
                    class="px-4 py-2 text-xs font-black rounded-lg transition {{ $chartFilter === 'daily' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-900' }}">
                    Harian
                </button>
                <button
                    wire:click="setChartFilter('weekly')"
                    class="px-4 py-2 text-xs font-bold rounded-lg transition {{ $chartFilter === 'weekly' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-900' }}">
                    Mingguan
                </button>
                <button
                    wire:click="setChartFilter('monthly')"
                    class="px-4 py-2 text-xs font-bold rounded-lg transition {{ $chartFilter === 'monthly' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-900' }}">
                    Bulanan
                </button>
            </div>
        </div>
        <div class="h-[350px] w-full">
            <canvas id="salesChart"></canvas>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-10">
        {{-- Recent Orders (Left Column - 2/3 width) --}}
        <div class="lg:col-span-2 bg-white rounded-[2.5rem] border border-slate-200 shadow-sm overflow-hidden">
            <div class="p-8 border-b border-slate-100 flex items-center justify-between">
                <h3 class="text-xl font-black text-slate-900 tracking-tight">5 Pesanan Terbaru</h3>
                <a href="/admin/orders" class="text-xs font-bold text-brand hover:underline">Lihat Semua</a>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-left">
                    <thead>
                        <tr class="bg-slate-50/50">
                            <th class="px-8 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">No. Pesanan</th>
                            <th class="px-8 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Meja / Nama</th>
                            <th class="px-8 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Items</th>
                            <th class="px-8 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Total</th>
                            <th class="px-8 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">Status</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        @forelse($recentOrders as $order)
                        <tr class="hover:bg-slate-50/50 transition">
                            <td class="px-8 py-4 font-bold text-sm text-slate-900">#ORD-{{ str_pad($order->id, 3, '0', STR_PAD_LEFT) }}</td>
                            <td class="px-8 py-4 text-sm font-medium text-slate-600">{{ $order->name ?? 'Meja -' }}</td>
                            <td class="px-8 py-4 text-sm text-slate-500">
                                <span class="line-clamp-1 max-w-[180px]">
                                    {{ $order->items->map(fn($i) => $i->quantity . 'x ' . ($i->product->name ?? '?'))->join(', ') }}
                                </span>
                            </td>
                            <td class="px-8 py-4 font-black text-slate-900">Rp {{ number_format($order->total_price, 0, ',', '.') }}</td>
                            <td class="px-8 py-4 text-center">
                                @php
                                    $statusColors = [
                                        'pending'    => 'bg-amber-100 text-amber-700',
                                        'processing' => 'bg-blue-100 text-blue-700',
                                        'completed'  => 'bg-emerald-100 text-emerald-700',
                                        'cancelled'  => 'bg-red-100 text-red-700',
                                    ];
                                    $badgeClass = $statusColors[$order->status] ?? 'bg-slate-100 text-slate-700';
                                @endphp
                                <span class="px-3 py-1 text-[10px] font-black uppercase rounded-lg {{ $badgeClass }}">
                                    {{ $order->status }}
                                </span>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="5" class="px-8 py-10 text-center text-slate-400 font-medium">Belum ada pesanan masuk.</td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        {{-- Top Products (Right Column - 1/3 width) --}}
        <div class="bg-white p-8 rounded-[2.5rem] border border-slate-200 shadow-sm">
            <h3 class="text-xl font-black text-slate-900 tracking-tight mb-8">Top 5 Produk Terpopuler</h3>
            <div class="space-y-6">
                @forelse($topProducts as $index => $item)
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <span class="w-8 h-8 flex items-center justify-center font-black rounded-lg text-sm {{ $index === 0 ? 'text-brand bg-brand/10' : 'text-slate-400 bg-slate-50' }}">
                            {{ $index + 1 }}
                        </span>
                        <span class="font-bold text-sm text-slate-700 line-clamp-1">{{ $item->product->name ?? '-' }}</span>
                    </div>
                    <span class="text-xs font-black text-slate-400 shrink-0">{{ $item->total_sold }} terjual</span>
                </div>
                @empty
                <p class="text-center text-slate-400 text-sm py-10 font-medium">Data belum tersedia.</p>
                @endforelse
            </div>

            @if($topProducts->count() > 0)
            <div class="mt-10 p-5 bg-brand/5 rounded-3xl border border-brand/10">
                <p class="text-xs font-bold text-brand leading-relaxed italic">Tip: Terus pantau menu terlaris untuk optimasi stok bahan baku Anda.</p>
            </div>
            @endif
        </div>
    </div>
</div>

{{-- Loading overlay for Livewire actions --}}
<div wire:loading.flex class="fixed inset-0 z-[999] bg-white/40 backdrop-blur-sm items-center justify-center">
    <div class="w-12 h-12 border-4 border-brand border-t-transparent rounded-full animate-spin"></div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    let salesChart = null;

    // Initial chart data from Livewire component
    const initialLabels = @json($labels);
    const initialValues = @json($salesValues);

    function initChart(labels, values) {
        const canvas = document.getElementById('salesChart');
        if (!canvas) return;

        if (salesChart) {
            salesChart.destroy();
            salesChart = null;
        }

        const ctx = canvas.getContext('2d');
        salesChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Pendapatan (Rp)',
                    data: values,
                    borderColor: '#E8781A',
                    backgroundColor: 'rgba(232, 120, 26, 0.08)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 5,
                    pointBackgroundColor: '#fff',
                    pointBorderColor: '#E8781A',
                    pointBorderWidth: 2,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                let label = context.dataset.label || '';
                                if (label) label += ': ';
                                if (context.parsed.y !== null) {
                                    label += new Intl.NumberFormat('id-ID', {
                                        style: 'currency',
                                        currency: 'IDR',
                                        minimumFractionDigits: 0
                                    }).format(context.parsed.y);
                                }
                                return label;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: 'rgba(0,0,0,0.03)' },
                        ticks: {
                            callback: function(value) {
                                if (value >= 1000000) return 'Rp ' + (value / 1000000).toFixed(1) + 'jt';
                                if (value >= 1000) return 'Rp ' + (value / 1000).toFixed(0) + 'rb';
                                return 'Rp ' + value;
                            },
                            font: { family: 'Outfit', weight: '700', size: 11 }
                        }
                    },
                    x: {
                        grid: { display: false },
                        ticks: { font: { family: 'Outfit', weight: '700', size: 11 } }
                    }
                }
            }
        });
    }

    // Initialize chart on page load
    document.addEventListener('DOMContentLoaded', function () {
        initChart(initialLabels, initialValues);
        lucide.createIcons();
    });

    // Listen for Livewire chart update event
    document.addEventListener('livewire:init', function () {
        Livewire.on('chartUpdated', function (data) {
            initChart(data[0].labels, data[0].salesValues);
            lucide.createIcons();
        });
    });

    // Re-init icons after Livewire morphs DOM
    document.addEventListener('livewire:navigated', function () {
        lucide.createIcons();
    });

    document.addEventListener('livewire:update', function () {
        lucide.createIcons();
    });
</script>
</div>
