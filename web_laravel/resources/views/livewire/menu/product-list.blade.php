<div class="space-y-6" x-data="{
    products: {{ json_encode($products) }},
    search: '',
    activeCategory: '',
    activeCuisine: '',
    noMatches: false,
    selectedProduct: null,
    showDetail: false,
    init() {
        this.$watch('search', () => this.checkMatches());
        this.$watch('activeCategory', () => this.checkMatches());
        this.$watch('activeCuisine', () => this.checkMatches());
    },
    checkMatches() {
        const searchLower = this.search.toLowerCase();
        const filtered = this.products.filter(p => {
            const matchesSearch = p.name.toLowerCase().includes(searchLower);
            const matchesCategory = this.activeCategory === '' || p.category_id == this.activeCategory;
            const matchesCuisine = this.activeCuisine === '' || (p.cuisine && p.cuisine === this.activeCuisine);
            return matchesSearch && matchesCategory && matchesCuisine;
        });
        this.noMatches = filtered.length === 0;
    },
    matchesFilter(id) {
        const product = this.products.find(p => p.id === id);
        if (!product) return false;
        const searchLower = this.search.toLowerCase();
        const matchesSearch = product.name.toLowerCase().includes(searchLower);
        const matchesCategory = this.activeCategory === '' || product.category_id == this.activeCategory;
        const matchesCuisine = this.activeCuisine === '' || product.cuisine === this.activeCuisine;
        return matchesSearch && matchesCategory && matchesCuisine;
    },
    openProductDetail(id) {
        this.selectedProduct = this.products.find(p => p.id === id);
        this.showDetail = true;
    },
    getProductImageUrl(product) {
        if (!product) return '';
        if (!product.image) return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600';
        if (product.image.startsWith('http')) return product.image;
        return '{{ asset('storage') }}/' + product.image;
    },
    formatPrice(price) {
        if (!price) return '';
        return 'Rp ' + Number(price).toLocaleString('id-ID');
    }
}">
    {{-- Search Bar --}}
    <div class="px-4">
        <div class="relative">
            <input
                type="text"
                x-model="search"
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
                @click="activeCategory = ''"
                class="px-5 py-3 rounded-2xl text-xs font-black uppercase tracking-wider transition shrink-0 border"
                :class="activeCategory === '' ? 'bg-brand text-white border-brand shadow-lg shadow-brand/20' : 'bg-slate-50 text-slate-600 border-slate-100 hover:bg-slate-100'">
                Semua
            </button>
            @foreach($categories as $category)
            <button
                @click="activeCategory = activeCategory === '{{ $category->id }}' ? '' : '{{ $category->id }}'"
                class="px-5 py-3 rounded-2xl text-xs font-black uppercase tracking-wider transition shrink-0 border flex items-center gap-2"
                :class="activeCategory == '{{ $category->id }}' ? 'bg-brand text-white border-brand shadow-lg shadow-brand/20' : 'bg-slate-50 text-slate-600 border-slate-100 hover:bg-slate-100'">
                <span>{{ $category->name }}</span>
                <span class="text-[9px] px-1.5 py-0.5 rounded-full"
                      :class="activeCategory == '{{ $category->id }}' ? 'bg-white/20 text-white' : 'bg-slate-200/60 text-slate-500'">{{ $category->products_count }}</span>
            </button>
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
                @click="activeCuisine = ''"
                class="px-4 py-2.5 rounded-xl text-xs font-bold transition shrink-0 border"
                :class="activeCuisine === '' ? 'bg-slate-900 text-white border-slate-900 shadow-md' : 'bg-slate-50 text-slate-500 border-slate-100'">
                Semua Asal
            </button>
            @foreach($cuisines as $c)
            <button
                @click="activeCuisine = activeCuisine === '{{ $c }}' ? '' : '{{ $c }}'"
                class="px-4 py-2.5 rounded-xl text-xs font-bold transition shrink-0 border"
                :class="activeCuisine === '{{ $c }}' ? 'bg-slate-900 text-white border-slate-900 shadow-md' : 'bg-slate-50 text-slate-500 border-slate-100'">
                {{ $c }}
            </button>
            @endforeach
        </div>
    </div>
    @endif

    {{-- Products Grid --}}
    <div class="px-4 pb-12">
        <div class="grid grid-cols-2 gap-4">
            @foreach($products as $product)
            <div class="bg-white rounded-[2rem] border border-slate-100 shadow-sm p-3 flex flex-col justify-between group active:scale-95 transition-all duration-300 relative cursor-pointer"
                 x-show="matchesFilter({{ $product->id }})"
                 x-transition
                 @click="openProductDetail({{ $product->id }})">
                
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
                            @click.stop="$wire.addToCart({{ $product->id }})"
                            class="w-8 h-8 bg-brand hover:opacity-90 text-white rounded-xl flex items-center justify-center shadow-lg shadow-brand/20 transition active:scale-90 shrink-0">
                            <i data-lucide="plus" class="w-4 h-4"></i>
                        </button>
                    </div>
                </div>
            </div>
            @endforeach

            <div x-show="noMatches" class="col-span-full flex flex-col items-center justify-center py-20 text-slate-200" style="display: none;">
                <div class="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mb-3">
                    <i data-lucide="utensils" class="w-8 h-8 text-slate-350"></i>
                </div>
                <p class="font-black uppercase tracking-widest text-[9px] text-slate-400">Tidak ada menu yang sesuai</p>
            </div>
        </div>
    </div>

    {{-- Bottom Sheet Detail Produk --}}
    <div x-show="showDetail" 
         class="fixed inset-0 z-[100] flex items-end justify-center" 
         style="display: none;">
        
        {{-- Backdrop overlay --}}
        <div x-show="showDetail"
             x-transition:enter="transition ease-out duration-300"
             x-transition:enter-start="opacity-0"
             x-transition:enter-end="opacity-100"
             x-transition:leave="transition ease-in duration-200"
             x-transition:leave-start="opacity-100"
             x-transition:leave-end="opacity-0"
             @click="showDetail = false"
             class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm"></div>

        {{-- Slide up Sheet content --}}
        <div x-show="showDetail"
             x-transition:enter="transition ease-out duration-400"
             x-transition:enter-start="translate-y-full"
             x-transition:enter-end="translate-y-0"
             x-transition:leave="transition ease-in duration-300"
             x-transition:leave-start="translate-y-0"
             x-transition:leave-end="translate-y-full"
             class="relative w-full max-w-[430px] bg-white rounded-t-[2.5rem] shadow-2xl z-10 flex flex-col max-h-[90vh] overflow-hidden border-t border-slate-100">
            
            {{-- Pull handle bar --}}
            <div class="py-3 shrink-0" @click="showDetail = false">
                <div class="w-12 h-1.5 bg-slate-200 rounded-full mx-auto cursor-pointer hover:bg-slate-300 transition"></div>
            </div>

            {{-- Scrollable detail content --}}
            <div class="flex-1 overflow-y-auto pb-8 px-6 space-y-6">
                {{-- Product Large Image --}}
                <div class="w-full aspect-[4/3] rounded-[2rem] bg-slate-50 overflow-hidden relative border border-slate-100 shadow-inner">
                    <img :src="getProductImageUrl(selectedProduct)"
                         class="w-full h-full object-cover" :alt="selectedProduct ? selectedProduct.name : ''">
                    
                    {{-- Popular Badge --}}
                    <div x-show="selectedProduct && selectedProduct.is_popular" 
                         class="absolute top-4 right-4 bg-amber-400 text-slate-950 px-3 py-1 rounded-xl font-black text-[10px] flex items-center gap-1 shadow-md">
                        ⭐ Populer
                    </div>

                    {{-- Discount Badge --}}
                    <div x-show="selectedProduct && selectedProduct.discount_percentage > 0" 
                         class="absolute top-4 left-4 bg-rose-500 text-white px-3 py-1 rounded-xl font-black text-[10px] shadow-md">
                         <span x-text="selectedProduct ? '-' + selectedProduct.discount_percentage + '%' : ''"></span>
                    </div>
                </div>

                {{-- Product Headers --}}
                <div class="space-y-2">
                    <div class="flex flex-wrap gap-2 items-center">
                        {{-- Cuisine / Origin Badge --}}
                        <div x-show="selectedProduct && selectedProduct.cuisine">
                            <span class="px-2.5 py-1 bg-slate-900 text-white text-[9px] font-black uppercase tracking-wider rounded-lg" x-text="selectedProduct ? selectedProduct.cuisine : ''"></span>
                        </div>
                        {{-- Category Badge --}}
                        <div x-show="selectedProduct && selectedProduct.category">
                            <span class="px-2.5 py-1 bg-brand/10 text-brand text-[9px] font-black uppercase tracking-wider rounded-lg" x-text="selectedProduct && selectedProduct.category ? selectedProduct.category.name : ''"></span>
                        </div>
                        {{-- Standard Portion Badge --}}
                        <div>
                            <span class="px-2.5 py-1 bg-slate-100 text-slate-500 text-[9px] font-bold rounded-lg flex items-center gap-1">
                                <i data-lucide="utensils" class="w-3 h-3"></i>
                                Porsi Standar
                            </span>
                        </div>
                    </div>

                    <h2 class="text-xl font-black text-slate-900 tracking-tight leading-snug" x-text="selectedProduct ? selectedProduct.name : ''"></h2>

                    {{-- Price Display --}}
                    <div class="flex items-baseline gap-2 mt-1">
                        <template x-if="selectedProduct && selectedProduct.discount_percentage > 0">
                            <div class="flex items-baseline gap-2">
                                <span class="font-black text-brand text-lg" x-text="formatPrice(selectedProduct.price * (1 - selectedProduct.discount_percentage / 100))"></span>
                                <span class="text-xs font-bold text-slate-400 line-through" x-text="formatPrice(selectedProduct.price)"></span>
                            </div>
                        </template>
                        <template x-if="selectedProduct && !selectedProduct.discount_percentage">
                            <span class="font-black text-brand text-lg" x-text="formatPrice(selectedProduct.price)"></span>
                        </template>
                    </div>
                </div>

                {{-- Tags --}}
                <div x-show="selectedProduct && selectedProduct.tags && selectedProduct.tags.length > 0" class="space-y-2">
                    <h4 class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Tag Menu</h4>
                    <div class="flex flex-wrap gap-1.5">
                        <template x-for="tag in (selectedProduct ? (selectedProduct.tags || []) : [])">
                            <span class="px-2.5 py-1 bg-slate-50 text-slate-500 text-[9px] font-bold rounded-lg border border-slate-100" x-text="tag"></span>
                        </template>
                    </div>
                </div>

                {{-- Description --}}
                <div class="space-y-2">
                    <h4 class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Deskripsi Lengkap</h4>
                    <p class="text-slate-500 text-xs leading-relaxed font-medium" x-text="selectedProduct && selectedProduct.description ? selectedProduct.description : 'Tidak ada deskripsi untuk menu ini.'"></p>
                </div>
            </div>

            {{-- Bottom Action Button --}}
            <div class="p-4 bg-white border-t border-slate-100 shrink-0">
                <button @click="$wire.addToCart(selectedProduct.id); showDetail = false" 
                        class="w-full py-4 bg-brand hover:opacity-95 text-white rounded-2xl font-black text-xs tracking-widest uppercase shadow-xl shadow-brand/20 active:scale-95 transition flex items-center justify-center gap-2">
                    <i data-lucide="shopping-bag" class="w-4 h-4"></i>
                    <span>Tambah ke Keranjang</span>
                </button>
            </div>
        </div>
    </div>
</div>
