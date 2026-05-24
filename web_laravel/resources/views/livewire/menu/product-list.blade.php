<div class="space-y-6">
    {{-- Search Bar --}}
    <div class="px-4">
        <div class="relative">
            <input
                type="text"
                wire:model.live.debounce.300ms="search"
                placeholder="Cari menu favoritmu..."
                class="w-full bg-slate-50 border border-slate-100 rounded-3xl py-4 pl-12 pr-6 text-sm font-medium shadow-sm outline-none focus:ring-2 focus:ring-brand focus:bg-white transition">
            <i data-lucide="search" class="absolute left-5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400"></i>
        </div>
    </div>

    {{-- Category Pills --}}
    <div class="space-y-2">
        <div class="px-4 flex items-center justify-between">
            <h3 class="text-xs font-black text-slate-450 uppercase tracking-widest">Kategori</h3>
        </div>
        <div class="flex gap-2 overflow-x-auto no-scrollbar px-4 pb-2">
            <button
                wire:click="selectCategory('')"
                class="px-5 py-3 rounded-2xl text-xs font-black uppercase tracking-wider transition shrink-0 border {{ $activeCategory === '' ? 'bg-brand text-white border-brand shadow-lg shadow-brand/20' : 'bg-slate-50 text-slate-600 border-slate-100 hover:bg-slate-100' }}">
                Semua
            </button>
            @foreach($categories as $category)
            @if($category->products_count > 0)
            <button
                wire:click="selectCategory('{{ $category->id }}')"
                class="px-5 py-3 rounded-2xl text-xs font-black uppercase tracking-wider transition shrink-0 border flex items-center gap-2 {{ $activeCategory == $category->id ? 'bg-brand text-white border-brand shadow-lg shadow-brand/20' : 'bg-slate-50 text-slate-600 border-slate-100 hover:bg-slate-100' }}">
                <span>{{ $category->name }}</span>
                <span class="text-[9px] px-1.5 py-0.5 rounded-full {{ $activeCategory == $category->id ? 'bg-white/20 text-white' : 'bg-slate-200/60 text-slate-500' }}">{{ $category->products_count }}</span>
            </button>
            @endif
            @endforeach
        </div>
    </div>

    {{-- Cuisine / Origin Pills --}}
    @if(count($cuisines) > 0)
    <div class="space-y-2">
        <div class="px-4 flex items-center justify-between">
            <h3 class="text-xs font-black text-slate-450 uppercase tracking-widest">Daerah / Asal</h3>
        </div>
        <div class="flex gap-2 overflow-x-auto no-scrollbar px-4 pb-2">
            <button
                wire:click="selectCuisine('')"
                class="px-4 py-2.5 rounded-xl text-xs font-bold transition shrink-0 border {{ $activeCuisine === '' ? 'bg-slate-900 text-white border-slate-900 shadow-md' : 'bg-slate-50 text-slate-500 border-slate-100' }}">
                Semua Asal
            </button>
            @foreach($cuisines as $c)
            <button
                wire:click="selectCuisine('{{ $c }}')"
                class="px-4 py-2.5 rounded-xl text-xs font-bold transition shrink-0 border {{ $activeCuisine === $c ? 'bg-slate-900 text-white border-slate-900 shadow-md' : 'bg-slate-50 text-slate-500 border-slate-100' }}">
                {{ $c }}
            </button>
            @endforeach
        </div>
    </div>
    @endif

    {{-- Products Grid --}}
    <div class="px-4">
        <div class="grid grid-cols-2 gap-4">
            @forelse($products as $product)
            <div class="bg-white rounded-[2rem] border border-slate-100 shadow-sm p-3 flex flex-col justify-between group active:scale-95 transition-all duration-300 relative">
                
                {{-- Product Image & Badges --}}
                <div class="w-full aspect-square rounded-[1.5rem] bg-slate-50 overflow-hidden relative border border-slate-50">
                    <img src="{{ $product->image ? (str_starts_with($product->image, 'http') ? $product->image : asset('storage/' . $product->image)) : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300' }}"
                        class="w-full h-full object-cover group-hover:scale-105 transition duration-500" alt="{{ $product->name }}">

                    {{-- Discount Badge --}}
                    @if($product->discount_percentage > 0)
                    <div class="absolute top-2 left-2 bg-rose-500 text-white px-2 py-0.5 rounded-lg font-black text-[8px] shadow-sm">
                        -{{ $product->discount_percentage }}%
                    </div>
                    @endif

                    {{-- Popular Badge --}}
                    @if($product->is_popular)
                    <div class="absolute top-2 right-2 bg-amber-400 text-slate-950 px-2 py-0.5 rounded-lg font-black text-[8px] flex items-center gap-0.5 shadow-sm">
                        ⭐ Populer
                    </div>
                    @endif

                    {{-- Cuisine Badge --}}
                    @if($product->cuisine)
                    <div class="absolute bottom-2 left-2">
                        <span class="px-2 py-0.5 bg-black/60 backdrop-blur text-white text-[7px] font-black uppercase rounded tracking-wider shadow-sm">{{ $product->cuisine }}</span>
                    </div>
                    @endif
                </div>

                {{-- Product Content --}}
                <div class="mt-3 flex-1 flex flex-col justify-between">
                    <div>
                        <h4 class="font-black text-slate-900 text-xs mb-1 line-clamp-2 leading-tight">{{ $product->name }}</h4>
                        
                        {{-- Tags --}}
                        @if($product->tags && count($product->tags) > 0)
                        <div class="flex flex-wrap gap-1 mb-2">
                            @foreach(array_slice($product->tags, 0, 2) as $tag)
                            <span class="px-1.5 py-0.5 bg-slate-50 text-slate-400 text-[7px] font-bold rounded">{{ $tag }}</span>
                            @endforeach
                        </div>
                        @endif
                    </div>

                    <div class="flex items-end justify-between mt-3">
                        <div class="flex flex-col">
                            @if($product->discount_percentage > 0)
                            <span class="text-[8px] font-bold text-slate-400 line-through leading-none mb-0.5">Rp {{ number_format($product->price, 0, ',', '.') }}</span>
                            <span class="font-black text-brand text-xs tracking-tight">
                                Rp {{ number_format($product->price * (1 - $product->discount_percentage / 100), 0, ',', '.') }}
                            </span>
                            @else
                            <span class="font-black text-brand text-xs">
                                Rp {{ number_format($product->price, 0, ',', '.') }}
                            </span>
                            @endif
                        </div>

                        {{-- Add to Cart Button --}}
                        <button
                            wire:click="addToCart({{ $product->id }})"
                            class="w-8 h-8 bg-brand hover:opacity-90 text-white rounded-xl flex items-center justify-center shadow-lg shadow-brand/20 transition active:scale-90 shrink-0">
                            <i data-lucide="plus" class="w-4 h-4"></i>
                        </button>
                    </div>
                </div>
            </div>
            @empty
            <div class="col-span-full flex flex-col items-center justify-center py-20 text-slate-200">
                <div class="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mb-3">
                    <i data-lucide="utensils" class="w-8 h-8 text-slate-350"></i>
                </div>
                <p class="font-black uppercase tracking-widest text-[9px] text-slate-400">Tidak ada menu yang sesuai</p>
            </div>
            @endforelse
        </div>
    </div>
</div>
