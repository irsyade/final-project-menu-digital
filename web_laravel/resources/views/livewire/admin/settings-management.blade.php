<div class="h-full bg-[#f8fafc]" x-data="{ activeTab: @entangle('activeTab') }">
    <!-- Navigation Tabs -->
    <div class="bg-white border-b border-slate-100 px-4 lg:px-6 flex gap-4 lg:gap-6 overflow-x-auto whitespace-nowrap [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none]">
        <button @click="activeTab = 'informasi'" 
                :class="activeTab === 'informasi' ? 'border-[#E8781A] text-[#E8781A] font-black' : 'border-transparent text-slate-400 font-bold hover:text-slate-600'" 
                class="py-2.5 border-b-2 text-sm transition outline-none">
            Informasi
        </button>
        <button @click="activeTab = 'operasional'" 
                :class="activeTab === 'operasional' ? 'border-[#E8781A] text-[#E8781A] font-black' : 'border-transparent text-slate-400 font-bold hover:text-slate-600'" 
                class="py-2.5 border-b-2 text-sm transition outline-none">
            Jam Oprasional
        </button>
        <button @click="activeTab = 'pembayaran'" 
                :class="activeTab === 'pembayaran' ? 'border-[#E8781A] text-[#E8781A] font-black' : 'border-transparent text-slate-400 font-bold hover:text-slate-600'" 
                class="py-2.5 border-b-2 text-sm transition outline-none">
            Pembayaran
        </button>
        <button @click="activeTab = 'tema'" 
                :class="activeTab === 'tema' ? 'border-[#E8781A] text-[#E8781A] font-black' : 'border-transparent text-slate-400 font-bold hover:text-slate-600'" 
                class="py-2.5 border-b-2 text-sm transition outline-none">
            Tema & warna Menu
        </button>
    </div>

    <!-- Success Toast Alert -->
    @if (session()->has('success'))
        <div class="mx-4 lg:mx-6 mt-4 p-4 bg-emerald-50 border border-emerald-100 rounded-2xl flex items-center gap-3 text-emerald-800 animate-in fade-in slide-in-from-top duration-300">
            <i data-lucide="check-circle" class="w-5 h-5 text-emerald-500 shrink-0"></i>
            <span class="text-sm font-black">{{ session('success') }}</span>
        </div>
    @endif

    <!-- Content Body -->
    <div class="p-2 lg:p-3">
        <!-- TAB 1: Informasi -->
        <div x-show="activeTab === 'informasi'" class="animate-in fade-in duration-300">
            <form wire:submit.prevent="save" class="space-y-6">
                <!-- Top Row with Title and Button -->
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <h2 class="text-2xl font-black text-slate-800 tracking-tight">Informasi Restoran</h2>
                    <button type="submit" 
                            class="w-full sm:w-auto px-8 py-3 bg-[#E8781A] text-white font-black rounded-full text-sm shadow-lg shadow-orange-500/20 hover:scale-[1.02] active:scale-95 transition-all">
                        Simpan Perubahan
                    </button>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    <!-- Left: Logo Upload -->
                    <div class="space-y-2">
                        <label class="block text-sm font-bold text-slate-700">Logo Restoran</label>
                        <div class="w-full h-56 bg-slate-50 border-2 border-dashed border-slate-200 rounded-3xl flex flex-col items-center justify-center relative overflow-hidden group hover:border-[#E8781A] transition duration-300">
                            @if ($new_logo)
                                <img src="{{ $new_logo->temporaryUrl() }}" class="w-full h-full object-contain p-4">
                            @elseif ($setting->site_logo)
                                <img src="{{ Storage::url($setting->site_logo) }}" class="w-full h-full object-contain p-4">
                            @else
                                <div class="flex flex-col items-center justify-center text-center p-4">
                                    <div class="w-12 h-12 bg-orange-50 rounded-2xl flex items-center justify-center mb-3">
                                        <i data-lucide="upload-cloud" class="w-6 h-6 text-[#E8781A]"></i>
                                    </div>
                                    <span class="text-sm font-black text-slate-700">Upload Logo</span>
                                    <span class="text-xs font-semibold text-slate-400 mt-1 uppercase tracking-wider">PNG, SVG</span>
                                </div>
                            @endif
                            <input type="file" wire:model="new_logo" class="absolute inset-0 opacity-0 cursor-pointer z-10">
                        </div>
                        @error('new_logo') <span class="text-red-500 text-xs font-bold">{{ $message }}</span> @enderror
                    </div>

                    <!-- Right: Text Inputs -->
                    <div class="lg:col-span-2 space-y-6">
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2">Nama Restoran</label>
                            <input type="text" wire:model="site_name" 
                                   class="w-full px-4 py-3 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-[#E8781A] focus:border-[#E8781A] outline-none font-bold text-slate-800 transition duration-300">
                            @error('site_name') <span class="text-red-500 text-xs font-bold">{{ $message }}</span> @enderror
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2">Nama Pemilik Restoran</label>
                            <input type="text" wire:model="owner_name" 
                                   class="w-full px-4 py-3 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-[#E8781A] focus:border-[#E8781A] outline-none font-bold text-slate-800 transition duration-300">
                            @error('owner_name') <span class="text-red-500 text-xs font-bold">{{ $message }}</span> @enderror
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2">Alamat Lengkap</label>
                            <textarea wire:model="address" rows="3"
                                      class="w-full px-4 py-3 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-[#E8781A] focus:border-[#E8781A] outline-none font-bold text-slate-800 transition duration-300"></textarea>
                            @error('address') <span class="text-red-500 text-xs font-bold">{{ $message }}</span> @enderror
                        </div>
                    </div>
                </div>

                <!-- Phone and Email Row -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label class="block text-sm font-bold text-slate-700 mb-2">Nomor Telepon</label>
                        <input type="text" wire:model="phone" 
                               class="w-full px-4 py-3 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-[#E8781A] focus:border-[#E8781A] outline-none font-bold text-slate-800 transition duration-300">
                        @error('phone') <span class="text-red-500 text-xs font-bold">{{ $message }}</span> @enderror
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-slate-700 mb-2">Email Restoran</label>
                        <input type="email" wire:model="email" 
                               class="w-full px-4 py-3 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-[#E8781A] focus:border-[#E8781A] outline-none font-bold text-slate-800 transition duration-300">
                        @error('email') <span class="text-red-500 text-xs font-bold">{{ $message }}</span> @enderror
                    </div>
                </div>

                <!-- Short Description -->
                <div>
                    <label class="block text-sm font-bold text-slate-700 mb-2">Deskripsi Singkat</label>
                    <textarea wire:model="description" rows="3"
                              class="w-full px-4 py-3 bg-white border border-slate-200 rounded-2xl focus:ring-2 focus:ring-[#E8781A] focus:border-[#E8781A] outline-none font-bold text-slate-800 transition duration-300"></textarea>
                    @error('description') <span class="text-red-500 text-xs font-bold">{{ $message }}</span> @enderror
                </div>

                <!-- Advanced Options Link / Collapsible for favicon / login bg -->
                <div class="pt-6 border-t border-slate-100" x-data="{ open: false }">
                    <button type="button" @click="open = !open" class="flex items-center gap-2 text-xs font-black text-[#E8781A] uppercase tracking-wider hover:underline outline-none">
                        <i data-lucide="settings-2" class="w-4 h-4"></i>
                        <span>Opsi Branding Tambahan (Favicon & Background Halaman Login)</span>
                        <i :class="open ? 'rotate-180' : ''" data-lucide="chevron-down" class="w-4 h-4 transition duration-300"></i>
                    </button>
                    
                    <div x-show="open" x-transition class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6 animate-in fade-in duration-300">
                        <!-- Favicon -->
                        <div class="space-y-2">
                            <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider">Browser Favicon</label>
                            <div class="w-full h-36 bg-slate-50 border border-dashed border-slate-200 rounded-2xl flex flex-col items-center justify-center relative overflow-hidden group hover:border-[#E8781A] transition">
                                @if ($new_favicon)
                                    <img src="{{ $new_favicon->temporaryUrl() }}" class="w-12 h-12 object-contain">
                                @elseif ($setting->site_favicon)
                                    <img src="{{ Storage::url($setting->site_favicon) }}" class="w-12 h-12 object-contain">
                                @else
                                    <i data-lucide="layout" class="w-6 h-6 text-slate-400 mb-2"></i>
                                    <span class="text-[10px] font-bold text-slate-400">Pilih Favicon</span>
                                @endif
                                <input type="file" wire:model="new_favicon" class="absolute inset-0 opacity-0 cursor-pointer">
                            </div>
                        </div>

                        <!-- Login BG -->
                        <div class="space-y-2">
                            <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider">Background Login Portal</label>
                            <div class="w-full h-36 bg-slate-50 border border-dashed border-slate-200 rounded-2xl flex flex-col items-center justify-center relative overflow-hidden group hover:border-[#E8781A] transition">
                                @if ($new_login_background)
                                    <img src="{{ $new_login_background->temporaryUrl() }}" class="w-full h-full object-cover">
                                @elseif ($setting->login_background)
                                    <img src="{{ Storage::url($setting->login_background) }}" class="w-full h-full object-cover">
                                @else
                                    <i data-lucide="image" class="w-6 h-6 text-slate-400 mb-2"></i>
                                    <span class="text-[10px] font-bold text-slate-400">Pilih Background Halaman Login</span>
                                @endif
                                <input type="file" wire:model="new_login_background" class="absolute inset-0 opacity-0 cursor-pointer">
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>

        <!-- TAB 2: Jam Operasional -->
        <div x-show="activeTab === 'operasional'" class="animate-in fade-in duration-300">
            <div class="bg-white border border-slate-100 rounded-3xl sm:rounded-[2rem] p-4 sm:p-6 shadow-sm">
                <form wire:submit.prevent="save" class="space-y-6">
                    <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-4 gap-4">
                        <h2 class="text-2xl font-black text-slate-800 tracking-tight">Jam Operasional</h2>
                        <button type="submit" 
                                class="w-full sm:w-auto px-8 py-3 bg-[#E8781A] text-white font-black rounded-full text-sm shadow-lg shadow-orange-500/20 hover:scale-[1.02] active:scale-95 transition-all">
                            Simpan Perubahan
                        </button>
                    </div>

                    <div class="space-y-4">
                        @foreach ($operational_hours as $index => $hour)
                            <div class="flex flex-col sm:flex-row sm:items-center justify-between p-4 bg-slate-50 border border-slate-100 rounded-2xl gap-4">
                                <span class="text-sm font-black text-slate-700 w-24">{{ $hour['day'] }}</span>
                                
                                <div class="flex items-center gap-3">
                                    <input type="time" wire:model="operational_hours.{{ $index }}.open" 
                                           class="px-4 py-2 bg-white border border-slate-200 rounded-xl text-xs font-bold outline-none focus:ring-2 focus:ring-[#E8781A]"
                                           @if($hour['is_closed']) disabled @endif>
                                    <span class="text-slate-400 font-bold">-</span>
                                    <input type="time" wire:model="operational_hours.{{ $index }}.close" 
                                           class="px-4 py-2 bg-white border border-slate-200 rounded-xl text-xs font-bold outline-none focus:ring-2 focus:ring-[#E8781A]"
                                           @if($hour['is_closed']) disabled @endif>
                                </div>

                                <!-- Toggle Switch Libur -->
                                <div class="flex items-center gap-3">
                                    <label class="relative inline-flex items-center cursor-pointer">
                                        <input type="checkbox" wire:model="operational_hours.{{ $index }}.is_closed" class="sr-only peer">
                                        <div class="w-12 h-6 bg-slate-200 rounded-full peer peer-focus:ring-0 after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#EF4444] peer-checked:after:translate-x-full"></div>
                                    </label>
                                    <span class="text-xs font-bold text-slate-400 uppercase tracking-wider">Libur</span>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </form>
            </div>
        </div>

        <!-- TAB 3: Pembayaran -->
        <div x-show="activeTab === 'pembayaran'" class="animate-in fade-in duration-300">
            <form wire:submit.prevent="save" class="space-y-8">
                <!-- Header -->
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <h2 class="text-2xl font-black text-slate-800 tracking-tight">Metode Pembayaran</h2>
                    <button type="submit" 
                            class="w-full sm:w-auto px-8 py-3 bg-[#E8781A] text-white font-black rounded-full text-sm shadow-lg shadow-orange-500/20 hover:scale-[1.02] active:scale-95 transition-all">
                        Simpan Perubahan
                    </button>
                </div>

                <!-- Payment Methods Grid -->
                <div class="bg-white border border-slate-100 rounded-3xl sm:rounded-[2rem] p-4 sm:p-6 shadow-sm space-y-6">
                    <!-- 1. Tunai -->
                    <div class="flex items-center justify-between p-6 bg-slate-50 rounded-3xl border border-slate-100">
                        <div class="flex items-center gap-4">
                            <div class="w-12 h-12 bg-emerald-50 rounded-2xl flex items-center justify-center text-emerald-500 border border-emerald-100">
                                <i data-lucide="wallet" class="w-6 h-6"></i>
                            </div>
                            <span class="text-sm font-black text-slate-700">Tunai (Cash)</span>
                        </div>
                        <label class="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" wire:model="is_cash_active" class="sr-only peer">
                            <div class="w-14 h-8 bg-slate-200 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[4px] after:start-[4px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-[#E8781A]"></div>
                        </label>
                    </div>

                    <!-- 2. QRIS -->
                    <div class="space-y-4">
                        <div class="flex items-center justify-between p-6 bg-slate-50 rounded-3xl border border-slate-100">
                            <div class="flex items-center gap-4">
                                <div class="w-12 h-12 bg-blue-50 rounded-2xl flex items-center justify-center text-blue-500 border border-blue-100">
                                    <i data-lucide="qr-code" class="w-6 h-6"></i>
                                </div>
                                <span class="text-sm font-black text-slate-700">QRIS</span>
                            </div>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" wire:model="is_qris_active" class="sr-only peer">
                                <div class="w-14 h-8 bg-slate-200 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[4px] after:start-[4px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-[#E8781A]"></div>
                            </label>
                        </div>
                        
                        <!-- Conditional QRIS upload -->
                        <div x-show="$wire.is_qris_active" x-transition class="p-6 bg-white border border-slate-100 rounded-3xl grid grid-cols-1 md:grid-cols-3 gap-6 animate-in fade-in">
                            <div>
                                <label class="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">QRIS Official Code Image</label>
                                <div class="relative w-full aspect-square bg-slate-50 rounded-2xl border-2 border-dashed border-slate-200 flex items-center justify-center overflow-hidden hover:border-[#E8781A] transition">
                                    @if ($new_qris_image)
                                        <img src="{{ $new_qris_image->temporaryUrl() }}" class="w-full h-full object-contain p-4">
                                    @elseif ($setting->qris_image)
                                        <img src="{{ Storage::url($setting->qris_image) }}" class="w-full h-full object-contain p-4">
                                    @else
                                        <div class="flex flex-col items-center gap-2 text-slate-400">
                                            <i data-lucide="upload" class="w-8 h-8"></i>
                                            <span class="text-[10px] font-bold">Upload QRIS</span>
                                        </div>
                                    @endif
                                    <input type="file" wire:model="new_qris_image" class="absolute inset-0 opacity-0 cursor-pointer">
                                </div>
                            </div>
                            <div class="md:col-span-2 flex items-center">
                                <p class="text-xs font-semibold text-slate-500 leading-relaxed bg-slate-50 p-6 rounded-2xl border border-slate-100">
                                    Unggah gambar QRIS official merchant Anda. Gambar ini akan ditampilkan di HP pelanggan saat melakukan pembayaran via QRIS secara dinamis.
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- 3. Transfer Bank -->
                    <div class="space-y-4">
                        <div class="flex items-center justify-between p-6 bg-slate-50 rounded-3xl border border-slate-100">
                            <div class="flex items-center gap-4">
                                <div class="w-12 h-12 bg-purple-50 rounded-2xl flex items-center justify-center text-purple-500 border border-purple-100">
                                    <i data-lucide="credit-card" class="w-6 h-6"></i>
                                </div>
                                <span class="text-sm font-black text-slate-700">Transfer Bank</span>
                            </div>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" wire:model="is_transfer_active" class="sr-only peer">
                                <div class="w-14 h-8 bg-slate-200 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[4px] after:start-[4px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-[#E8781A]"></div>
                            </label>
                        </div>
                        
                        <!-- Conditional Bank Details fields -->
                        <div x-show="$wire.is_transfer_active" x-transition class="p-6 bg-white border border-slate-100 rounded-3xl space-y-4 animate-in fade-in">
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                                <div>
                                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Nama Bank</label>
                                    <input type="text" wire:model="bank_name" placeholder="Contoh: Bank Central Asia (BCA)"
                                           class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold outline-none focus:ring-2 focus:ring-[#E8781A]">
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Nomor Rekening</label>
                                    <input type="text" wire:model="account_number" placeholder="Contoh: 1234567890"
                                           class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold outline-none focus:ring-2 focus:ring-[#E8781A]">
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Nama Pemilik</label>
                                    <input type="text" wire:model="account_name" placeholder="Contoh: Flavora Kitchen"
                                           class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold outline-none focus:ring-2 focus:ring-[#E8781A]">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Quick Amount Section -->
                <div class="bg-white border border-slate-100 rounded-3xl sm:rounded-[2.5rem] p-6 sm:p-10 shadow-sm space-y-6">
                    <h3 class="text-lg font-black text-slate-800 tracking-tight">Nominal Cepat (Quick Amount)</h3>
                    
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                        @for ($i = 0; $i < 4; $i++)
                            <div class="relative bg-slate-50 border border-slate-150 rounded-2xl px-4 py-3 flex items-center gap-2">
                                <span class="text-xs font-bold text-slate-400 select-none">Rp</span>
                                <input type="number" wire:model="quick_amounts.{{ $i }}" 
                                       class="w-full bg-transparent outline-none font-bold text-slate-800 text-sm focus:ring-0 border-none p-0">
                            </div>
                        @endfor
                    </div>
                </div>
            </form>
        </div>

        <!-- TAB 4: Tema & warna Menu -->
        <div x-show="activeTab === 'tema'" class="animate-in fade-in duration-300">
            <form wire:submit.prevent="save" class="space-y-8">
                <!-- Header -->
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <h2 class="text-2xl font-black text-slate-800 tracking-tight">Tema & warna Menu</h2>
                    <button type="submit" 
                            class="w-full sm:w-auto px-8 py-3 bg-[#E8781A] text-white font-black rounded-full text-sm shadow-lg shadow-orange-500/20 hover:scale-[1.02] active:scale-95 transition-all">
                        Simpan Perubahan
                    </button>
                </div>

                <!-- Theme Control and Live Preview Grid -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 lg:gap-10">
                    <!-- Left: Control Area -->
                    <div class="space-y-6">
                        <!-- Theme Colors Card -->
                        <div class="bg-white border border-slate-100 rounded-3xl sm:rounded-[2rem] p-4 sm:p-6 shadow-sm space-y-8">
                            <div>
                                <h3 class="text-lg font-black text-slate-800 tracking-tight mb-4">Tema Menu Digital</h3>
                                
                                <label class="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Rekomendasi</label>
                                <div class="flex flex-wrap items-center gap-3">
                                    @foreach ([
                                        '#E8781A' => 'bg-[#E8781A]', // Mockup original orange
                                        '#10B981' => 'bg-[#10B981]', // Green
                                        '#3B82F6' => 'bg-[#3B82F6]', // Blue
                                        '#8B5CF6' => 'bg-[#8B5CF6]', // Purple
                                        '#EC4899' => 'bg-[#EC4899]', // Pink
                                        '#EF4444' => 'bg-[#EF4444]'  // Red
                                    ] as $hex => $bgColorClass)
                                        <button type="button" 
                                                wire:click="selectColorPreset('{{ $hex }}')"
                                                class="w-10 h-10 rounded-full {{ $bgColorClass }} border-2 border-white shadow-md flex items-center justify-center transition-all hover:scale-110 relative outline-none">
                                            @if ($primary_color === $hex)
                                                <i data-lucide="check" class="w-4 h-4 text-white drop-shadow-md"></i>
                                            @endif
                                        </button>
                                    @endforeach
                                </div>
                            </div>

                            <div class="pt-6 border-t border-slate-100">
                                <label class="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Costume Warna</label>
                                <div class="flex items-center gap-4">
                                    <!-- Color Indicator Circle -->
                                    <div class="w-12 h-12 rounded-full border border-slate-200 shadow-inner flex items-center justify-center relative overflow-hidden" 
                                         style="background-color: {{ $primary_color }}">
                                        <input type="color" wire:model.live="primary_color" class="absolute inset-0 w-[200%] h-[200%] -top-1/2 -left-1/2 opacity-0 cursor-pointer">
                                    </div>
                                    
                                    <!-- Hex Text Box -->
                                    <div class="relative w-36 bg-slate-50 border border-slate-200 rounded-2xl px-5 py-3">
                                        <input type="text" wire:model.live="primary_color" 
                                               class="w-full bg-transparent outline-none font-bold text-slate-800 uppercase text-sm border-none p-0">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right: Live Mockup Preview -->
                    <div class="space-y-6">
                        <div class="bg-white border border-slate-100 rounded-3xl sm:rounded-[2rem] p-4 sm:p-6 shadow-sm space-y-6">
                            <h3 class="text-lg font-black text-slate-800 tracking-tight">Preview Tampilan Menu</h3>

                            <!-- Mockup Container -->
                            <div class="border border-slate-150 rounded-3xl overflow-hidden shadow-inner max-w-sm mx-auto">
                                <!-- Phone Header (Digital Menu Style) -->
                                <div class="text-white px-6 py-5 flex items-center gap-3 transition-colors duration-500" 
                                     style="background-color: {{ $primary_color }}">
                                    <!-- Initial Logo Badge -->
                                    <div class="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center font-bold text-white uppercase shadow-sm">
                                        {{ substr($site_name, 0, 1) }}
                                    </div>
                                    <div>
                                        <h4 class="font-black text-sm tracking-tight leading-none">{{ $site_name }}</h4>
                                        <span class="text-[9px] font-bold text-white/70 tracking-widest uppercase">Digital Menu</span>
                                    </div>
                                </div>

                                <!-- Menu Items list -->
                                <div class="bg-slate-50 p-6 space-y-4">
                                    <!-- Item 1 -->
                                    <div class="bg-white p-4 rounded-2xl border border-slate-100 flex items-center justify-between shadow-sm">
                                        <div class="text-left">
                                            <h5 class="text-xs font-black text-slate-700">Ayam Bakar Spesial</h5>
                                        </div>
                                        <span class="text-xs font-black transition-colors duration-500" style="color: {{ $primary_color }}">
                                            Rp 45K
                                        </span>
                                    </div>

                                    <!-- Item 2 -->
                                    <div class="bg-white p-4 rounded-2xl border border-slate-100 flex items-center justify-between shadow-sm">
                                        <div class="text-left">
                                            <h5 class="text-xs font-black text-slate-700">Nasi Goreng Kampung</h5>
                                        </div>
                                        <span class="text-xs font-black transition-colors duration-500" style="color: {{ $primary_color }}">
                                            Rp 45K
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

@script
<script>
    $wire.on('settings-saved', () => {
        lucide.createIcons();
    });
    document.addEventListener('livewire:navigated', () => {
        lucide.createIcons();
    });
    lucide.createIcons();
</script>
@endscript
