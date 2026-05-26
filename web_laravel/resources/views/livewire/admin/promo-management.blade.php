<div class="flex flex-col h-full">
    {{-- Flash Message --}}
    @if(session()->has('success'))
    <div class="mb-6 p-4 bg-emerald-50 border border-emerald-100 text-emerald-700 rounded-2xl flex items-center gap-3 shadow-sm shrink-0">
        <i data-lucide="check-circle" class="w-5 h-5 shrink-0"></i>
        <p class="font-bold text-sm">{{ session('success') }}</p>
    </div>
    @endif

    {{-- Action Row --}}
    <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-6 mb-8 shrink-0">
        <div>
            <button
                wire:click="openAdd()"
                class="px-6 py-4 bg-brand text-white rounded-2xl font-black text-sm transition shadow-xl shadow-brand/20 hover:-translate-y-1 active:scale-95 flex items-center gap-2">
                <i data-lucide="plus" class="w-5 h-5"></i>
                <span>TAMBAH PROMO</span>
            </button>
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

    {{-- Promo Grid --}}
    <div class="flex-1 overflow-y-auto custom-scrollbar pr-1 pb-10">
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
            @forelse($promos as $promo)
            <div class="flex flex-col bg-white rounded-[2.5rem] border border-slate-200 shadow-sm overflow-hidden group hover:shadow-xl hover:shadow-slate-200/50 transition-all duration-500 relative {{ !$promo->is_active ? 'opacity-85' : '' }}">
                {{-- Promo Image --}}
                <div class="h-40 w-full relative overflow-hidden bg-slate-50 {{ !$promo->is_active ? 'grayscale' : '' }}">
                    <img src="{{ $promo->image ? (str_starts_with($promo->image, 'http') ? $promo->image : asset('storage/' . $promo->image)) : 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=500&auto=format&fit=crop' }}"
                        class="w-full h-full object-cover group-hover:scale-110 transition duration-700" alt="{{ $promo->name }}">

                    @if(!$promo->is_active)
                    <div class="absolute inset-0 bg-slate-900/40 flex items-center justify-center">
                        <span class="px-4 py-2 bg-white text-slate-900 text-[10px] font-black uppercase rounded-xl tracking-widest shadow-xl">TIDAK AKTIF</span>
                    </div>
                    @endif

                    <div class="absolute top-4 left-4 flex flex-col gap-1.5">
                        <span class="px-2.5 py-1 bg-white/95 backdrop-blur text-brand text-[9px] font-black uppercase rounded-lg shadow-sm border border-brand/10 w-fit">
                            {{ $promo->type === 'percentage' ? $promo->value . '%' : 'Rp ' . number_format($promo->value, 0, ',', '.') }} OFF
                        </span>
                        @if($promo->is_banner)
                        <span class="px-2.5 py-1 bg-red-500 text-white text-[9px] font-black uppercase rounded-lg shadow-sm w-fit">
                            Banner Utama
                        </span>
                        @endif
                    </div>

                    <div class="absolute top-4 right-4 flex gap-2">
                        <button wire:click="openEdit({{ $promo->id }})" class="p-2 bg-white/90 backdrop-blur text-slate-400 hover:text-blue-500 rounded-lg shadow-sm transition">
                            <i data-lucide="pencil" class="w-4 h-4"></i>
                        </button>
                        <button wire:click="delete({{ $promo->id }})" onclick="return confirm('Hapus promo ini?')" class="p-2 bg-white/90 backdrop-blur text-slate-400 hover:text-red-500 rounded-lg shadow-sm transition">
                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                        </button>
                    </div>
                </div>

                {{-- Content --}}
                <div class="p-6 flex-1 flex flex-col justify-between">
                    <div>
                        <div class="mb-3">
                            <span class="px-3 py-1 bg-slate-100 border border-slate-200 text-slate-700 text-xs font-black rounded-lg inline-block uppercase tracking-wider select-all cursor-pointer">
                                {{ $promo->code }}
                            </span>
                        </div>
                        <h3 class="text-base font-black text-slate-900 mb-1 leading-tight">{{ $promo->name }}</h3>
                        <p class="text-xs text-slate-500 font-medium line-clamp-2 mb-4">{{ $promo->description ?: 'Tidak ada deskripsi.' }}</p>

                        <div class="space-y-1.5 mb-6 pt-4 border-t border-slate-100">
                            <div class="flex justify-between items-center text-xs">
                                <span class="text-slate-400 font-medium">Min. Belanja</span>
                                <span class="font-black text-slate-800">Rp {{ number_format($promo->min_purchase, 0, ',', '.') }}</span>
                            </div>
                            <div class="flex justify-between items-center text-xs">
                                <span class="text-slate-400 font-medium">Kuota</span>
                                <span class="font-black text-slate-800">{{ $promo->quota !== null ? $promo->quota . ' Kupon' : 'Tak Terbatas' }}</span>
                            </div>
                        </div>
                    </div>

                    <div class="flex items-center justify-between pt-4 border-t border-slate-100">
                        <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Status Promo</span>
                        <label class="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" class="sr-only peer" {{ $promo->is_active ? 'checked' : '' }}
                                wire:click="toggleActive({{ $promo->id }})">
                            <div class="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-500"></div>
                        </label>
                    </div>
                </div>
            </div>
            @empty
            <div class="col-span-full flex flex-col items-center justify-center py-24 text-slate-200">
                <div class="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mb-4">
                    <i data-lucide="tag" class="w-10 h-10"></i>
                </div>
                <p class="font-black uppercase tracking-widest text-[10px]">Tidak ada promo ditemukan</p>
            </div>
            @endforelse
        </div>
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
                        <h3 class="text-2xl font-black text-slate-900 tracking-tight">{{ $editingId ? 'Edit Promo' : 'Tambah Promo Baru' }}</h3>
                        <p class="text-sm font-medium text-slate-500">Lengkapi detail penawaran promo.</p>
                    </div>
                    <button wire:click="$set('showModal', false)" class="p-3 bg-slate-50 text-slate-400 hover:text-slate-600 rounded-2xl transition">
                        <i data-lucide="x" class="w-6 h-6"></i>
                    </button>
                </div>

                <div class="space-y-8 pb-20">
                    {{-- Photo Upload --}}
                    <div>
                        <label class="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-4">Banner Promo</label>
                        @if($existingImage && !$photo)
                        <div class="mb-3 w-full h-44 rounded-[2rem] overflow-hidden bg-slate-50 border border-slate-200">
                            <img src="{{ str_starts_with($existingImage, 'http') ? $existingImage : asset('storage/' . $existingImage) }}" class="w-full h-full object-cover">
                        </div>
                        <p class="text-[10px] text-slate-400 mb-3 italic px-1">Gambar saat ini. Upload baru untuk mengganti.</p>
                        @endif

                        <div class="w-full h-44 bg-slate-50 border-2 border-dashed border-slate-200 rounded-[2rem] flex flex-col items-center justify-center gap-2 cursor-pointer hover:border-brand hover:bg-brand/5 transition relative overflow-hidden"
                            onclick="document.getElementById('modal_promo_photo_input').click()">
                            @if($photo)
                            <img src="{{ $photo->temporaryUrl() }}" class="absolute inset-0 w-full h-full object-cover">
                            @else
                            <i data-lucide="camera" class="w-10 h-10 text-slate-300 hover:text-brand transition z-10"></i>
                            <span class="text-xs font-bold text-slate-400 z-10 bg-white/80 px-3 py-1 rounded-full">Klik untuk upload foto</span>
                            @endif
                        </div>
                        <input type="file" id="modal_promo_photo_input" wire:model="photo" class="hidden" accept="image/*">
                        @error('photo') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        {{-- Name --}}
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Nama Promo *</label>
                            <input type="text" wire:model="name" required placeholder="Contoh: Promo Akhir Pekan Ceria"
                                class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium text-sm transition">
                            @error('name') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                        </div>

                        {{-- Code --}}
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Kode Promo (Kupon) *</label>
                            <input type="text" wire:model="code" required placeholder="Contoh: WEEKEND50"
                                class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-black text-sm uppercase transition">
                            @error('code') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                        </div>

                        {{-- Description --}}
                        <div class="col-span-2">
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Deskripsi Promo</label>
                            <textarea wire:model="description" rows="2" placeholder="Tuliskan syarat & ketentuan promo di sini..."
                                class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium text-sm transition"></textarea>
                            @error('description') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                        </div>

                        {{-- Promo Type (Tipe Promo) --}}
                        <div class="col-span-2">
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Tipe Promo *</label>
                            <div class="grid grid-cols-3 gap-4">
                                <button type="button" wire:click="$set('promo_type', 'diskon')"
                                    class="py-4 border-2 rounded-2xl font-bold flex flex-col items-center justify-center gap-2 transition @if($promo_type === 'diskon') border-brand bg-brand/5 text-brand @else border-slate-200 bg-white text-slate-400 hover:border-slate-300 @endif">
                                    <i data-lucide="percent" class="w-6 h-6"></i>
                                    <span class="text-xs">Diskon</span>
                                </button>
                                <button type="button" wire:click="$set('promo_type', 'bundling')"
                                    class="py-4 border-2 rounded-2xl font-bold flex flex-col items-center justify-center gap-2 transition @if($promo_type === 'bundling') border-blue-500 bg-blue-50 text-blue-600 @else border-slate-200 bg-white text-slate-400 hover:border-slate-300 @endif">
                                    <i data-lucide="package" class="w-6 h-6"></i>
                                    <span class="text-xs">Bundling</span>
                                </button>
                                <button type="button" wire:click="$set('promo_type', 'free_item')"
                                    class="py-4 border-2 rounded-2xl font-bold flex flex-col items-center justify-center gap-2 transition @if($promo_type === 'free_item') border-emerald-500 bg-emerald-50 text-emerald-600 @else border-slate-200 bg-white text-slate-400 hover:border-slate-300 @endif">
                                    <i data-lucide="gift" class="w-6 h-6"></i>
                                    <span class="text-xs">Free Item</span>
                                </button>
                            </div>
                        </div>

                        {{-- DYNAMIC FIELDS BASED ON PROMO TYPE --}}
                        <div class="col-span-2 p-6 rounded-[2rem] border @if($promo_type === 'diskon') border-brand/20 bg-brand/5 @elseif($promo_type === 'bundling') border-blue-200 bg-blue-50 @else border-emerald-200 bg-emerald-50 @endif">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                @if($promo_type === 'diskon')
                                <div class="col-span-2">
                                    <label class="block text-sm font-bold @if($promo_type === 'diskon') text-brand @elseif($promo_type === 'bundling') text-blue-600 @else text-emerald-600 @endif mb-4">Detail Diskon</label>
                                    <label class="block text-xs font-bold text-slate-700 mb-2 px-1">Tipe Diskon *</label>
                                    <div class="flex gap-4">
                                        <button type="button" wire:click="$set('type', 'percentage')"
                                            class="flex-1 py-3 border-2 rounded-xl font-bold text-sm transition @if($type === 'percentage') border-brand bg-brand text-white @else border-slate-200 bg-white text-slate-500 @endif">
                                            % Persentase
                                        </button>
                                        <button type="button" wire:click="$set('type', 'fixed')"
                                            class="flex-1 py-3 border-2 rounded-xl font-bold text-sm transition @if($type === 'fixed') border-brand bg-brand text-white @else border-slate-200 bg-white text-slate-500 @endif">
                                            Rp Nominal
                                        </button>
                                    </div>
                                </div>
                                <div>
                                    <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Nilai Diskon *</label>
                                    <div class="relative">
                                        @if($type === 'fixed') <div class="absolute left-4 top-4 text-sm font-black text-slate-400">Rp</div> @endif
                                        <input type="number" wire:model="value" required placeholder="{{ $type === 'percentage' ? '10' : '15000' }}"
                                            class="w-full py-4 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-black text-sm transition {{ $type === 'fixed' ? 'pl-10 pr-6' : 'px-6' }}">
                                        @if($type === 'percentage') <div class="absolute right-4 top-4 text-sm font-black text-slate-400">%</div> @endif
                                    </div>
                                    @error('value') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                                </div>
                                <div>
                                    <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Min. Pembelian (Opsional)</label>
                                    <div class="relative">
                                        <div class="absolute left-4 top-4 text-sm font-black text-slate-400">Rp</div>
                                        <input type="number" wire:model="min_purchase" placeholder="0"
                                            class="w-full pl-10 pr-6 py-4 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-bold text-sm transition">
                                    </div>
                                    @error('min_purchase') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                                </div>

                                @elseif($promo_type === 'bundling')
                                <div class="col-span-2">
                                    <label class="block text-sm font-bold text-blue-600 mb-4">Detail Bundling</label>
                                    <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Isi Bundling *</label>
                                    <textarea wire:model="bundling_items" required rows="2" placeholder="Contoh: 2 Nasi + 2 Lauk + 2 Minuman"
                                        class="w-full px-6 py-4 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-blue-500 outline-none font-medium text-sm transition"></textarea>
                                    @error('bundling_items') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                                </div>
                                <div class="col-span-2">
                                    <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Harga Bundling *</label>
                                    <div class="relative">
                                        <div class="absolute left-4 top-4 text-sm font-black text-slate-400">Rp</div>
                                        <input type="number" wire:model="value" required placeholder="0"
                                            class="w-full pl-10 pr-6 py-4 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-blue-500 outline-none font-black text-sm transition">
                                    </div>
                                    @error('value') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                                </div>

                                @elseif($promo_type === 'free_item')
                                <div class="col-span-2">
                                    <label class="block text-sm font-bold text-emerald-600 mb-4">Detail Free Item</label>
                                    <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Item Gratis *</label>
                                    <input type="text" wire:model="free_item_name" required placeholder="Contoh: Es Teh Manis"
                                        class="w-full px-6 py-4 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-emerald-500 outline-none font-medium text-sm transition">
                                    @error('free_item_name') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                                </div>
                                <div class="col-span-2">
                                    <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Min. Pembelian *</label>
                                    <div class="relative">
                                        <div class="absolute left-4 top-4 text-sm font-black text-slate-400">Rp</div>
                                        <input type="number" wire:model="min_purchase" required placeholder="0"
                                            class="w-full pl-10 pr-6 py-4 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-emerald-500 outline-none font-bold text-sm transition">
                                    </div>
                                    @error('min_purchase') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                                </div>
                                @endif
                            </div>
                        </div>

                        {{-- Quota --}}
                        <div class="col-span-2">
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Kuota Kupon</label>
                            <input type="number" wire:model="quota" placeholder="Kosongkan jika tak terbatas"
                                class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium text-sm transition">
                            @error('quota') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                        </div>

                        {{-- Toggles --}}
                        <div class="col-span-2 flex flex-col md:flex-row gap-6 mt-2">
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" wire:model="is_active" class="sr-only peer">
                                <div class="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-500"></div>
                                <span class="ml-3 text-sm font-bold text-slate-700">Promo Aktif</span>
                            </label>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" wire:model="is_banner" class="sr-only peer">
                                <div class="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-brand"></div>
                                <span class="ml-3 text-sm font-bold text-slate-700">Tampilkan di Banner Utama</span>
                            </label>
                        </div>
                    </div>

                    <div class="pt-6 flex gap-4">
                        <button wire:click="save()" class="flex-1 py-5 bg-brand text-white rounded-2xl font-black text-lg shadow-2xl shadow-brand/30 hover:opacity-90 transition">
                            <span wire:loading.remove wire:target="save">SIMPAN PROMO</span>
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
