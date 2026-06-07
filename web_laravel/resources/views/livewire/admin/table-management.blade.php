<div class="flex flex-col h-full">
    {{-- Flash Message --}}
    @if(session()->has('success'))
    <div class="mb-6 p-4 bg-emerald-50 border border-emerald-100 text-emerald-700 rounded-2xl flex items-center gap-3 shadow-sm shrink-0">
        <i data-lucide="check-circle" class="w-5 h-5 shrink-0"></i>
        <p class="font-bold text-sm">{{ session('success') }}</p>
    </div>
    @endif

    {{-- Header & Actions --}}
    <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-6 mb-6 shrink-0">
        <div>
            <p class="text-slate-500 font-medium">Kelola meja dan QR code untuk pemesanan pelanggan</p>
        </div>
        <div class="flex items-center gap-4">
            <a href="{{ route('admin.tables.qr.download-all') }}" class="px-6 py-3 bg-white text-slate-700 border border-slate-200 rounded-xl font-bold text-sm transition hover:bg-slate-50 flex items-center gap-2">
                <i data-lucide="download" class="w-4 h-4"></i>
                <span>Download Semua QR</span>
            </a>
            <button
                wire:click="openAdd()"
                class="px-6 py-3 bg-brand text-white rounded-xl font-bold text-sm transition shadow-lg shadow-brand/20 hover:-translate-y-0.5 active:scale-95 flex items-center gap-2">
                <i data-lucide="plus" class="w-4 h-4"></i>
                <span>Tambah Meja</span>
            </button>
        </div>
    </div>

    {{-- Stats Row --}}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8 shrink-0">
        @php
            $total = count($tables);
            $aktif = $tables->where('is_active', true)->count();
            $nonaktif = $total - $aktif;
        @endphp
        
        {{-- Total Meja --}}
        <div class="bg-white rounded-2xl p-6 border border-slate-100 shadow-sm flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-blue-50 flex items-center justify-center">
                <i data-lucide="list" class="w-6 h-6 text-blue-500"></i>
            </div>
            <div>
                <p class="text-sm font-medium text-slate-400">Total Meja</p>
                <h4 class="text-2xl font-black text-slate-900">{{ $total }}</h4>
            </div>
        </div>

        {{-- Meja Aktif --}}
        <div class="bg-white rounded-2xl p-6 border border-slate-100 shadow-sm flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-emerald-50 flex items-center justify-center">
                <i data-lucide="check-circle-2" class="w-6 h-6 text-emerald-500"></i>
            </div>
            <div>
                <p class="text-sm font-medium text-slate-400">Meja Aktif</p>
                <h4 class="text-2xl font-black text-emerald-500">{{ $aktif }}</h4>
            </div>
        </div>

        {{-- Meja Nonaktif --}}
        <div class="bg-white rounded-2xl p-6 border border-slate-100 shadow-sm flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-slate-50 flex items-center justify-center">
                <i data-lucide="info" class="w-6 h-6 text-slate-400"></i>
            </div>
            <div>
                <p class="text-sm font-medium text-slate-400">Meja Nonaktif</p>
                <h4 class="text-2xl font-black text-slate-400">{{ $nonaktif }}</h4>
            </div>
        </div>

        {{-- Total QR Code --}}
        <div class="bg-white rounded-2xl p-6 border border-slate-100 shadow-sm flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-orange-50 flex items-center justify-center">
                <i data-lucide="qr-code" class="w-6 h-6 text-orange-500"></i>
            </div>
            <div>
                <p class="text-sm font-medium text-slate-400">Total QR Code</p>
                <h4 class="text-2xl font-black text-brand">{{ $total }}</h4>
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

    {{-- Tables Grid --}}
    <div class="flex-1 overflow-y-auto custom-scrollbar pr-1 pb-10">
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-8">
            @forelse($tables as $table)
            @php
                $statusColors = [
                    'available' => ['bg' => 'bg-emerald-50 border-emerald-100', 'text' => 'text-emerald-700', 'dot' => 'bg-emerald-500', 'label' => 'Tersedia'],
                    'occupied'  => ['bg' => 'bg-amber-50 border-amber-100', 'text' => 'text-amber-700', 'dot' => 'bg-amber-500', 'label' => 'Terisi'],
                    'reserved'  => ['bg' => 'bg-blue-50 border-blue-100', 'text' => 'text-blue-700', 'dot' => 'bg-blue-500', 'label' => 'Dipesan'],
                ];
                $status = $statusColors[$table->status] ?? ['bg' => 'bg-slate-50 border-slate-100', 'text' => 'text-slate-700', 'dot' => 'bg-slate-500', 'label' => 'N/A'];
            @endphp
            <div class="flex flex-col bg-white rounded-[2.5rem] border border-slate-200 shadow-sm overflow-hidden group hover:shadow-xl hover:shadow-slate-200/50 transition-all duration-500 relative {{ !$table->is_active ? 'opacity-75' : '' }}">
                
                {{-- Card Header --}}
                <div class="p-6 pb-4 flex items-start justify-between border-b border-slate-100/60 bg-slate-50/50">
                    <div>
                        <span class="px-2.5 py-1 bg-white border border-slate-150 text-[10px] font-black text-slate-500 rounded-lg uppercase tracking-wider">
                            {{ $table->type }}
                        </span>
                        <h3 class="text-xl font-black text-slate-900 mt-2">Meja {{ $table->number }}</h3>
                        <p class="text-xs text-slate-400 font-medium mt-0.5">{{ $table->name ?: 'Tanpa Label Khusus' }}</p>
                    </div>

                    <div class="flex gap-1">
                        <button wire:click="showQr({{ $table->id }})" class="p-2 bg-white hover:bg-slate-100 text-slate-400 hover:text-brand rounded-xl shadow-sm border border-slate-100 transition" title="Lihat QR Code">
                            <i data-lucide="qr-code" class="w-4 h-4"></i>
                        </button>
                        <a href="{{ route('admin.tables.qr.download', $table->id) }}" class="p-2 bg-white hover:bg-slate-100 text-slate-400 hover:text-brand rounded-xl shadow-sm border border-slate-100 transition" title="Download QR PDF">
                            <i data-lucide="download" class="w-4 h-4"></i>
                        </a>
                        <button wire:click="openEdit({{ $table->id }})" class="p-2 bg-white hover:bg-slate-100 text-slate-400 hover:text-blue-500 rounded-xl shadow-sm border border-slate-100 transition" title="Edit Meja">
                            <i data-lucide="pencil" class="w-4 h-4"></i>
                        </button>
                        <button wire:click="delete({{ $table->id }})" onclick="return confirm('Hapus meja ini?')" class="p-2 bg-white hover:bg-slate-100 text-slate-400 hover:text-red-500 rounded-xl shadow-sm border border-slate-100 transition" title="Hapus Meja">
                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                        </button>
                    </div>
                </div>

                {{-- Card Body --}}
                <div class="p-6 flex-1 flex flex-col justify-between">
                    <div class="space-y-4 mb-6">
                        {{-- Info --}}
                        <div class="flex items-center gap-3">
                            <div class="p-2 bg-slate-50 text-slate-400 rounded-xl border border-slate-100">
                                <i data-lucide="users" class="w-4 h-4"></i>
                            </div>
                            <div>
                                <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest leading-none">Kapasitas</p>
                                <p class="text-sm font-bold text-slate-800 mt-1">{{ $table->capacity }} Orang</p>
                            </div>
                        </div>

                        {{-- Current Status Badge --}}
                        <div class="flex items-center gap-3">
                            <div class="p-2 bg-slate-50 text-slate-400 rounded-xl border border-slate-100">
                                <i data-lucide="info" class="w-4 h-4"></i>
                            </div>
                            <div>
                                <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest leading-none">Status</p>
                                <div class="flex items-center gap-2 mt-1 px-3 py-1 rounded-lg border w-fit {{ $status['bg'] }} {{ $status['text'] }}">
                                    <span class="w-1.5 h-1.5 rounded-full {{ $status['dot'] }}"></span>
                                    <span class="text-xs font-black uppercase tracking-wider">{{ $status['label'] }}</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Quick Action Status --}}
                    <div class="pt-4 border-t border-slate-100/60">
                        <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-3">Ubah Status Cepat</p>
                        <div class="grid grid-cols-3 gap-1.5">
                            <button wire:click="updateStatus({{ $table->id }}, 'available')"
                                class="py-2.5 rounded-xl border text-[10px] font-black uppercase tracking-wider transition {{ $table->status === 'available' ? 'bg-emerald-500 border-emerald-500 text-white shadow-lg shadow-emerald-500/20' : 'bg-slate-50 hover:bg-slate-100 border-slate-200 text-slate-600' }}">
                                Buka
                            </button>
                            <button wire:click="updateStatus({{ $table->id }}, 'occupied')"
                                class="py-2.5 rounded-xl border text-[10px] font-black uppercase tracking-wider transition {{ $table->status === 'occupied' ? 'bg-amber-500 border-amber-500 text-white shadow-lg shadow-amber-500/20' : 'bg-slate-50 hover:bg-slate-100 border-slate-200 text-slate-600' }}">
                                Isi
                            </button>
                            <button wire:click="updateStatus({{ $table->id }}, 'reserved')"
                                class="py-2.5 rounded-xl border text-[10px] font-black uppercase tracking-wider transition {{ $table->status === 'reserved' ? 'bg-blue-500 border-blue-500 text-white shadow-lg shadow-blue-500/20' : 'bg-slate-50 hover:bg-slate-100 border-slate-200 text-slate-600' }}">
                                Pesan
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            @empty
            <div class="col-span-full flex flex-col items-center justify-center py-24 text-slate-200">
                <div class="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mb-4">
                    <i data-lucide="layout" class="w-10 h-10"></i>
                </div>
                <p class="font-black uppercase tracking-widest text-[10px]">Tidak ada meja ditemukan</p>
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
                            <h3 class="text-2xl font-black text-slate-900 tracking-tight">{{ $editingId ? 'Edit Meja' : 'Tambah Meja Baru' }}</h3>
                            <p class="text-sm font-medium text-slate-500">Lengkapi detail penataan meja restoran.</p>
                        </div>
                        <button wire:click="$set('showModal', false)" class="p-3 bg-slate-50 text-slate-400 hover:text-slate-600 rounded-2xl transition">
                            <i data-lucide="x" class="w-6 h-6"></i>
                        </button>
                    </div>

                    <div class="space-y-6">
                        {{-- Number --}}
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Nomor Meja *</label>
                            <input type="text" wire:model="number" required placeholder="Contoh: 01, 12B, VIP-01"
                                class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-bold text-sm transition">
                            @error('number') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                        </div>

                        {{-- Name --}}
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Label Meja (Opsional)</label>
                            <input type="text" wire:model="name" placeholder="Contoh: Dekat Jendela, Pojok Tenang"
                                class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium text-sm transition">
                            @error('name') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                        </div>


                        {{-- Capacity --}}
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Kapasitas Kursi (Orang) *</label>
                            <input type="number" wire:model="capacity" min="1" max="20" required placeholder="2"
                                class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-bold text-sm transition">
                            @error('capacity') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                        </div>

                        {{-- Status --}}
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Status Meja Awal *</label>
                            <select wire:model="status" class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-bold text-sm transition">
                                <option value="available">Tersedia (Buka)</option>
                                <option value="occupied">Terisi (Sedang Digunakan)</option>
                                <option value="reserved">Dipesan (Reservasi)</option>
                            </select>
                            @error('status') <p class="text-xs text-red-500 mt-1">{{ $message }}</p> @enderror
                        </div>

                        {{-- Active Status --}}
                        <div class="pt-4 px-1">
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" wire:model="is_active" class="sr-only peer">
                                <div class="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-500"></div>
                                <span class="ml-3 text-sm font-bold text-slate-700">Meja Aktif (Bisa Dipilih Pelanggan)</span>
                            </label>
                        </div>
                    </div>
                </div>

                <div class="pt-10 flex gap-4 mt-auto">
                    <button wire:click="save()" class="flex-1 py-5 bg-brand text-white rounded-2xl font-black text-lg shadow-2xl shadow-brand/30 hover:opacity-90 transition">
                        <span wire:loading.remove wire:target="save">SIMPAN MEJA</span>
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

    {{-- ===================== MODAL VIEW QR ===================== --}}
    @if($showQrModal)
    <div
        x-data="{ show: @entangle('showQrModal') }"
        x-show="show"
        x-init="$watch('show', value => { if (value) { $nextTick(() => lucide.createIcons()); } })"
        x-transition:enter="transition ease-out duration-300"
        x-transition:enter-start="opacity-0"
        x-transition:enter-end="opacity-100"
        x-transition:leave="transition ease-in duration-200"
        x-transition:leave-start="opacity-100"
        x-transition:leave-end="opacity-0"
        class="fixed inset-0 z-[60] bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4"
        style="display: none;">
        <div
            x-show="show"
            x-transition:enter="transition ease-out duration-300"
            x-transition:enter-start="scale-95 opacity-0"
            x-transition:enter-end="scale-100 opacity-100"
            x-transition:leave="transition ease-in duration-200"
            x-transition:leave-start="scale-100 opacity-100"
            x-transition:leave-end="scale-95 opacity-0"
            @click.away="show = false"
            class="bg-white w-full max-w-md rounded-[2rem] shadow-2xl p-8 overflow-hidden relative border border-slate-100">
            
            <!-- Close Button -->
            <button wire:click="$set('showQrModal', false)" class="absolute top-6 right-6 p-2 bg-slate-50 hover:bg-slate-100 text-slate-400 hover:text-slate-600 rounded-xl transition">
                <i data-lucide="x" class="w-5 h-5"></i>
            </button>

            <!-- Title & Info -->
            <div class="mb-6 pr-10">
                <h3 class="text-2xl font-black text-slate-900 tracking-tight">QR Code Meja {{ $qrTableNumber }}</h3>
                <p class="text-sm font-medium text-slate-400 mt-1">{{ $qrTableName ?: 'Pelanggan dapat memindai untuk langsung memesan menu.' }}</p>
            </div>

            <!-- QR Container -->
            <div class="flex flex-col items-center justify-center bg-[#F8FAFC] rounded-3xl p-8 border border-slate-100 mb-6">
                <div class="bg-white p-6 rounded-3xl shadow-sm border border-slate-150 flex items-center justify-center">
                    {!! \SimpleSoftwareIO\QrCode\Facades\QrCode::size(200)
                        ->color(15, 23, 42)
                        ->backgroundColor(255, 255, 255)
                        ->margin(1)
                        ->generate('https://menuku.icaadrm.my.id/menu?table=' . urlencode($qrTableNumber)) !!}
                </div>
                
                <div class="mt-6 w-full text-center">
                    <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest leading-none">URL Pemesanan</p>
                    <p class="text-xs font-bold text-brand mt-2 break-all bg-white px-4 py-2 border border-slate-150 rounded-xl">
                        https://menuku.icaadrm.my.id/menu?table={{ urlencode($qrTableNumber) }}
                    </p>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="flex gap-3">
                <a href="{{ route('admin.tables.qr.download', $qrTableId) }}" class="flex-1 py-4 bg-brand text-white rounded-xl font-black text-sm shadow-lg shadow-brand/20 hover:opacity-95 transition flex items-center justify-center gap-2">
                    <i data-lucide="download" class="w-4 h-4"></i>
                    <span>UNDUH PDF</span>
                </a>
                <button wire:click="$set('showQrModal', false)" class="px-6 py-4 bg-slate-100 text-slate-600 rounded-xl font-bold text-sm hover:bg-slate-200 transition">
                    TUTUP
                </button>
            </div>
        </div>
    </div>
    @endif
</div>
