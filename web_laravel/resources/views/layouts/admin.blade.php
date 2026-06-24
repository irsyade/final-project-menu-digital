@php
    $setting = \App\Models\Setting::first() ?? new \App\Models\Setting;
    $pendingOrdersCount = \App\Models\Order::where('status', 'pending')->count();
@endphp
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Admin Dashboard') - {{ $setting->site_name ?? 'MenuKu' }}</title>
    @if($setting->site_logo)
        <link rel="icon" href="{{ str_starts_with($setting->site_logo, 'http') ? $setting->site_logo : asset('storage/' . $setting->site_logo) }}">
    @endif
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    @livewireStyles
    <style>
        body { font-family: 'Outfit', sans-serif; }
        .sidebar-active { background: #E8781A !important; color: white !important; font-weight: 700; }
        .custom-scrollbar::-webkit-scrollbar { width: 4px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.1); border-radius: 10px; }
    </style>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: { 
                        brand: '#E8781A',
                        dark: '#1E1E2E',
                        background: '#F7F6F3',
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-[#F7F6F3] text-slate-900">
    <div class="flex min-h-screen overflow-hidden">
        <!-- Sidebar -->
        <aside id="sidebar" class="fixed inset-y-0 left-0 z-50 w-60 bg-[#1E1E2E] text-slate-400 transition-transform duration-300 -translate-x-full lg:translate-x-0 lg:static lg:inset-0 flex flex-col">
            <div class="p-6 mb-4">
                <div class="flex items-center gap-3">
                    <img src="{{ asset('logo-menuku.png') }}" class="w-8 h-8 object-contain rounded-lg shadow-lg">
                    <span class="text-white font-black text-xl tracking-tighter italic">Menu<span class="text-brand">Ku</span></span>
                </div>
            </div>

            <div class="flex-1 overflow-y-auto px-4 space-y-1 custom-scrollbar">
                <!-- Dashboard -->
                <a href="/admin" class="flex items-center gap-3 px-4 py-3 rounded-xl transition hover:text-white @if(request()->is('admin')) sidebar-active @endif">
                    <i data-lucide="layout-grid" class="w-5 h-5"></i>
                    <span class="text-sm">Dashboard</span>
                </a>

                <!-- Pesanan Masuk -->
                <a href="/admin/orders" class="flex items-center justify-between px-4 py-3 rounded-xl transition hover:text-white @if(request()->is('admin/orders')) sidebar-active @endif">
                    <div class="flex items-center gap-3">
                        <i data-lucide="package" class="w-5 h-5"></i>
                        <span class="text-sm">Pesanan Masuk</span>
                    </div>
                    @if($pendingOrdersCount > 0)
                        <span class="bg-red-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded-md">{{ $pendingOrdersCount }}</span>
                    @endif
                </a>

                <!-- Kelola Menu -->
                <a href="/admin/products" class="flex items-center gap-3 px-4 py-3 rounded-xl transition hover:text-white @if(request()->is('admin/products*') || request()->is('admin/categories*')) sidebar-active @endif">
                    <i data-lucide="utensils" class="w-5 h-5"></i>
                    <span class="text-sm">Kelola Menu</span>
                </a>

                <!-- Meja & QR -->
                <a href="/admin/tables" class="flex items-center gap-3 px-4 py-3 rounded-xl transition hover:text-white @if(request()->is('admin/tables*')) sidebar-active @endif">
                    <i data-lucide="armchair" class="w-5 h-5"></i>
                    <span class="text-sm">Meja & QR Code</span>
                </a>

                <!-- Promo & Jadwal -->
                <a href="/admin/promos" class="flex items-center gap-3 px-4 py-3 rounded-xl transition hover:text-white @if(request()->is('admin/promos*')) sidebar-active @endif">
                    <i data-lucide="tag" class="w-5 h-5"></i>
                    <span class="text-sm">Promo & Jadwal</span>
                </a>

                <!-- Laporan Penjualan -->
                <a href="/admin/reports" class="flex items-center gap-3 px-4 py-3 rounded-xl transition hover:text-white @if(request()->is('admin/reports*')) sidebar-active @endif">
                    <i data-lucide="bar-chart-3" class="w-5 h-5"></i>
                    <span class="text-sm">Laporan Penjualan</span>
                </a>

                <!-- Pengaturan -->
                <a href="/admin/branding" class="flex items-center gap-3 px-4 py-3 rounded-xl transition hover:text-white @if(request()->is('admin/branding') || request()->is('admin/settings')) sidebar-active @endif">
                    <i data-lucide="settings" class="w-5 h-5"></i>
                    <span class="text-sm">Pengaturan</span>
                </a>
            </div>

            <!-- Logout -->
            <div class="p-6 border-t border-white/5">
                <form method="POST" action="/logout">
                    @csrf
                    <button type="submit" class="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-slate-400 hover:text-red-400 transition text-sm font-medium">
                        <i data-lucide="log-out" class="w-5 h-5"></i>
                        <span>Keluar</span>
                    </button>
                </form>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="flex-1 flex flex-col min-w-0 overflow-hidden relative">
            <!-- Top Bar -->
            <header class="h-20 bg-white border-b border-slate-200 px-4 lg:px-8 flex items-center justify-between sticky top-0 z-40">
                <div class="flex items-center gap-4">
                    <button id="sidebarToggle" class="lg:hidden p-2 text-slate-500 hover:bg-slate-100 rounded-lg">
                        <i data-lucide="menu" class="w-6 h-6"></i>
                    </button>
                    <h2 class="text-xl font-black text-slate-900 tracking-tight">@yield('page_title', 'Pengaturan')</h2>
                </div>
                
                <div class="flex items-center gap-6">

                    <!-- Profile -->
                    <div class="flex items-center gap-3 pl-6 border-l border-slate-200">
                        <div class="text-right hidden sm:block">
                            <p id="header-owner-name" class="text-sm font-bold text-slate-900 leading-none">{{ $setting->owner_name ?? Auth::user()->name ?? 'Administrator' }}</p>
                            <span class="text-[10px] font-black text-brand uppercase tracking-tighter">{{ Auth::user()->role == 'admin' ? 'Pemilik Resto' : 'Staf Kasir' }}</span>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-slate-100 text-slate-400 flex items-center justify-center border border-slate-200">
                            <i data-lucide="user" class="w-6 h-6"></i>
                        </div>
                    </div>
                </div>
            </header>

            <!-- Content Area -->
            <div class="flex-1 overflow-hidden bg-[#F7F6F3] flex flex-col">
                <div class="flex-1 overflow-hidden p-4 lg:p-8 flex flex-col">
                    @if(session('success'))
                        <div class="mb-8 p-4 bg-emerald-50 border border-emerald-100 text-emerald-700 rounded-2xl flex items-center gap-3 shadow-sm animate-in fade-in slide-in-from-top-4 duration-500 shrink-0">
                            <i data-lucide="check-circle" class="w-5 h-5"></i>
                            <p class="font-bold text-sm">{{ session('success') }}</p>
                        </div>
                    @endif

                    @if($errors->any())
                        <div class="mb-8 p-4 bg-red-50 border border-red-100 text-red-700 rounded-2xl flex items-center gap-3 shadow-sm shrink-0">
                            <i data-lucide="alert-circle" class="w-5 h-5"></i>
                            <div class="text-sm font-bold">
                                @foreach($errors->all() as $error)
                                    <p>{{ $error }}</p>
                                @endforeach
                            </div>
                        </div>
                    @endif

                    <div class="flex-1 overflow-hidden">
                        @yield('content')
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Mobile Sidebar Backdrop -->
    <div id="sidebarBackdrop" class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-40 hidden lg:hidden"></div>

    <script>
        lucide.createIcons();

        window.addEventListener('settings-saved', (event) => {
            const newName = event.detail.ownerName;
            if (newName) {
                const headerName = document.getElementById('header-owner-name');
                if (headerName) {
                    headerName.textContent = newName;
                }
            }
        });

        document.addEventListener('livewire:init', () => {
            Livewire.hook('morph.updated', ({ el, component }) => {
                if (typeof lucide !== 'undefined') {
                    lucide.createIcons();
                }
            });
        });

        const sidebar = document.getElementById('sidebar');
        const sidebarToggle = document.getElementById('sidebarToggle');
        const sidebarBackdrop = document.getElementById('sidebarBackdrop');

        function toggleSidebar() {
            sidebar.classList.toggle('-translate-x-full');
            sidebarBackdrop.classList.toggle('hidden');
        }

        sidebarToggle.addEventListener('click', toggleSidebar);
        sidebarBackdrop.addEventListener('click', toggleSidebar);
        
        window.addEventListener('resize', () => {
            if (window.innerWidth >= 1024) {
                sidebar.classList.remove('-translate-x-full');
                sidebarBackdrop.classList.add('hidden');
            }
        });
    </script>
    @stack('scripts')
    @livewireScripts
</body>
</html>
