<div class="flex flex-col h-full">
    {{-- Flash Message --}}
    @if(session()->has('message'))
    <div class="mb-6 p-4 bg-emerald-50 border border-emerald-100 text-emerald-700 rounded-2xl flex items-center gap-3 shadow-sm shrink-0">
        <i data-lucide="check-circle" class="w-5 h-5 shrink-0"></i>
        <p class="font-bold text-sm">{{ session('message') }}</p>
    </div>
    @endif

    {{-- Header Row --}}
    <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-6 mb-8 shrink-0">
        {{-- Add Button --}}
        <button
            wire:click="openAdd()"
            class="w-full lg:w-auto px-6 py-4 bg-brand text-white rounded-2xl font-black text-sm transition shadow-xl shadow-brand/20 hover:-translate-y-1 active:scale-95 flex items-center justify-center gap-2">
            <i data-lucide="plus" class="w-5 h-5"></i>
            <span>TAMBAH MENU</span>
        </button>

        <div class="flex flex-wrap items-center gap-4 w-full lg:w-auto">
            {{-- Search & View Toggle Group --}}
            <div class="flex items-center gap-3 w-full sm:w-auto flex-1 sm:flex-initial">
                {{-- Search --}}
                <div class="relative group flex-1 sm:flex-initial">
                    <input
                        type="text"
                        wire:model.live="search"
                        placeholder="Cari menu..."
                        class="w-full sm:w-64 pl-12 pr-6 py-3.5 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand focus:border-brand transition outline-none text-sm font-medium shadow-sm">
                    <i data-lucide="search" class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 group-focus-within:text-brand transition"></i>
                </div>

                {{-- View Mode Toggle --}}
                <div class="flex p-1 bg-white border border-slate-200 rounded-xl shadow-sm shrink-0">
                    <button
                        wire:click="$set('viewMode', 'grid')"
                        class="p-2 rounded-lg transition {{ $viewMode === 'grid' ? 'bg-slate-100 text-slate-900' : 'text-slate-400 hover:text-brand' }}">
                        <i data-lucide="layout-grid" class="w-5 h-5"></i>
                    </button>
                    <button
                        wire:click="$set('viewMode', 'list')"
                        class="p-2 rounded-lg transition {{ $viewMode === 'list' ? 'bg-slate-100 text-slate-900' : 'text-slate-400 hover:text-brand' }}">
                        <i data-lucide="list" class="w-5 h-5"></i>
                    </button>
                </div>
            </div>

            {{-- Category Filter --}}
            <div x-data="{ open: false }" class="relative z-20">
                <button @click="open = !open" @click.outside="open = false" type="button"
                    class="px-5 py-3.5 bg-white border border-slate-200 rounded-2xl text-xs font-bold text-slate-600 outline-none hover:border-brand shadow-sm flex items-center justify-between gap-4 min-w-[180px] transition">
                    <span>{{ $filterCategory ? ($categories->firstWhere('id', $filterCategory)?->name ?? 'Semua Kategori') : 'Semua Kategori' }}</span>
                    <i data-lucide="chevron-down" class="w-4 h-4 text-slate-400 transition-transform" :class="open ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="open" x-transition.opacity.duration.200ms style="display: none;"
                    class="absolute top-full mt-2 w-full bg-white border border-slate-100 rounded-2xl shadow-xl overflow-hidden py-2 z-30">
                    <button wire:click="$set('filterCategory', '')" @click="open = false"
                        class="w-full text-left px-5 py-3 text-xs font-bold text-slate-600 hover:bg-brand/5 hover:text-brand transition">Semua Kategori</button>
                    @foreach($categories as $category)
                    <button wire:click="$set('filterCategory', {{ $category->id }})" @click="open = false"
                        class="w-full text-left px-5 py-3 text-xs font-bold text-slate-600 hover:bg-brand/5 hover:text-brand transition">{{ $category->name }}</button>
                    @endforeach
                </div>
            </div>

            {{-- Cuisine Filter --}}
            <div x-data="{ open: false }" class="relative z-20">
                <button @click="open = !open" @click.outside="open = false" type="button"
                    class="px-5 py-3.5 bg-white border border-slate-200 rounded-2xl text-xs font-bold text-slate-600 outline-none hover:border-brand shadow-sm flex items-center justify-between gap-4 min-w-[170px] transition">
                    <span>{{ $filterCuisine ?: 'Semua Asal' }}</span>
                    <i data-lucide="chevron-down" class="w-4 h-4 text-slate-400 transition-transform" :class="open ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="open" x-transition.opacity.duration.200ms style="display: none;"
                    class="absolute top-full mt-2 w-full bg-white border border-slate-100 rounded-2xl shadow-xl overflow-hidden py-2 z-30">
                    <button wire:click="$set('filterCuisine', '')" @click="open = false"
                        class="w-full text-left px-5 py-3 text-xs font-bold text-slate-600 hover:bg-brand/5 hover:text-brand transition">Semua Asal</button>
                    @foreach($cuisines as $cuisine)
                    <button wire:click="$set('filterCuisine', '{{ $cuisine }}')" @click="open = false"
                        class="w-full text-left px-5 py-3 text-xs font-bold text-slate-600 hover:bg-brand/5 hover:text-brand transition">{{ $cuisine }}</button>
                    @endforeach
                </div>
            </div>
        </div>
    </div>

    {{-- Loading Indicator --}}
    <div wire:loading class="text-xs font-bold text-brand mb-4 flex items-center gap-2 shrink-0">
        <svg class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
        </svg>
        Memuat data...
    </div>

    {{-- Product Grid / List --}}
    <div class="flex-1 overflow-y-auto custom-scrollbar pr-1 pb-10">

        {{-- GRID VIEW --}}
        @if($viewMode === 'grid')
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
            @forelse($products as $product)
            <div class="flex flex-col bg-white rounded-[2.5rem] border border-slate-200 shadow-sm overflow-hidden group hover:shadow-xl hover:shadow-slate-200/50 transition-all duration-500 relative {{ !$product->is_available ? 'opacity-80' : '' }}">
                {{-- Image --}}
                <div class="h-48 w-full relative overflow-hidden {{ !$product->is_available ? 'grayscale' : '' }}">
                    <img src="{{ $product->image ? (str_starts_with($product->image, 'http') ? $product->image : asset('storage/' . $product->image)) : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop' }}"
                        class="w-full h-full object-cover group-hover:scale-110 transition duration-700" alt="{{ $product->name }}">

                    @if(!$product->is_available)
                    <div class="absolute inset-0 bg-slate-900/40 flex items-center justify-center">
                        <span class="px-4 py-2 bg-white text-slate-900 text-[10px] font-black uppercase rounded-xl tracking-widest shadow-xl">STOK HABIS</span>
                    </div>
                    @endif

                    <div class="absolute top-4 left-4">
                        <span class="px-3 py-1 bg-white/90 backdrop-blur text-brand text-[9px] font-black uppercase rounded-lg shadow-sm border border-brand/10">{{ $product->category?->name ?? 'Umum' }}</span>
                    </div>

                    <div class="absolute top-4 right-4 flex gap-2">
                        <button wire:click="openEdit({{ $product->id }})" class="p-2 bg-white/90 backdrop-blur text-slate-400 hover:text-blue-500 rounded-lg shadow-sm transition">
                            <i data-lucide="pencil" class="w-4 h-4"></i>
                        </button>
                        <button wire:click="delete({{ $product->id }})" onclick="return confirm('Hapus produk ini?')" class="p-2 bg-white/90 backdrop-blur text-slate-400 hover:text-red-500 rounded-lg shadow-sm transition">
                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                        </button>
                    </div>
                </div>

                {{-- Content --}}
                <div class="p-6 flex-1 flex flex-col justify-between">
                    <div>
                        <div class="flex items-center gap-2 mb-3">
                            @if($product->is_popular)
                            <span class="px-2 py-0.5 bg-red-50 text-red-500 text-[8px] font-black uppercase rounded-md border border-red-100">Populer</span>
                            @endif
                            @if($product->discount_percentage > 0)
                            <span class="px-2 py-0.5 bg-rose-500 text-white text-[8px] font-black uppercase rounded-md shadow-sm">-{{ $product->discount_percentage }}%</span>
                            @endif
                            @if($product->cuisine)
                            <span class="px-2 py-0.5 bg-brand/5 text-brand text-[8px] font-black uppercase rounded-md border border-brand/10">{{ $product->cuisine }}</span>
                            @endif
                        </div>
                        <h3 class="text-base font-black text-slate-900 mb-1 leading-tight {{ !$product->is_available ? 'text-slate-400' : '' }}">{{ $product->name }}</h3>

                        {{-- Tags --}}
                        @if($product->tags && count($product->tags) > 0)
                        <div class="flex flex-wrap gap-1.5 mb-3">
                            @foreach($product->tags as $tag)
                            <span class="px-2 py-0.5 bg-slate-100 text-slate-500 text-[8px] font-bold rounded-md border border-slate-200">{{ $tag }}</span>
                            @endforeach
                        </div>
                        @endif

                        <div class="flex flex-col mb-4">
                            @if($product->discount_percentage > 0)
                            <span class="text-[10px] font-bold text-slate-400 line-through leading-none mb-1">Rp {{ number_format($product->price, 0, ',', '.') }}</span>
                            @endif
                            <p class="text-lg font-black text-brand tracking-tighter leading-none {{ !$product->is_available ? 'opacity-50' : '' }}">
                                Rp {{ number_format($product->price * (1 - $product->discount_percentage / 100), 0, ',', '.') }}
                            </p>
                        </div>
                    </div>

                    <div class="flex items-center justify-between pt-4 border-t border-slate-100">
                        <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Ketersediaan</span>
                        <label class="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" class="sr-only peer" {{ $product->is_available ? 'checked' : '' }}
                                wire:click="toggleAvailability({{ $product->id }})">
                            <div class="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-500"></div>
                        </label>
                    </div>
                </div>
            </div>
            @empty
            <div class="col-span-full flex flex-col items-center justify-center py-24 text-slate-200">
                <div class="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mb-4">
                    <i data-lucide="package-search" class="w-10 h-10"></i>
                </div>
                <p class="font-black uppercase tracking-widest text-[10px]">Tidak ada menu ditemukan</p>
            </div>
            @endforelse
        </div>

        {{-- LIST VIEW --}}
        @else
        <div class="bg-white rounded-[2.5rem] border border-slate-200 shadow-sm overflow-hidden">
            <div class="overflow-x-auto w-full custom-scrollbar">
                <table class="w-full text-left min-w-[700px] md:min-w-full">
                    <thead>
                        <tr class="bg-slate-50/50">
                            <th class="px-4 sm:px-8 py-4 sm:py-5 text-[10px] font-black text-slate-400 uppercase tracking-widest whitespace-nowrap">Produk</th>
                            <th class="px-4 sm:px-8 py-4 sm:py-5 text-[10px] font-black text-slate-400 uppercase tracking-widest whitespace-nowrap">Kategori</th>
                            <th class="px-4 sm:px-8 py-4 sm:py-5 text-[10px] font-black text-slate-400 uppercase tracking-widest whitespace-nowrap">Harga</th>
                            <th class="px-4 sm:px-8 py-4 sm:py-5 text-[10px] font-black text-slate-400 uppercase tracking-widest whitespace-nowrap">Status</th>
                            <th class="px-4 sm:px-8 py-4 sm:py-5 text-[10px] font-black text-slate-400 uppercase tracking-widest text-right whitespace-nowrap">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        @forelse($products as $product)
                        <tr class="hover:bg-slate-50/30 transition">
                            <td class="px-4 sm:px-8 py-4 sm:py-5">
                                <div class="flex items-center gap-4">
                                    <div class="w-14 h-14 rounded-2xl overflow-hidden shrink-0 {{ !$product->is_available ? 'grayscale' : '' }}">
                                        <img src="{{ $product->image ? (str_starts_with($product->image, 'http') ? $product->image : asset('storage/' . $product->image)) : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100' }}"
                                            class="w-full h-full object-cover" alt="{{ $product->name }}">
                                    </div>
                                    <div>
                                        <p class="font-black text-sm text-slate-900 whitespace-nowrap">{{ $product->name }}</p>
                                        @if($product->tags && count($product->tags) > 0)
                                        <div class="flex flex-wrap gap-1 mt-1">
                                            @foreach(array_slice($product->tags, 0, 2) as $tag)
                                            <span class="px-1.5 py-0.5 bg-slate-100 text-slate-400 text-[8px] font-bold rounded">{{ $tag }}</span>
                                            @endforeach
                                        </div>
                                        @endif
                                    </div>
                                </div>
                            </td>
                            <td class="px-4 sm:px-8 py-4 sm:py-5 whitespace-nowrap">
                                <span class="px-3 py-1 bg-brand/5 text-brand text-[10px] font-black uppercase rounded-lg border border-brand/10 whitespace-nowrap">{{ $product->category?->name ?? '-' }}</span>
                            </td>
                            <td class="px-4 sm:px-8 py-4 sm:py-5 whitespace-nowrap">
                                @if($product->discount_percentage > 0)
                                <span class="text-[10px] text-slate-400 line-through block leading-none mb-1">Rp {{ number_format($product->price, 0, ',', '.') }}</span>
                                @endif
                                <span class="font-black text-brand">Rp {{ number_format($product->price * (1 - $product->discount_percentage / 100), 0, ',', '.') }}</span>
                            </td>
                            <td class="px-4 sm:px-8 py-4 sm:py-5 whitespace-nowrap">
                                <label class="relative inline-flex items-center cursor-pointer">
                                    <input type="checkbox" class="sr-only peer" {{ $product->is_available ? 'checked' : '' }}
                                        wire:click="toggleAvailability({{ $product->id }})">
                                    <div class="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-500"></div>
                                </label>
                            </td>
                            <td class="px-4 sm:px-8 py-4 sm:py-5 text-right whitespace-nowrap">
                                <div class="flex items-center justify-end gap-2">
                                    <button wire:click="openEdit({{ $product->id }})" class="p-2.5 bg-slate-50 text-slate-400 hover:text-blue-500 hover:bg-blue-50 rounded-xl transition border border-slate-100">
                                        <i data-lucide="pencil" class="w-4 h-4"></i>
                                    </button>
                                    <button wire:click="delete({{ $product->id }})" onclick="return confirm('Hapus produk ini?')" class="p-2.5 bg-slate-50 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-xl transition border border-slate-100">
                                        <i data-lucide="trash-2" class="w-4 h-4"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="5" class="px-4 sm:px-8 py-20 text-center">
                                <div class="flex flex-col items-center text-slate-200">
                                    <i data-lucide="package-search" class="w-12 h-12 mb-3"></i>
                                    <p class="font-black uppercase tracking-widest text-[10px]">Tidak ada menu ditemukan</p>
                                </div>
                            </td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
        @endif
    </div>

    {{-- Pagination --}}
    <div class="mt-8 shrink-0">
        {{ $products->links() }}
    </div>

    {{-- ===================== MODAL ADD/EDIT ===================== --}}
    @if($showModal)
    <div
        x-data="{ show: @entangle('showModal') }"
        x-show="show"
        x-transition:enter="transition ease-out duration-300"
        x-transition:enter-start="opacity-0"
        x-transition:enter-end="opacity-100"
        x-transition:leave="transition ease-in duration-200"
        x-transition:leave-start="opacity-100"
        x-transition:leave-end="opacity-0"
        class="fixed inset-0 z-[60] bg-slate-900/60 backdrop-blur-sm flex justify-end"
        style="display: none;">
        <div
            x-show="show"
            x-transition:enter="transition ease-out duration-300"
            x-transition:enter-start="translate-x-full"
            x-transition:enter-end="translate-x-0"
            x-transition:leave="transition ease-in duration-200"
            x-transition:leave-start="translate-x-0"
            x-transition:leave-end="translate-x-full"
            class="bg-white w-full max-w-2xl h-full shadow-2xl overflow-y-auto custom-scrollbar">
            <div class="p-10">
                <div class="flex items-center justify-between mb-10">
                    <div>
                        <h3 class="text-2xl font-black text-slate-900 tracking-tight">{{ $editingId ? 'Edit Produk' : 'Tambah Produk Baru' }}</h3>
                        <p class="text-sm font-medium text-slate-500">Lengkapi detail produk dengan benar.</p>
                    </div>
                    <button wire:click="$set('showModal', false)" class="p-3 bg-slate-50 text-slate-400 hover:text-slate-600 rounded-2xl transition">
                        <i data-lucide="x" class="w-6 h-6"></i>
                    </button>
                </div>

                <div class="space-y-8 pb-20">
                    {{-- Photo Upload --}}
                    <div>
                        <label class="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-4">Foto Produk</label>
                        @if($existingImage)
                        <div class="mb-3 w-full h-48 rounded-[2rem] overflow-hidden bg-slate-50 border-2 border-dashed border-slate-200">
                            <img src="{{ str_starts_with($existingImage, 'http') ? $existingImage : asset('storage/' . $existingImage) }}" class="w-full h-full object-cover">
                        </div>
                        <p class="text-[10px] text-slate-400 mb-3 italic px-1">Gambar saat ini. Upload baru untuk mengganti.</p>
                        @endif

                        <div class="w-full h-48 bg-slate-50 border-2 border-dashed border-slate-200 rounded-[2rem] flex flex-col items-center justify-center gap-2 cursor-pointer hover:border-brand hover:bg-brand/5 transition relative overflow-hidden"
                            onclick="document.getElementById('modal_photo_input').click()">
                            @if($photo)
                            <img src="{{ $photo->temporaryUrl() }}" class="absolute inset-0 w-full h-full object-cover">
                            @else
                            <i data-lucide="camera" class="w-10 h-10 text-slate-300 hover:text-brand transition z-10"></i>
                            <span class="text-xs font-bold text-slate-400 z-10 bg-white/80 px-3 py-1 rounded-full">Klik untuk upload foto</span>
                            @endif
                        </div>
                        <input type="file" id="modal_photo_input" wire:model="photo" class="hidden" accept="image/*">
                        @error('photo') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        {{-- Name --}}
                        <div class="col-span-2">
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Nama Produk *</label>
                            <input type="text" wire:model="name" required placeholder="Contoh: Es Teh Manis"
                                class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium text-sm transition">
                            @error('name') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                        </div>

                        {{-- Description --}}
                        <div class="col-span-2">
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Deskripsi</label>
                            <textarea wire:model="description" rows="2" placeholder="Jelaskan kelezatan produk ini..."
                                class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium text-sm transition"></textarea>
                        </div>

                        {{-- Price --}}
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Harga *</label>
                            <div class="relative">
                                <input type="number" wire:model="price" required placeholder="25000"
                                    class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium text-sm pl-12 transition">
                                <span class="absolute left-6 top-1/2 -translate-y-1/2 text-sm font-bold text-slate-400">Rp</span>
                            </div>
                            @error('price') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                        </div>

                        {{-- Discount --}}
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Diskon (%)</label>
                            <div class="relative">
                                <input type="number" wire:model="discount_percentage" min="0" max="100" placeholder="0"
                                    class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium text-sm pr-12 transition">
                                <span class="absolute right-6 top-1/2 -translate-y-1/2 text-sm font-bold text-slate-400">%</span>
                            </div>
                        </div>

                        {{-- Category --}}
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Kategori *</label>
                            <select wire:model="category_id" class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium text-sm transition">
                                <option value="">Pilih Kategori</option>
                                @foreach($categories as $category)
                                <option value="{{ $category->id }}">{{ $category->name }}</option>
                                @endforeach
                            </select>
                            @error('category_id') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                        </div>

                        {{-- Cuisine --}}
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Asal Makanan (Daerah)</label>
                            <select wire:model="cuisine" class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium text-sm transition">
                                <option value="">Pilih Asal</option>
                                @foreach($cuisines as $c)
                                <option value="{{ $c }}">{{ $c }}</option>
                                @endforeach
                            </select>
                        </div>

                        {{-- Tags --}}
                        <div class="col-span-2">
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Tags (pisahkan dengan koma)</label>
                            <input type="text" wire:model="tags" placeholder="Pedas, Manis, Gurih"
                                class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium text-sm transition">
                        </div>

                        {{-- Toggles --}}
                        <div class="col-span-2 flex gap-6">
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" wire:model="is_popular" class="sr-only peer">
                                <div class="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-brand"></div>
                                <span class="ml-3 text-sm font-bold text-slate-700">Tandai Populer</span>
                            </label>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" wire:model="is_available" class="sr-only peer">
                                <div class="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-500"></div>
                                <span class="ml-3 text-sm font-bold text-slate-700">Tersedia</span>
                            </label>
                        </div>
                    </div>

                    <div class="pt-6 flex gap-4">
                        <button wire:click="save()" class="flex-1 py-5 bg-brand text-white rounded-2xl font-black text-lg shadow-2xl shadow-brand/30 hover:opacity-90 transition">
                            <span wire:loading.remove wire:target="save">SIMPAN PRODUK</span>
                            <span wire:loading wire:target="save" class="flex items-center justify-center gap-2">
                                <svg class="animate-spin w-5 h-5" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path></svg>
                                Menyimpan...
                            </span>
                        </button>
                        <button wire:click="$set('showModal', false)" class="px-8 py-5 bg-slate-100 text-slate-600 rounded-2xl font-black text-sm hover:bg-slate-200 transition">BATAL</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    @endif
</div>
