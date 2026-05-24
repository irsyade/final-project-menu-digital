<div class="flex flex-col h-full" wire:poll.5s>
    {{-- Top Section --}}
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-6 mb-8 shrink-0">
        {{-- Status Filter Tabs --}}
        <div class="flex p-1 bg-white border border-slate-200 rounded-2xl shadow-sm overflow-x-auto no-scrollbar">
            @php
                $tabs = [
                    'semua'      => ['label' => 'Semua',     'active' => 'bg-brand text-white shadow-lg shadow-brand/20'],
                    'pending'    => ['label' => 'Pending',   'active' => 'bg-amber-500 text-white shadow-lg shadow-amber-500/20'],
                    'processing' => ['label' => 'Diproses',  'active' => 'bg-blue-500 text-white shadow-lg shadow-blue-500/20'],
                    'completed'  => ['label' => 'Selesai',   'active' => 'bg-emerald-500 text-white shadow-lg shadow-emerald-500/20'],
                    'cancelled'  => ['label' => 'Batal',     'active' => 'bg-red-500 text-white shadow-lg shadow-red-500/20'],
                ];
            @endphp
            @foreach($tabs as $status => $tab)
            <button
                wire:click="$set('filterStatus', '{{ $status }}')"
                class="px-5 py-2.5 rounded-xl text-xs font-black uppercase tracking-widest transition shrink-0 {{ $filterStatus === $status ? $tab['active'] : 'text-slate-500 hover:text-brand' }}">
                {{ $tab['label'] }}
            </button>
            @endforeach
        </div>

        {{-- Search --}}
        <div class="relative group w-full md:w-80">
            <input
                type="text"
                wire:model.live="search"
                placeholder="Cari nomor/nama pesanan..."
                class="w-full pl-12 pr-6 py-3.5 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand focus:border-brand transition outline-none text-sm font-medium shadow-sm">
            <i data-lucide="search" class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 group-focus-within:text-brand transition"></i>
        </div>
    </div>

    {{-- Loading bar --}}
    <div wire:loading class="h-1 bg-brand/20 rounded-full mb-4 shrink-0 overflow-hidden">
        <div class="h-full bg-brand rounded-full animate-pulse w-1/2"></div>
    </div>

    {{-- Orders Table --}}
    <div class="flex-1 overflow-y-auto custom-scrollbar">
        <div class="bg-white rounded-[2.5rem] border border-slate-200 shadow-sm overflow-hidden">
            <table class="w-full text-left">
                <thead>
                    <tr class="bg-slate-50/50">
                        <th class="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">No.Pesanan</th>
                        <th class="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Pelanggan / Meja</th>
                        <th class="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Items</th>
                        <th class="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Total</th>
                        <th class="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">Status</th>
                        <th class="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-widest text-right">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                    @forelse($orders as $order)
                    @php
                        $statusColors = [
                            'pending'    => 'bg-amber-100 text-amber-700',
                            'processing' => 'bg-blue-100 text-blue-700',
                            'completed'  => 'bg-emerald-100 text-emerald-700',
                            'cancelled'  => 'bg-red-100 text-red-700',
                        ];
                        $badgeClass = $statusColors[$order->status] ?? 'bg-slate-100 text-slate-600';
                    @endphp
                    <tr class="hover:bg-slate-50/50 transition group">
                        <td class="px-6 py-5">
                            <span class="font-black text-sm text-slate-900">#ORD-{{ str_pad($order->id, 3, '0', STR_PAD_LEFT) }}</span>
                        </td>
                        <td class="px-6 py-5">
                            <div>
                                <p class="font-bold text-sm text-slate-900">{{ $order->customer_name ?? $order->name ?? '-' }}</p>
                                <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest mt-0.5">{{ $order->table?->name ?? 'Meja -' }}</p>
                            </div>
                        </td>
                        <td class="px-6 py-5">
                            <span class="text-sm text-slate-500 line-clamp-1 max-w-[200px]">
                                {{ $order->items->map(fn($i) => $i->quantity . 'x ' . ($i->product->name ?? '?'))->join(', ') }}
                            </span>
                        </td>
                        <td class="px-6 py-5">
                            <span class="font-black text-slate-900">Rp {{ number_format($order->total_price, 0, ',', '.') }}</span>
                        </td>
                        <td class="px-6 py-5 text-center">
                            <span class="px-3 py-1 text-[10px] font-black uppercase rounded-lg {{ $badgeClass }}">{{ $order->status }}</span>
                        </td>
                        <td class="px-6 py-5 text-right">
                            <select
                                onchange="@this.call('updateStatus', {{ $order->id }}, this.value)"
                                class="px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-700 outline-none focus:ring-2 focus:ring-brand transition cursor-pointer">
                                <option value="pending"    {{ $order->status === 'pending'    ? 'selected' : '' }}>Pending</option>
                                <option value="processing" {{ $order->status === 'processing' ? 'selected' : '' }}>Diproses</option>
                                <option value="completed"  {{ $order->status === 'completed'  ? 'selected' : '' }}>Selesai</option>
                                <option value="cancelled"  {{ $order->status === 'cancelled'  ? 'selected' : '' }}>Batal</option>
                            </select>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="6" class="px-8 py-20 text-center">
                            <div class="flex flex-col items-center text-slate-200">
                                <i data-lucide="package-search" class="w-12 h-12 mb-3"></i>
                                <p class="font-black uppercase tracking-widest text-[10px]">Tidak ada pesanan ditemukan</p>
                            </div>
                        </td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    {{-- Pagination --}}
    <div class="mt-6 shrink-0">
        {{ $orders->links() }}
    </div>

    <style>
        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
    </style>
</div>
