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
                <span>TAMBAH KATEGORI</span>
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

    {{-- Categories Grid --}}
    <div class="flex-1 overflow-y-auto custom-scrollbar pr-1 pb-10">
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-8">
            @forelse($categories as $category)
            <div class="flex flex-col bg-white rounded-[2.5rem] border border-slate-200 shadow-sm overflow-hidden group hover:shadow-xl hover:shadow-slate-200/50 transition-all duration-500 relative">
                {{-- Image Cover --}}
                <div class="h-44 w-full relative overflow-hidden bg-slate-50">
                    <img src="{{ $category->image ? (str_starts_with($category->image, 'http') ? $category->image : asset('storage/' . $category->image)) : 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=500&auto=format&fit=crop' }}"
                        class="w-full h-full object-cover group-hover:scale-110 transition duration-700" alt="{{ $category->name }}">

                    <div class="absolute top-4 right-4 flex gap-2">
                        <button wire:click="openEdit({{ $category->id }})" class="p-2 bg-white/90 backdrop-blur text-slate-400 hover:text-blue-500 rounded-lg shadow-sm transition">
                            <i data-lucide="pencil" class="w-4 h-4"></i>
                        </button>
                        <button wire:click="confirmDelete({{ $category->id }})" class="p-2 bg-white/90 backdrop-blur text-slate-400 hover:text-red-500 rounded-lg shadow-sm transition">
                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                        </button>
                    </div>

                    <div class="absolute bottom-4 left-4">
                        <span class="px-3 py-1 bg-white/95 backdrop-blur text-brand text-[9px] font-black uppercase rounded-lg shadow-sm border border-brand/10">
                            {{ $category->products_count }} Produk
                        </span>
                    </div>
                </div>

                {{-- Card Body --}}
                <div class="p-6">
                    <h3 class="text-base font-black text-slate-900 leading-tight">{{ $category->name }}</h3>
                    <p class="text-xs text-slate-400 mt-1 font-medium">ID Kategori: #CAT-{{ str_pad($category->id, 2, '0', STR_PAD_LEFT) }}</p>
                </div>
            </div>
            @empty
            <div class="col-span-full flex flex-col items-center justify-center py-24 text-slate-200">
                <div class="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mb-4">
                    <i data-lucide="folder-search" class="w-10 h-10"></i>
                </div>
                <p class="font-black uppercase tracking-widest text-[10px]">Tidak ada kategori ditemukan</p>
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
            class="bg-white w-full max-w-xl h-full shadow-2xl overflow-y-auto custom-scrollbar">
            <div class="p-10 flex flex-col h-full justify-between">
                <div>
                    <div class="flex items-center justify-between mb-10">
                        <div>
                            <h3 class="text-2xl font-black text-slate-900 tracking-tight">{{ $editingId ? 'Edit Kategori' : 'Tambah Kategori Baru' }}</h3>
                            <p class="text-sm font-medium text-slate-500">Lengkapi detail kategori makanan atau minuman.</p>
                        </div>
                        <button wire:click="$set('showModal', false)" class="p-3 bg-slate-50 text-slate-400 hover:text-slate-600 rounded-2xl transition">
                            <i data-lucide="x" class="w-6 h-6"></i>
                        </button>
                    </div>

                    <div class="space-y-8">
                        {{-- Photo Upload --}}
                        <div>
                            <label class="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-4">Foto / Banner Kategori</label>
                            @if($existingImage && !$photo)
                            <div class="mb-3 w-full h-44 rounded-[2rem] overflow-hidden bg-slate-50 border border-slate-200">
                                <img src="{{ str_starts_with($existingImage, 'http') ? $existingImage : asset('storage/' . $existingImage) }}" class="w-full h-full object-cover">
                            </div>
                            <p class="text-[10px] text-slate-400 mb-3 italic px-1">Gambar saat ini. Upload baru untuk mengganti.</p>
                            @endif

                            <div class="w-full h-44 bg-slate-50 border-2 border-dashed border-slate-200 rounded-[2rem] flex flex-col items-center justify-center gap-2 cursor-pointer hover:border-brand hover:bg-brand/5 transition relative overflow-hidden"
                                onclick="document.getElementById('modal_cat_photo_input').click()">
                                @if($photo)
                                <img src="{{ $photo->temporaryUrl() }}" class="absolute inset-0 w-full h-full object-cover">
                                @else
                                <i data-lucide="image" class="w-10 h-10 text-slate-300 hover:text-brand transition z-10"></i>
                                <span class="text-xs font-bold text-slate-400 z-10 bg-white/80 px-3 py-1 rounded-full">Klik untuk upload gambar</span>
                                @endif
                            </div>
                            <input type="file" id="modal_cat_photo_input" wire:model="photo" class="hidden" accept="image/*">
                            @error('photo') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                        </div>

                        {{-- Name --}}
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Nama Kategori *</label>
                            <input type="text" wire:model="name" required placeholder="Contoh: Hidangan Utama, Minuman Dingin"
                                class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium text-sm transition">
                            @error('name') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                        </div>
                    </div>
                </div>

                <div class="pt-10 flex gap-4 mt-auto">
                    <button wire:click="save()" class="flex-1 py-5 bg-brand text-white rounded-2xl font-black text-lg shadow-2xl shadow-brand/30 hover:opacity-90 transition">
                        <span wire:loading.remove wire:target="save">SIMPAN KATEGORI</span>
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
    @endif

    {{-- ===================== DELETE CONFIRMATION ===================== --}}
    @if($deletingId)
    <div
        x-data="{ show: @entangle('deletingId') }"
        x-show="show"
        x-transition:enter="transition ease-out duration-300"
        x-transition:enter-start="opacity-0"
        x-transition:enter-end="opacity-100"
        x-transition:leave="transition ease-in duration-200"
        x-transition:leave-start="opacity-100"
        x-transition:leave-end="opacity-0"
        class="fixed inset-0 z-[70] bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4"
        style="display: none;">
        <div
            x-show="show"
            x-transition:enter="transition ease-out duration-300"
            x-transition:enter-start="scale-95 opacity-0"
            x-transition:enter-end="scale-100 opacity-100"
            x-transition:leave="transition ease-in duration-200"
            x-transition:leave-start="scale-100 opacity-100"
            x-transition:leave-end="scale-95 opacity-0"
            class="bg-white w-full max-w-md rounded-[2.5rem] border border-slate-200 p-8 shadow-2xl relative">
            <div class="flex flex-col items-center text-center">
                <div class="w-16 h-16 bg-red-50 text-red-500 rounded-full flex items-center justify-center mb-6">
                    <i data-lucide="alert-triangle" class="w-8 h-8"></i>
                </div>
                <h3 class="text-xl font-black text-slate-900 mb-2 leading-tight">Hapus Kategori?</h3>
                <p class="text-sm font-medium text-slate-500 mb-8">Tindakan ini tidak dapat dibatalkan. Semua relasi produk dengan kategori ini mungkin akan terpengaruh.</p>
                <div class="flex w-full gap-4">
                    <button wire:click="delete()" class="flex-1 py-4 bg-red-600 hover:bg-red-700 text-white rounded-2xl font-black text-sm transition shadow-lg shadow-red-600/20">
                        YA, HAPUS
                    </button>
                    <button wire:click="$set('deletingId', null)" class="flex-1 py-4 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-2xl font-black text-sm transition">
                        BATAL
                    </button>
                </div>
            </div>
        </div>
    </div>
    @endif
</div>
