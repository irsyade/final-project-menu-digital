@php
    $promos = \App\Models\Promo::where('is_active', true)->orderBy('is_banner', 'desc')->get();
    $popularProducts = \App\Models\Product::where('is_available', true)->where('is_popular', true)->latest()->get();
    $setting = \App\Models\Setting::first() ?? new \App\Models\Setting;
    $restoName = $setting->site_name ?? 'MenuKu';
@endphp

<div class="flex-1 flex flex-col h-full">
    {{-- ===================== SCREEN: MENU (Product Catalogue) ===================== --}}
    @if($activeScreen === 'menu')
    {{-- Header --}}
    <header class="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b border-slate-100 p-4 shrink-0">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-2">
                <div class="w-10 h-10 bg-brand rounded-xl flex items-center justify-center text-white shadow-lg shadow-brand/20">
                    <i data-lucide="utensils" class="w-6 h-6"></i>
                </div>
                <div>
                    <h1 class="font-black text-slate-900 text-sm leading-tight">{{ $restoName }}</h1>
                    <div class="flex items-center gap-1">
                        <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                        <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">
                            {{ $tableName ?: 'Dine In' }}
                        </span>
                    </div>
                </div>
            </div>
            
            {{-- Floating Cart Button in Header --}}
            <button
                wire:click="setScreen('cart')"
                class="relative w-10 h-10 rounded-full bg-white border border-slate-100 flex items-center justify-center text-slate-950 shadow-sm active:scale-90 transition">
                <i data-lucide="shopping-bag" class="w-5 h-5"></i>
                @if($this->cartCount() > 0)
                <div class="absolute -top-1 -right-1 w-5 h-5 bg-brand text-white text-[9px] font-black rounded-full flex items-center justify-center border-2 border-white">
                    {{ $this->cartCount() }}
                </div>
                @endif
            </button>
        </div>
    </header>

    {{-- Main Body Scroll --}}
    <div class="flex-1 overflow-y-auto custom-scrollbar pb-32">
        {{-- Promo Carousel --}}
        @if(count($promos) > 0)
        <section class="mt-6 px-4" 
                 x-data="{ 
                     active: 0, 
                     timer: null, 
                     touchStartX: 0, 
                     touchEndX: 0, 
                     count: {{ count($promos) }},
                     startTimer() {
                         if (this.timer) clearInterval(this.timer);
                         this.timer = setInterval(() => {
                             this.next();
                         }, 3000);
                     },
                     next() {
                         this.active = (this.active + 1) % this.count;
                     },
                     prev() {
                         this.active = (this.active - 1 + this.count) % this.count;
                     },
                     handleTouchStart(e) {
                         this.touchStartX = e.touches[0].clientX;
                     },
                     handleTouchEnd(e) {
                         this.touchEndX = e.changedTouches[0].clientX;
                         const diff = this.touchStartX - this.touchEndX;
                         if (Math.abs(diff) > 50) {
                             if (diff > 0) {
                                 this.next();
                             } else {
                                 this.prev();
                             }
                             this.startTimer();
                         }
                     }
                 }" 
                 x-init="startTimer()">
            <div class="relative overflow-hidden rounded-[2rem] h-52 shadow-xl shadow-brand/10 bg-slate-100"
                 @touchstart="handleTouchStart($event)"
                 @touchend="handleTouchEnd($event)">
                @foreach($promos as $index => $promo)
                @php
                    $gradient = 'linear-gradient(135deg, #FF8C00 0%, #E8781A 100%)';
                    if($promo->promo_type == 'bundling') $gradient = 'linear-gradient(135deg, #1D9E75 0%, #166534 100%)';
                    
                    $imageUrl = $promo->image ? (str_starts_with($promo->image, 'http') ? $promo->image : asset('storage/' . $promo->image)) : null;
                @endphp
                <div x-show="active === {{ $index }}" 
                     x-transition:enter="transition ease-out duration-500"
                     x-transition:enter-start="opacity-0 translate-x-8"
                     x-transition:enter-end="opacity-100 translate-x-0"
                     class="absolute inset-0 text-white flex flex-col justify-between overflow-hidden"
                     style="background: {{ $gradient }}; display: none;">
                    
                    {{-- Full Background Image --}}
                    @if($imageUrl)
                    <img src="{{ $imageUrl }}" class="absolute inset-0 w-full h-full object-cover opacity-60 mix-blend-overlay">
                    <div class="absolute inset-0 bg-gradient-to-r from-black/80 via-black/40 to-transparent"></div>
                    @endif

                    <div class="relative z-10 w-full h-full flex flex-col justify-center p-6 w-3/4">
                        <div class="inline-flex items-center gap-2 mb-2">
                            <span class="px-2 py-0.5 bg-white text-slate-900 rounded-[0.25rem] text-[8px] font-black uppercase tracking-widest shadow-sm">{{ str_replace('_', ' ', $promo->promo_type) }}</span>
                        </div>
                        
                        <h3 class="text-xs font-black uppercase tracking-widest text-white/90 mb-0.5 leading-tight line-clamp-1">{{ $promo->name }}</h3>
                        
                        @if($promo->promo_type == 'diskon')
                            <div class="flex items-baseline gap-1 mb-1">
                                @if($promo->type == 'percentage')
                                <span class="text-4xl font-black tracking-tighter">{{ $promo->value }}%</span>
                                @else
                                <span class="text-sm font-black text-white/80">Rp</span>
                                <span class="text-4xl font-black tracking-tighter">{{ number_format($promo->value/1000, 0) }}k</span>
                                @endif
                            </div>
                            <p class="text-[10px] font-medium text-white/80 line-clamp-2 mb-3 leading-snug">{{ $promo->description }}</p>
                            
                        @elseif($promo->promo_type == 'bundling')
                            <div class="flex items-baseline gap-1 mb-1">
                                <span class="text-sm font-black text-white/80">Rp</span>
                                <span class="text-4xl font-black tracking-tighter">{{ number_format($promo->value/1000, 0) }}k</span>
                            </div>
                            <p class="text-[10px] font-bold text-white mb-3 line-clamp-2 leading-snug"><i data-lucide="package" class="w-3 h-3 inline mr-1"></i>{{ $promo->bundling_items ?? $promo->description }}</p>

                        @endif

                        <div class="mt-1">
                            <span class="px-5 py-2 bg-white/20 backdrop-blur-sm text-white rounded-xl font-black text-[10px] uppercase tracking-widest shadow-sm flex items-center gap-2 w-fit border border-white/30">
                                KODE: {{ $promo->code }}
                            </span>
                        </div>
                    </div>
                </div>
                @endforeach
            </div>
            
            @if(count($promos) > 1)
            <div class="flex justify-center gap-1.5 mt-3">
                @foreach($promos as $index => $promo)
                <button @click="active = {{ $index }}; startTimer()" class="h-1.5 rounded-full transition-all duration-300" :class="active === {{ $index }} ? 'w-5 bg-brand' : 'w-1.5 bg-slate-200'"></button>
                @endforeach
            </div>
            @endif
        </section>
        @endif

        {{-- Popular Products Horizontal Scroller --}}
        @if(count($popularProducts) > 0)
        <section class="mt-8">
            <div class="px-4 flex items-center justify-between mb-4">
                <div class="flex items-center gap-2">
                    <div class="w-7 h-7 bg-amber-400 rounded-xl flex items-center justify-center text-slate-950 shadow-md">
                        <i data-lucide="star" class="w-4 h-4 fill-slate-950"></i>
                    </div>
                    <h3 class="font-black text-slate-900 text-sm">Terpopuler Hari Ini</h3>
                </div>
            </div>
            <div class="flex gap-4 overflow-x-auto no-scrollbar px-4 pb-4">
                @foreach($popularProducts as $product)
                <div class="w-40 shrink-0 bg-white p-3 rounded-[2rem] border border-slate-100 shadow-sm relative group transition active:scale-95">
                    <div class="w-full aspect-square rounded-[1.5rem] bg-slate-50 mb-3 overflow-hidden border border-slate-100 relative">
                        <img src="{{ $product->image ? (str_starts_with($product->image, 'http') ? $product->image : asset('storage/' . $product->image)) : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300' }}" class="w-full h-full object-cover">
                        
                        @if($product->discount_percentage > 0)
                        <div class="absolute top-1.5 right-1.5 bg-rose-500 text-white px-2 py-0.5 rounded-lg font-black text-[8px] shadow-sm">
                            -{{ $product->discount_percentage }}%
                        </div>
                        @endif

                        @if($product->cuisine)
                        <div class="absolute bottom-1.5 left-1.5">
                            <span class="px-1.5 py-0.5 bg-black/60 backdrop-blur text-white text-[7px] font-black uppercase rounded shadow-sm">{{ $product->cuisine }}</span>
                        </div>
                        @endif
                    </div>
                    <h4 class="font-black text-slate-900 text-[11px] mb-1 line-clamp-1 leading-tight">{{ $product->name }}</h4>
                    <div class="flex items-center justify-between mt-2">
                        <div class="flex flex-col">
                            @if($product->discount_percentage > 0)
                            <span class="text-[8px] font-bold text-slate-400 line-through leading-none mb-0.5">Rp {{ number_format($product->price, 0, ',', '.') }}</span>
                            <span class="font-black text-brand text-xs tracking-tight">Rp {{ number_format($product->price * (1 - $product->discount_percentage/100), 0, ',', '.') }}</span>
                            @else
                            <span class="font-black text-brand text-xs">Rp {{ number_format($product->price, 0, ',', '.') }}</span>
                            @endif
                        </div>
                        <button
                            wire:click="addToCart({{ $product->id }})"
                            class="w-7 h-7 bg-brand text-white rounded-lg flex items-center justify-center shadow-md shadow-brand/25 transition active:scale-90">
                            <i data-lucide="plus" class="w-4 h-4"></i>
                        </button>
                    </div>
                </div>
                @endforeach
            </div>
        </section>
        @endif

        {{-- Menu Catalogue Component --}}
        <section class="mt-4">
            <livewire:menu.product-list />
        </section>
    </div>

    {{-- Bottom Floating Checkout Bar --}}
    @if($this->cartCount() > 0)
    <div class="fixed bottom-0 left-0 right-0 max-w-[430px] mx-auto p-4 bg-white/90 backdrop-blur-lg border-t border-slate-100 shadow-[0_-10px_20px_rgba(0,0,0,0.03)] z-40 shrink-0">
        <div class="flex items-center justify-between gap-4">
            <div class="flex flex-col">
                <span class="text-[8px] font-black text-slate-400 uppercase tracking-widest">Total Pesanan</span>
                <span class="text-xs font-bold text-slate-500 leading-none mt-1">{{ $this->cartCount() }} Items</span>
                <span class="text-lg font-black text-brand tracking-tight mt-0.5">Rp {{ number_format($this->subtotal(), 0, ',', '.') }}</span>
            </div>

            <button
                wire:click="setScreen('cart')"
                class="flex-1 py-4 bg-brand text-white rounded-2xl font-black text-sm tracking-widest uppercase shadow-xl shadow-brand/20 flex items-center justify-center gap-2 active:scale-95 transition">
                <span>LIHAT KERANJANG</span>
                <i data-lucide="arrow-right" class="w-4 h-4"></i>
            </button>
        </div>
    </div>
    @endif


    {{-- ===================== SCREEN: CART & CHECKOUT ===================== --}}
    @elseif($activeScreen === 'cart')
    {{-- Header --}}
    <header class="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b border-slate-100 p-4 shrink-0">
        <div class="flex items-center gap-4">
            <button
                wire:click="setScreen('menu')"
                class="w-10 h-10 rounded-full bg-white border border-slate-50 flex items-center justify-center text-slate-450 hover:text-brand shadow-sm active:scale-90 transition">
                <i data-lucide="chevron-left" class="w-5 h-5"></i>
            </button>
            <div>
                <h1 class="font-black text-slate-900 text-base leading-tight">Keranjang Belanja</h1>
                <p class="text-[10px] font-bold text-slate-400 uppercase tracking-widest mt-0.5">Meja: {{ $tableName ?: 'Dine In' }}</p>
            </div>
        </div>
    </header>

    {{-- Main Cart Scroll --}}
    <div class="flex-1 overflow-y-auto custom-scrollbar p-6 space-y-8 pb-32">
        {{-- Empty Cart State --}}
        @if(empty($items) && (!$appliedPromo || $appliedPromo['promo_type'] === 'diskon') && empty($promoMessage))
        <div class="flex flex-col items-center justify-center py-20 text-slate-200">
            <div class="w-20 h-20 bg-slate-55 rounded-full flex items-center justify-center mb-6">
                <i data-lucide="shopping-basket" class="w-10 h-10 text-slate-300"></i>
            </div>
            <h3 class="text-slate-700 font-black text-lg mb-1">Keranjang Kosong</h3>
            <p class="text-slate-400 text-xs text-center max-w-[200px] mb-8 font-medium">Pilih hidangan lezat kami di menu sebelum checkout.</p>
            <button
                wire:click="setScreen('menu')"
                class="px-6 py-3.5 bg-brand text-white font-black text-xs uppercase tracking-widest rounded-2xl shadow-lg shadow-brand/20 active:scale-95 transition">
                KEMBALI KE MENU
            </button>
        </div>
        
        @else
        {{-- Client Details Form --}}
        <div class="bg-slate-50 rounded-[2.5rem] border border-slate-100 p-6 space-y-4">
            <h3 class="text-xs font-black text-slate-500 uppercase tracking-widest px-1">Detail Pelanggan</h3>
            
            <div>
                <label class="block text-[10px] font-bold text-slate-700 mb-1.5 px-1">Nama Anda *</label>
                <input
                    type="text"
                    wire:model.live="customerName"
                    required
                    placeholder="Masukkan nama pemesan..."
                    class="w-full px-5 py-3.5 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-bold text-xs transition">
            </div>

            <div>
                <label class="block text-[10px] font-bold text-slate-700 mb-1.5 px-1">Nomor / Nama Meja</label>
                <input
                    type="text"
                    wire:model="tableName"
                    placeholder="Nomor meja..."
                    class="w-full px-5 py-3.5 bg-slate-100 border border-slate-200 text-slate-500 rounded-2xl outline-none font-bold text-xs cursor-not-allowed"
                    disabled>
            </div>
        </div>

        {{-- Cart Items List --}}
        <div class="space-y-4">
            <h3 class="text-xs font-black text-slate-500 uppercase tracking-widest px-1">Pesanan Anda</h3>
            
            <div class="divide-y divide-slate-100">
                @if($appliedPromo && $appliedPromo['promo_type'] === 'bundling')
                <div class="py-4 flex items-center justify-between gap-4 first:pt-0">
                    <div class="flex items-center gap-3 flex-1 min-w-0">
                        <div class="w-16 h-16 rounded-2xl overflow-hidden bg-blue-50 shrink-0 border border-blue-100 flex items-center justify-center text-blue-500">
                            <i data-lucide="package" class="w-8 h-8"></i>
                        </div>
                        <div class="min-w-0 flex-1">
                            <h4 class="font-black text-slate-900 text-xs line-clamp-1 leading-tight">{{ $appliedPromo['name'] }}</h4>
                            <p class="text-[10px] font-bold text-slate-400 mt-0.5">{{ $appliedPromo['bundling_items'] }}</p>
                            <p class="text-xs font-black text-brand mt-1">Rp {{ number_format($appliedPromo['value'], 0, ',', '.') }}</p>
                        </div>
                    </div>
                </div>
                @endif

                @foreach($cartProducts as $product)
                @php
                    $qty = $items[$product->id] ?? 0;
                    $discountPrice = $product->discount_percentage > 0
                        ? $product->price * (1 - $product->discount_percentage / 100)
                        : $product->price;
                @endphp
                <div class="py-4 flex items-center justify-between gap-4 first:pt-0">
                    {{-- Item Info --}}
                    <div class="flex items-center gap-3 flex-1 min-w-0">
                        <div class="w-16 h-16 rounded-2xl overflow-hidden bg-slate-50 shrink-0 border border-slate-100">
                            <img src="{{ $product->image ? (str_starts_with($product->image, 'http') ? $product->image : asset('storage/' . $product->image)) : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100' }}"
                                class="w-full h-full object-cover">
                        </div>
                        <div class="min-w-0 flex-1">
                            <h4 class="font-black text-slate-900 text-xs line-clamp-1 leading-tight">{{ $product->name }}</h4>
                            <p class="text-xs font-black text-brand mt-1">Rp {{ number_format($discountPrice, 0, ',', '.') }}</p>
                        </div>
                    </div>

                    {{-- Quantity Controls --}}
                    <div class="flex items-center gap-3 shrink-0">
                        <div class="flex items-center bg-slate-50 border border-slate-250/60 rounded-xl p-1 shadow-sm">
                            <button
                                wire:click="updateQty({{ $product->id }}, {{ $qty - 1 }})"
                                class="w-7 h-7 rounded-lg bg-white flex items-center justify-center text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition font-black">
                                -
                            </button>
                            <span class="w-8 text-center text-xs font-black text-slate-800">{{ $qty }}</span>
                            <button
                                wire:click="updateQty({{ $product->id }}, {{ $qty + 1 }})"
                                class="w-7 h-7 rounded-lg bg-white flex items-center justify-center text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition font-black">
                                +
                            </button>
                        </div>

                        <button
                            wire:click="removeItem({{ $product->id }})"
                            class="p-2.5 text-slate-350 hover:text-red-500 rounded-xl bg-slate-50/50 hover:bg-red-50 transition shrink-0 border border-slate-100">
                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                        </button>
                    </div>
                </div>
                @endforeach
            </div>
        </div>

        {{-- Promo Apply Box --}}
        <div class="bg-slate-50 rounded-[2.5rem] border border-slate-100 p-6 space-y-4">
            <h3 class="text-xs font-black text-slate-500 uppercase tracking-widest px-1">Kupon / Promo</h3>
            
            <div class="flex gap-2">
                <input
                    type="text"
                    wire:model="promoCode"
                    placeholder="Masukkan kode kupon..."
                    class="flex-1 px-5 py-3.5 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-bold text-xs uppercase transition">
                <button
                    wire:click="applyPromo()"
                    class="px-5 py-3.5 bg-slate-900 hover:bg-slate-800 text-white rounded-2xl font-black text-xs uppercase tracking-wider transition shrink-0">
                    Terapkan
                </button>
            </div>
            
            @if($promoMessage)
            <div class="px-1 text-[10px] font-bold {{ $promoValid ? 'text-emerald-600' : 'text-red-500' }}">
                {{ $promoMessage }}
            </div>
            @endif
        </div>

        {{-- Bill Breakdown --}}
        <div class="bg-white border border-slate-100 rounded-[2.5rem] p-6 space-y-3">
            <div class="flex justify-between items-center text-xs">
                <span class="text-slate-400 font-medium">Subtotal</span>
                <span class="font-black text-slate-850">Rp {{ number_format($this->subtotal(), 0, ',', '.') }}</span>
            </div>
            
            @if($this->discount() > 0)
            <div class="flex justify-between items-center text-xs">
                <span class="text-slate-400 font-medium">Diskon</span>
                <span class="font-black text-rose-500">- Rp {{ number_format($this->discount(), 0, ',', '.') }}</span>
            </div>
            @endif

            <div class="pt-3 border-t border-slate-100 flex justify-between items-center">
                <span class="text-xs font-black text-slate-900">Total Pembayaran</span>
                <span class="text-xl font-black text-brand tracking-tight">Rp {{ number_format($this->grandTotal(), 0, ',', '.') }}</span>
            </div>
        </div>
        @endif
    </div>

    {{-- Bottom Submit Checkout Bar --}}
    @if(!empty($items) || ($appliedPromo && $appliedPromo['promo_type'] !== 'diskon'))
    <div class="fixed bottom-0 left-0 right-0 max-w-[430px] mx-auto p-4 bg-white border-t border-slate-100 shadow-[0_-10px_20px_rgba(0,0,0,0.03)] z-40 shrink-0">
        <button
            wire:click="placeOrder()"
            @if(empty($customerName)) disabled @endif
            class="w-full py-5 bg-brand disabled:opacity-40 disabled:cursor-not-allowed text-white rounded-2xl font-black text-sm tracking-widest uppercase shadow-xl shadow-brand/20 active:scale-95 transition flex items-center justify-center">
            <span wire:loading.remove wire:target="placeOrder">KIRIM PESANAN</span>
            <span wire:loading wire:target="placeOrder">
                <span class="flex items-center justify-center gap-2">
                    <svg class="animate-spin w-4 h-4 text-white" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path></svg>
                    <span>Memproses...</span>
                </span>
            </span>
        </button>
    </div>
    @endif


    {{-- ===================== SCREEN: STATUS (Order Placed) ===================== --}}
    @elseif($activeScreen === 'status' && $lastOrder)
    <div class="flex-1 flex flex-col items-center justify-center p-6 space-y-8 pb-20"
         wire:poll.5000ms="pollOrderStatus">

        {{-- Live Order Status Notification Alert --}}
        @if($orderNotification)
        <div wire:key="notif-{{ $orderStatus }}"
             class="w-full rounded-2xl px-5 py-4 flex items-start gap-4 transition-all duration-500 shadow-lg
                    @if($notificationLevel === 'info') bg-blue-50 border border-blue-200
                    @elseif($notificationLevel === 'warning') bg-amber-50 border border-amber-300
                    @elseif($notificationLevel === 'success') bg-emerald-50 border border-emerald-300
                    @elseif($notificationLevel === 'error') bg-red-50 border border-red-200
                    @else bg-slate-50 border border-slate-200 @endif"
             style="animation: slideDown 0.4s ease-out;">

            {{-- Icon dot --}}
            <span class="mt-0.5 flex-shrink-0 relative">
                <span class="block w-3 h-3 rounded-full
                    @if($notificationLevel === 'info') bg-blue-500
                    @elseif($notificationLevel === 'warning') bg-amber-500
                    @elseif($notificationLevel === 'success') bg-emerald-500
                    @elseif($notificationLevel === 'error') bg-red-500
                    @else bg-slate-400 @endif"></span>
                @if($notificationLevel !== 'error' && $orderStatus !== 'completed')
                <span class="absolute inset-0 rounded-full animate-ping opacity-70
                    @if($notificationLevel === 'info') bg-blue-400
                    @elseif($notificationLevel === 'warning') bg-amber-400
                    @elseif($notificationLevel === 'success') bg-emerald-400
                    @else bg-slate-300 @endif"></span>
                @endif
            </span>

            <div class="flex-1">
                <p class="text-sm font-bold leading-snug
                    @if($notificationLevel === 'info') text-blue-800
                    @elseif($notificationLevel === 'warning') text-amber-800
                    @elseif($notificationLevel === 'success') text-emerald-800
                    @elseif($notificationLevel === 'error') text-red-800
                    @else text-slate-700 @endif">
                    {{ $orderNotification }}
                </p>
                <p class="mt-1 text-[10px] font-semibold uppercase tracking-widest
                    @if($notificationLevel === 'info') text-blue-400
                    @elseif($notificationLevel === 'warning') text-amber-400
                    @elseif($notificationLevel === 'success') text-emerald-400
                    @elseif($notificationLevel === 'error') text-red-400
                    @else text-slate-400 @endif">
                    Status: {{ strtoupper($orderStatus) }}
                </p>
            </div>
        </div>
        @endif

        {{-- Success Display --}}
        <div class="text-center space-y-3">
            <div class="w-20 h-20 bg-emerald-50 text-emerald-500 rounded-full flex items-center justify-center mx-auto mb-6 shadow-md shadow-emerald-500/10">
                <i data-lucide="check" class="w-10 h-10 stroke-[3]"></i>
            </div>
            <h2 class="text-2xl font-black text-slate-900 tracking-tight">Pesanan Diterima!</h2>
            <p class="text-slate-450 text-xs font-semibold uppercase tracking-widest">ORDER ID: #ORD-{{ str_pad($lastOrder['id'], 3, '0', STR_PAD_LEFT) }}</p>
        </div>

        {{-- Dine In Info --}}
        <div class="w-full bg-slate-50 border border-slate-100 rounded-[2.5rem] p-6 space-y-4">
            <div class="flex justify-between items-center text-xs">
                <span class="text-slate-450 font-medium">Nomor Meja</span>
                <span class="font-black text-slate-800">{{ $lastOrder['tableName'] ?: 'Dine In' }}</span>
            </div>
            <div class="flex justify-between items-center text-xs">
                <span class="text-slate-450 font-medium">Nama Pelanggan</span>
                <span class="font-black text-slate-800">{{ $customerName ?: 'Pelanggan' }}</span>
            </div>
            <div class="pt-3 border-t border-slate-150/60 flex justify-between items-center">
                <span class="text-xs font-black text-slate-900">Total Dibayar (di Kasir)</span>
                <span class="text-base font-black text-brand tracking-tight">Rp {{ number_format($lastOrder['grandTotal'], 0, ',', '.') }}</span>
            </div>
        </div>

        {{-- Order Items Summary --}}
        <div class="w-full space-y-3">
            <h4 class="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Rincian Hidangan</h4>
            <div class="bg-white border border-slate-100 rounded-[2rem] p-5 divide-y divide-slate-50">
                @if(!empty($lastOrder['promoDesc']))
                <div class="py-2.5 flex justify-between items-center first:pt-0 last:pb-0">
                    <span class="text-xs font-bold text-brand w-3/4 leading-tight">
                        {{ $lastOrder['promoDesc'] }}
                    </span>
                    <span class="text-xs font-black text-brand text-right w-1/4">Terpakai</span>
                </div>
                @endif
                @foreach($lastOrder['items'] as $item)
                <div class="py-2.5 flex justify-between items-center first:pt-0 last:pb-0">
                    <span class="text-xs font-medium text-slate-600">
                        {{ $item['quantity'] }}x <span class="font-bold text-slate-850">{{ $item['name'] }}</span>
                    </span>
                    <span class="text-xs font-black text-slate-800">Rp {{ number_format($item['price'] * $item['quantity'], 0, ',', '.') }}</span>
                </div>
                @endforeach
            </div>
        </div>

        {{-- QRIS Payment Section --}}
        @if($setting->qris_image)
        <div class="w-full bg-white border border-slate-100 rounded-[2.5rem] p-6 space-y-4 text-center shadow-sm">
            <div class="inline-flex items-center justify-center w-12 h-12 bg-blue-50 text-blue-500 rounded-full mb-2">
                <i data-lucide="qr-code" class="w-6 h-6"></i>
            </div>
            <h3 class="text-sm font-black text-slate-900 uppercase tracking-widest">Bayar Pakai QRIS</h3>
            <p class="text-[10px] font-bold text-slate-400 leading-relaxed max-w-[250px] mx-auto">
                Scan kode QR di bawah ini untuk melakukan pembayaran. Tunjukkan bukti transfer ke kasir setelah berhasil.
            </p>
            
            <div class="mx-auto w-48 h-48 bg-slate-50 border-2 border-dashed border-slate-200 rounded-3xl p-3 flex items-center justify-center overflow-hidden">
                <img src="{{ str_starts_with($setting->qris_image, 'http') ? $setting->qris_image : asset('storage/' . $setting->qris_image) }}" class="w-full h-full object-contain rounded-2xl" alt="QRIS Payment">
            </div>

            {{-- Download QR Code Button --}}
            @php
                $qrisImageUrl = str_starts_with($setting->qris_image, 'http') ? $setting->qris_image : asset('storage/' . $setting->qris_image);
            @endphp
            <div class="mt-3 flex justify-center">
                <a href="{{ $qrisImageUrl }}" download="QRIS-Payment.png" target="_blank"
                   class="inline-flex items-center gap-2 px-5 py-3 bg-slate-100 border border-slate-200 hover:bg-slate-200 text-slate-700 rounded-2xl text-xs font-black uppercase tracking-widest transition active:scale-95 shadow-sm">
                    <i data-lucide="download" class="w-4 h-4 text-slate-500"></i>
                    <span>Unduh Kode QR</span>
                </a>
            </div>

            @if($setting->bank_name || $setting->account_number)
            <div class="bg-slate-50 p-4 rounded-2xl mt-4 text-left border border-slate-100">
                <span class="block text-[9px] font-black uppercase tracking-widest text-slate-400 mb-1">Atau Transfer Rekening</span>
                <p class="text-xs font-black text-slate-900">{{ $setting->bank_name ?? 'Bank' }} - {{ $setting->account_number ?? '-' }}</p>
                <p class="text-[10px] font-bold text-slate-500 mt-0.5">a.n {{ $setting->account_name ?? 'MenuKu' }}</p>
            </div>
            @endif
        </div>
        @endif

        {{-- Status Notice --}}
        <div class="bg-brand/5 border border-brand/10 p-5 rounded-[2rem] text-center w-full">
            <p class="text-xs font-bold text-brand leading-relaxed">
                Hidangan Anda sedang dipersiapkan oleh koki kami. Silakan tunggu santai di meja Anda, pelayan kami akan segera mengantarkan pesanan Anda!
            </p>
        </div>

        {{-- Reset Back to Menu --}}
        <button
            wire:click="setScreen('menu')"
            class="w-full py-5 bg-slate-900 hover:bg-slate-800 text-white rounded-2xl font-black text-sm tracking-widest uppercase shadow-xl transition active:scale-95">
            KEMBALI KE BERANDA
        </button>
    </div>
    @endif

    <style>
        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-16px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</div>
