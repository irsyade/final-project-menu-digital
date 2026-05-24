@extends('layouts.admin')

@section('title', 'Pengaturan')
@section('page_title', 'Pengaturan Sistem')

@section('content')
<div class="flex flex-col lg:flex-row gap-10 h-full" x-data="{ activeTab: 'profil' }">
    <!-- Sidebar Tabs (Left) -->
    <div class="lg:w-72 space-y-2">
        <button @click="activeTab = 'profil'" :class="activeTab === 'profil' ? 'bg-brand text-white' : 'bg-white text-slate-500 hover:bg-slate-50'" class="w-full flex items-center gap-3 px-6 py-4 rounded-2xl font-bold text-sm transition shadow-sm">
            <i data-lucide="store" class="w-5 h-5"></i>
            <span>Profil Restoran</span>
        </button>
        <button @click="activeTab = 'operasional'" :class="activeTab === 'operasional' ? 'bg-brand text-white' : 'bg-white text-slate-500 hover:bg-slate-50'" class="w-full flex items-center gap-3 px-6 py-4 rounded-2xl font-bold text-sm transition shadow-sm">
            <i data-lucide="clock" class="w-5 h-5"></i>
            <span>Jam Operasional</span>
        </button>
        <button @click="activeTab = 'pembayaran'" :class="activeTab === 'pembayaran' ? 'bg-brand text-white' : 'bg-white text-slate-500 hover:bg-slate-50'" class="w-full flex items-center gap-3 px-6 py-4 rounded-2xl font-bold text-sm transition shadow-sm">
            <i data-lucide="credit-card" class="w-5 h-5"></i>
            <span>Metode Pembayaran</span>
        </button>
        <button @click="activeTab = 'notifikasi'" :class="activeTab === 'notifikasi' ? 'bg-brand text-white' : 'bg-white text-slate-500 hover:bg-slate-50'" class="w-full flex items-center gap-3 px-6 py-4 rounded-2xl font-bold text-sm transition shadow-sm">
            <i data-lucide="bell" class="w-5 h-5"></i>
            <span>Notifikasi</span>
        </button>
        <button @click="activeTab = 'akun'" :class="activeTab === 'akun' ? 'bg-brand text-white' : 'bg-white text-slate-500 hover:bg-slate-50'" class="w-full flex items-center gap-3 px-6 py-4 rounded-2xl font-bold text-sm transition shadow-sm">
            <i data-lucide="user-cog" class="w-5 h-5"></i>
            <span>Akun Admin</span>
        </button>
        <button @click="activeTab = 'subadmin'" :class="activeTab === 'subadmin' ? 'bg-brand text-white' : 'bg-white text-slate-500 hover:bg-slate-50'" class="w-full flex items-center gap-3 px-6 py-4 rounded-2xl font-bold text-sm transition shadow-sm">
            <i data-lucide="users" class="w-5 h-5"></i>
            <span>Sub-Admin / Kasir</span>
        </button>
    </div>

    <!-- Content (Right) -->
    <div class="flex-1">
        <!-- 1. Profil Restoran -->
        <div x-show="activeTab === 'profil'" class="bg-white rounded-[2.5rem] border border-slate-200 shadow-sm overflow-hidden animate-in fade-in duration-500">
            <div class="p-10">
                <h3 class="text-xl font-black text-slate-900 mb-8 tracking-tight">Profil Restoran</h3>
                <form onsubmit="handleSave(event)" class="space-y-8">
                    <div class="flex flex-col md:flex-row gap-10">
                        <div class="w-full md:w-48">
                            <label class="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-4">Logo Resto</label>
                            <div class="relative group cursor-pointer">
                                <div class="w-40 h-40 bg-slate-50 border-2 border-dashed border-slate-200 rounded-[2rem] flex flex-col items-center justify-center gap-2 group-hover:border-brand transition">
                                    <i data-lucide="camera" class="w-10 h-10 text-slate-300 group-hover:text-brand"></i>
                                    <span class="text-[9px] font-black text-slate-400 group-hover:text-brand uppercase tracking-widest">Ganti Logo</span>
                                </div>
                            </div>
                        </div>
                        <div class="flex-1 space-y-6">
                            <div>
                                <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Nama Restoran</label>
                                <input type="text" value="MenuKu Resto & Cafe" class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium">
                            </div>
                            <div>
                                <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Tagline / Deskripsi Singkat</label>
                                <input type="text" value="Sajian lezat dengan pelayanan digital tercepat." class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium">
                            </div>
                        </div>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Alamat Lengkap</label>
                            <textarea rows="3" class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium">Jl. Digital Raya No. 404, Jakarta Selatan</textarea>
                        </div>
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Nomor Telepon / WhatsApp</label>
                            <input type="text" value="081234567890" class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand outline-none font-medium">
                        </div>
                    </div>
                    <button type="submit" class="px-10 py-4 bg-brand text-white rounded-2xl font-black text-sm shadow-lg shadow-brand/20 hover:scale-[1.02] active:scale-95 transition">SIMPAN PERUBAHAN</button>
                </form>
            </div>
        </div>

        <!-- 2. Jam Operasional -->
        <div x-show="activeTab === 'operasional'" class="bg-white rounded-[2.5rem] border border-slate-200 shadow-sm overflow-hidden animate-in fade-in duration-500">
            <div class="p-10">
                <h3 class="text-xl font-black text-slate-900 mb-8 tracking-tight">Jam Operasional</h3>
                <form onsubmit="handleSave(event)" class="space-y-4">
                    @foreach(['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'] as $hari)
                    <div class="flex items-center justify-between p-4 bg-slate-50 rounded-2xl border border-slate-100">
                        <div class="flex items-center gap-4 w-32">
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" checked class="sr-only peer">
                                <div class="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-brand"></div>
                            </label>
                            <span class="text-sm font-black text-slate-700">{{ $hari }}</span>
                        </div>
                        <div class="flex items-center gap-3">
                            <input type="time" value="09:00" class="px-4 py-2 bg-white border border-slate-200 rounded-xl text-xs font-bold outline-none">
                            <span class="text-slate-400 font-bold">-</span>
                            <input type="time" value="22:00" class="px-4 py-2 bg-white border border-slate-200 rounded-xl text-xs font-bold outline-none">
                        </div>
                    </div>
                    @endforeach
                    <button type="submit" class="mt-6 px-10 py-4 bg-brand text-white rounded-2xl font-black text-sm shadow-lg shadow-brand/20 hover:scale-[1.02] active:scale-95 transition">SIMPAN JADWAL</button>
                </form>
            </div>
        </div>

        <!-- 3. Metode Pembayaran -->
        <div x-show="activeTab === 'pembayaran'" class="bg-white rounded-[2.5rem] border border-slate-200 shadow-sm overflow-hidden animate-in fade-in duration-500">
            <div class="p-10">
                <h3 class="text-xl font-black text-slate-900 mb-8 tracking-tight">Metode Pembayaran</h3>
                <div class="space-y-4">
                    @foreach(['Tunai / Cash', 'Transfer Bank', 'QRIS (Gopay, OVO, Dana)', 'Kartu Debit / Kredit'] as $method)
                    <div class="flex items-center justify-between p-6 bg-slate-50 rounded-3xl border border-slate-100">
                        <div class="flex items-center gap-4">
                            <div class="w-12 h-12 bg-white rounded-2xl flex items-center justify-center text-slate-400 border border-slate-100">
                                <i data-lucide="{{ $method == 'Tunai / Cash' ? 'banknote' : ($method == 'Transfer Bank' ? 'building-2' : ($method == 'QRIS (Gopay, OVO, Dana)' ? 'qr-code' : 'credit-card')) }}" class="w-6 h-6"></i>
                            </div>
                            <span class="text-sm font-black text-slate-700">{{ $method }}</span>
                        </div>
                        <label class="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" checked class="sr-only peer">
                            <div class="w-14 h-8 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[4px] after:start-[4px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-emerald-500"></div>
                        </label>
                    </div>
                    @endforeach
                </div>
            </div>
        </div>

        <!-- 4. Notifikasi -->
        <div x-show="activeTab === 'notifikasi'" class="bg-white rounded-[2.5rem] border border-slate-200 shadow-sm overflow-hidden animate-in fade-in duration-500">
            <div class="p-10">
                <h3 class="text-xl font-black text-slate-900 mb-8 tracking-tight">Preferensi Notifikasi</h3>
                <div class="space-y-6">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-bold text-slate-800">Pesanan Baru</p>
                            <p class="text-xs text-slate-500">Berikan suara notifikasi saat ada pesanan masuk.</p>
                        </div>
                        <input type="checkbox" checked class="w-6 h-6 rounded-lg border-slate-300 text-brand focus:ring-brand">
                    </div>
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-bold text-slate-800">Stok Menu Habis</p>
                            <p class="text-xs text-slate-500">Ingatkan jika ada item yang stoknya kritis.</p>
                        </div>
                        <input type="checkbox" checked class="w-6 h-6 rounded-lg border-slate-300 text-brand focus:ring-brand">
                    </div>
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-bold text-slate-800">Promo Kadaluarsa</p>
                            <p class="text-xs text-slate-500">Notifikasi 1 hari sebelum promo berakhir.</p>
                        </div>
                        <input type="checkbox" class="w-6 h-6 rounded-lg border-slate-300 text-brand focus:ring-brand">
                    </div>
                </div>
            </div>
        </div>

        <!-- 5. Akun Admin -->
        <div x-show="activeTab === 'akun'" class="bg-white rounded-[2.5rem] border border-slate-200 shadow-sm overflow-hidden animate-in fade-in duration-500">
            <div class="p-10">
                <h3 class="text-xl font-black text-slate-900 mb-8 tracking-tight">Keamanan Akun</h3>
                <form onsubmit="handleSave(event)" class="space-y-6 max-w-md">
                    <div>
                        <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Email Admin</label>
                        <input type="email" value="admin@menuku.app" class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl outline-none font-medium">
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Password Baru</label>
                        <input type="password" placeholder="••••••••" class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl outline-none font-medium">
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-slate-700 mb-2 px-1">Konfirmasi Password Baru</label>
                        <input type="password" placeholder="••••••••" class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl outline-none font-medium">
                    </div>
                    <button type="submit" class="w-full py-5 bg-slate-900 text-white rounded-[1.5rem] font-black text-lg shadow-2xl shadow-slate-900/20 hover:bg-brand transition">UPDATE PASSWORD</button>
                </form>
            </div>
        </div>

        <!-- 6. Sub-Admin -->
        <div x-show="activeTab === 'subadmin'" class="bg-white rounded-[2.5rem] border border-slate-200 shadow-sm overflow-hidden animate-in fade-in duration-500">
            <div class="p-10">
                <div class="flex items-center justify-between mb-8">
                    <h3 class="text-xl font-black text-slate-900 tracking-tight">Akun Sub-Admin / Kasir</h3>
                    <button class="px-4 py-2 bg-brand text-white rounded-xl text-xs font-black uppercase tracking-widest">+ Akun Baru</button>
                </div>
                <div class="space-y-4">
                    <!-- User 1 -->
                    <div class="flex items-center justify-between p-5 bg-slate-50 rounded-3xl border border-slate-100">
                        <div class="flex items-center gap-4">
                            <div class="w-12 h-12 bg-white rounded-2xl flex items-center justify-center text-brand border border-slate-200 font-black text-lg">
                                K1
                            </div>
                            <div>
                                <p class="text-sm font-black text-slate-900">Kasir Lantai 1</p>
                                <p class="text-[10px] font-bold text-slate-400 uppercase tracking-widest">kasir1@menuku.app</p>
                            </div>
                        </div>
                        <button onclick="confirm('Hapus akun ini?')" class="p-2 text-slate-300 hover:text-red-500 transition"><i data-lucide="trash-2" class="w-5 h-5"></i></button>
                    </div>
                    <!-- User 2 -->
                    <div class="flex items-center justify-between p-5 bg-slate-50 rounded-3xl border border-slate-100">
                        <div class="flex items-center gap-4">
                            <div class="w-12 h-12 bg-white rounded-2xl flex items-center justify-center text-brand border border-slate-200 font-black text-lg">
                                K2
                            </div>
                            <div>
                                <p class="text-sm font-black text-slate-900">Kasir Lantai 2</p>
                                <p class="text-[10px] font-bold text-slate-400 uppercase tracking-widest">kasir2@menuku.app</p>
                            </div>
                        </div>
                        <button onclick="confirm('Hapus akun ini?')" class="p-2 text-slate-300 hover:text-red-500 transition"><i data-lucide="trash-2" class="w-5 h-5"></i></button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Success Toast -->
<div id="successToast" class="fixed bottom-10 right-10 z-[100] bg-emerald-500 text-white px-8 py-4 rounded-2xl shadow-2xl font-black text-sm flex items-center gap-3 hidden animate-in slide-in-from-right duration-300">
    <i data-lucide="check-circle" class="w-5 h-5"></i>
    <span>Perubahan berhasil disimpan!</span>
</div>

<script src="https://unpkg.com/alpinejs" defer></script>
<script>
    function handleSave(e) {
        e.preventDefault();
        const toast = document.getElementById('successToast');
        toast.classList.remove('hidden');
        setTimeout(() => toast.classList.add('hidden'), 3000);
    }

    document.addEventListener('DOMContentLoaded', function() {
        lucide.createIcons();
    });
</script>
@endsection
