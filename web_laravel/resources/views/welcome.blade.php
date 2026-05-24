@php
    $setting = \App\Models\Setting::first() ?? new \App\Models\Setting;
@endphp
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MenuKu - Kelola Restoran Lebih Mudah</title>
    <link rel="icon" type="image/png" href="{{ $setting->site_favicon ? asset('storage/' . $setting->site_favicon) : '' }}">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body { font-family: 'Outfit', sans-serif; scroll-behavior: smooth; }
        .bg-pattern {
            background-image: radial-gradient(#E8781A 0.5px, transparent 0.5px);
            background-size: 24px 24px;
            opacity: 0.05;
        }
    </style>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: { 
                        brand: '#E8781A',
                        dark: '#1E1E2E',
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-white text-slate-900 selection:bg-brand selection:text-white">

    <!-- NAVBAR -->
    <nav class="fixed top-0 inset-x-0 z-50 bg-white/80 backdrop-blur-lg border-b border-slate-100">
        <div class="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
            <!-- Logo -->
            <div class="flex items-center gap-2.5">
                <div class="w-10 h-10 bg-brand rounded-xl flex items-center justify-center shadow-lg shadow-brand/30">
                    <i data-lucide="utensils-crossed" class="w-6 h-6 text-white"></i>
                </div>
                <span class="text-2xl font-black tracking-tighter">Menu<span class="text-brand">Ku</span></span>
            </div>

            <!-- Links -->
            <div class="hidden md:flex items-center gap-10">
                <a href="#fitur" class="text-sm font-bold text-slate-600 hover:text-brand transition">Fitur</a>
                <a href="#harga" class="text-sm font-bold text-slate-600 hover:text-brand transition">Harga</a>
                <a href="#tentang" class="text-sm font-bold text-slate-600 hover:text-brand transition">Tentang</a>
            </div>

            <!-- Buttons -->
            <div class="flex items-center gap-4">
                <a href="/menu" class="hidden md:flex px-6 py-2.5 text-sm font-bold text-brand bg-brand/10 rounded-xl hover:bg-brand/20 transition items-center gap-2">
                    <i data-lucide="menu" class="w-4 h-4"></i> Lihat Menu
                </a>
                <a href="/login" class="px-6 py-2.5 text-sm font-bold text-slate-700 border-2 border-slate-200 rounded-xl hover:bg-slate-50 transition">Login</a>
                <a href="/login" class="hidden sm:block px-6 py-2.5 text-sm font-black text-white bg-brand rounded-xl shadow-lg shadow-brand/20 hover:opacity-90 transition">Daftar Gratis</a>
            </div>
        </div>
    </nav>

    <!-- HERO SECTION -->
    <section class="relative pt-48 pb-32 overflow-hidden">
        <div class="absolute inset-0 bg-pattern -z-10"></div>
        <div class="absolute top-0 right-0 -translate-y-1/2 translate-x-1/4 w-[600px] h-[600px] bg-brand/5 blur-[120px] rounded-full -z-10"></div>
        
        <div class="max-w-7xl mx-auto px-6 text-center">
            <div class="inline-flex items-center gap-2 px-5 py-2 bg-brand/10 text-brand rounded-full text-[11px] font-bold tracking-[0.2em] uppercase mb-10 animate-pulse">
                <i data-lucide="sparkles" class="w-4 h-4"></i>
                <span>Solusi Restoran Digital #1</span>
            </div>
            <h1 class="text-6xl md:text-8xl font-extrabold text-slate-900 mb-10 leading-[1.05] tracking-tight">
                Modernisasi Bisnis <br> <span class="text-brand font-medium italic serif">Kuliner Anda</span>
            </h1>
            <p class="text-xl text-slate-600 max-w-3xl mx-auto mb-14 font-normal leading-relaxed">
                Kelola pesanan, pantau stok, dan terima pembayaran digital dalam satu platform cerdas. Didesain untuk efisiensi maksimal dan pengalaman pelanggan yang premium.
            </p>

            <div class="flex flex-col sm:flex-row items-center justify-center gap-6">
                <a href="/login" class="w-full sm:w-auto px-12 py-5 bg-brand text-white rounded-2xl font-bold text-lg shadow-[0_20px_50px_rgba(232,120,26,0.3)] hover:-translate-y-1 hover:shadow-[0_20px_60px_rgba(232,120,26,0.4)] transition-all duration-300 flex items-center justify-center gap-3">
                    <span>Mulai Gratis</span>
                    <i data-lucide="arrow-right" class="w-5 h-5"></i>
                </a>
                <a href="#demo" class="w-full sm:w-auto px-12 py-5 bg-white text-slate-700 border border-slate-200 rounded-2xl font-bold text-lg hover:bg-slate-50 hover:border-slate-300 transition-all duration-300 flex items-center justify-center gap-3">
                    <i data-lucide="play-circle" class="w-5 h-5"></i>
                    <span>Lihat Demo</span>
                </a>
            </div>
        </div>
    </section>

    <!-- MENU EXAMPLES SECTION -->
    <section class="py-32 bg-white">
        <div class="max-w-7xl mx-auto px-6">
            <div class="flex flex-col md:flex-row items-end justify-between mb-16 gap-6">
                <div class="max-w-2xl">
                    <h2 class="text-3xl md:text-5xl font-bold text-slate-900 mb-6 tracking-tight">Antarmuka Menu yang <span class="text-brand">Interaktif</span></h2>
                    <p class="text-slate-500 font-light leading-relaxed">Berikan pengalaman memesan yang modern bagi pelanggan Anda. Menu digital kami dirancang untuk kecepatan dan kemudahan penggunaan di semua perangkat.</p>
                </div>
                <a href="/menu" class="px-8 py-4 bg-slate-900 text-white rounded-2xl font-semibold hover:bg-slate-800 transition flex items-center gap-3">
                    Lihat Demo Menu <i data-lucide="external-link" class="w-4 h-4"></i>
                </a>
            </div>

            <div class="relative group">
                <div class="absolute -inset-4 bg-gradient-to-r from-brand/20 to-orange-500/20 rounded-[3rem] blur-2xl opacity-0 group-hover:opacity-100 transition duration-700"></div>
                <div class="relative bg-slate-50 rounded-[3rem] p-4 border border-slate-100 shadow-xl overflow-hidden">
                    <img src="{{ asset('assets/screenshots/menu-page.png') }}" class="w-full h-auto rounded-[2rem] shadow-sm" alt="Menu Page Screenshot">
                </div>
            </div>
        </div>
    </section>

    <!-- SYSTEM PREVIEW SECTION -->
    <section id="demo" class="py-32 bg-slate-50">
        <div class="max-w-7xl mx-auto px-6">
            <div class="text-center max-w-3xl mx-auto mb-20">
                <h2 class="text-3xl md:text-5xl font-bold text-slate-900 mb-6 tracking-tight">Satu Sistem, <span class="text-brand">Kontrol Penuh</span></h2>
                <p class="text-slate-500 font-light italic">"Kelola seluruh aspek operasional melalui dashboard admin yang intuitif."</p>
            </div>

            <div class="grid grid-cols-1 gap-16 items-center">
                <!-- Admin Dashboard -->
                <div class="relative group">
                    <div class="absolute -inset-6 bg-gradient-to-r from-brand to-orange-500 rounded-[4rem] blur-3xl opacity-5 group-hover:opacity-10 transition duration-700"></div>
                    <div class="relative bg-white rounded-[3rem] p-6 shadow-2xl border border-slate-100 overflow-hidden">
                        <div class="flex items-center gap-3 mb-6 px-4">
                            <div class="flex gap-1.5">
                                <div class="w-3 h-3 rounded-full bg-red-400"></div>
                                <div class="w-3 h-3 rounded-full bg-amber-400"></div>
                                <div class="w-3 h-3 rounded-full bg-emerald-400"></div>
                            </div>
                            <div class="h-8 bg-slate-50 rounded-lg flex-1 flex items-center px-4 text-[10px] text-slate-400 font-mono">
                                admin.menuku.id/dashboard
                            </div>
                        </div>
                        <img src="{{ asset('assets/screenshots/admin-dashboard.png') }}" class="w-full h-auto rounded-2xl border border-slate-100" alt="Admin Dashboard Real">
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- FEATURES LIST SECTION -->
    <section class="py-32 bg-white">
        <div class="max-w-7xl mx-auto px-6">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-x-12 gap-y-16">
                <div>
                    <div class="w-12 h-12 bg-orange-100 text-brand rounded-xl flex items-center justify-center mb-6">
                        <i data-lucide="zap" class="w-6 h-6"></i>
                    </div>
                    <h4 class="text-xl font-bold text-slate-900 mb-3">Sangat Cepat</h4>
                    <p class="text-slate-500 font-light text-sm leading-relaxed">Aplikasi ringan dan responsif, memastikan pelanggan tidak perlu menunggu lama saat membuka menu.</p>
                </div>
                <div>
                    <div class="w-12 h-12 bg-blue-100 text-blue-600 rounded-xl flex items-center justify-center mb-6">
                        <i data-lucide="shield-check" class="w-6 h-6"></i>
                    </div>
                    <h4 class="text-xl font-bold text-slate-900 mb-3">Keamanan Data</h4>
                    <p class="text-slate-500 font-light text-sm leading-relaxed">Semua data transaksi dan data pelanggan Anda dienkripsi dengan standar keamanan tinggi.</p>
                </div>
                <div>
                    <div class="w-12 h-12 bg-emerald-100 text-emerald-600 rounded-xl flex items-center justify-center mb-6">
                        <i data-lucide="bar-chart-3" class="w-6 h-6"></i>
                    </div>
                    <h4 class="text-xl font-bold text-slate-900 mb-3">Laporan Otomatis</h4>
                    <p class="text-slate-500 font-light text-sm leading-relaxed">Tidak perlu lagi rekap manual. Laporan harian, mingguan, hingga bulanan tersedia instan.</p>
                </div>
                <div>
                    <div class="w-12 h-12 bg-purple-100 text-purple-600 rounded-xl flex items-center justify-center mb-6">
                        <i data-lucide="refresh-ccw" class="w-6 h-6"></i>
                    </div>
                    <h4 class="text-xl font-bold text-slate-900 mb-3">Update Real-time</h4>
                    <p class="text-slate-500 font-light text-sm leading-relaxed">Stok habis? Ganti status menu dalam hitungan detik dan pelanggan akan langsung melihatnya.</p>
                </div>
                <div>
                    <div class="w-12 h-12 bg-amber-100 text-amber-600 rounded-xl flex items-center justify-center mb-6">
                        <i data-lucide="star" class="w-6 h-6"></i>
                    </div>
                    <h4 class="text-xl font-bold text-slate-900 mb-3">Sistem Rating</h4>
                    <p class="text-slate-500 font-light text-sm leading-relaxed">Dapatkan feedback langsung dari pelanggan untuk terus meningkatkan kualitas layanan Anda.</p>
                </div>
                <div>
                    <div class="w-12 h-12 bg-rose-100 text-rose-600 rounded-xl flex items-center justify-center mb-6">
                        <i data-lucide="smartphone" class="w-6 h-6"></i>
                    </div>
                    <h4 class="text-xl font-bold text-slate-900 mb-3">Multi Platform</h4>
                    <p class="text-slate-500 font-light text-sm leading-relaxed">Akses dashboard dari laptop, tablet, hingga smartphone kapan saja dan di mana saja.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA SECTION -->
    <section class="py-32">
        <div class="max-w-7xl mx-auto px-6">
            <div class="bg-slate-900 rounded-[4rem] p-10 md:p-20 text-center relative overflow-hidden">
                <div class="absolute top-0 right-0 w-96 h-96 bg-brand/20 blur-[100px] rounded-full -translate-y-1/2 translate-x-1/2"></div>
                <div class="absolute bottom-0 left-0 w-96 h-96 bg-brand/10 blur-[100px] rounded-full translate-y-1/2 -translate-x-1/2"></div>
                
                <h2 class="text-4xl md:text-6xl font-bold text-white mb-8 tracking-tight relative z-10">Siap Mendigitalisasi <br> <span class="text-brand">Restoran Anda?</span></h2>
                <p class="text-slate-400 font-light text-lg max-w-2xl mx-auto mb-12 relative z-10">Bergabunglah dengan ratusan pengusaha kuliner sukses yang telah menggunakan MenuKu.</p>
                
                <div class="flex flex-col sm:flex-row items-center justify-center gap-6 relative z-10">
                    <a href="/register" class="w-full sm:w-auto px-12 py-5 bg-brand text-white rounded-2xl font-bold text-xl shadow-2xl shadow-brand/20 hover:-translate-y-1 transition duration-300">
                        Daftar Sekarang
                    </a>
                    <a href="https://wa.me/628123456789" class="w-full sm:w-auto px-12 py-5 bg-white/10 text-white border border-white/20 rounded-2xl font-bold text-xl hover:bg-white/20 transition duration-300 flex items-center justify-center gap-3">
                        <i data-lucide="message-circle" class="w-6 h-6"></i>
                        Hubungi Kami
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- FOOTER -->
    <footer class="bg-slate-950 py-24 px-6 text-white border-t border-white/5">
        <div class="max-w-7xl mx-auto">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-16 mb-20">
                <div class="col-span-1 md:col-span-2">
                    <div class="flex items-center gap-3 mb-8">
                        <div class="w-10 h-10 bg-brand rounded-xl flex items-center justify-center">
                            <i data-lucide="utensils-crossed" class="w-6 h-6 text-white"></i>
                        </div>
                        <span class="text-2xl font-bold tracking-tighter italic">Menu<span class="text-brand">Ku</span></span>
                    </div>
                    <p class="text-slate-400 font-light max-w-md mb-10 leading-relaxed">
                        Platform manajemen restoran paling modern di Indonesia. Kami membantu Anda fokus pada rasa, sementara kami mengurus sistemnya.
                    </p>
                    <div class="flex flex-col gap-4 text-slate-400 font-light">
                        <a href="mailto:hello@menuku.id" class="flex items-center gap-3 hover:text-brand transition">
                            <i data-lucide="mail" class="w-5 h-5"></i>
                            hello@menuku.id
                        </a>
                        <a href="https://wa.me/628123456789" class="flex items-center gap-3 hover:text-brand transition">
                            <i data-lucide="phone" class="w-5 h-5"></i>
                            +62 812-3456-7890 (WhatsApp)
                        </a>
                    </div>
                </div>
                
                <div>
                    <h5 class="text-lg font-bold mb-8">Perusahaan</h5>
                    <ul class="space-y-4 text-slate-400 font-light">
                        <li><a href="#fitur" class="hover:text-brand transition">Fitur Utama</a></li>
                        <li><a href="#" class="hover:text-brand transition">Tentang Kami</a></li>
                        <li><a href="#" class="hover:text-brand transition">Karir</a></li>
                        <li><a href="#" class="hover:text-brand transition">Kontak</a></li>
                    </ul>
                </div>
                
                <div>
                    <h5 class="text-lg font-bold mb-8">Bantuan</h5>
                    <ul class="space-y-4 text-slate-400 font-light">
                        <li><a href="#" class="hover:text-brand transition">Pusat Bantuan</a></li>
                        <li><a href="#" class="hover:text-brand transition">Panduan Pengguna</a></li>
                        <li><a href="#" class="hover:text-brand transition">Syarat & Ketentuan</a></li>
                        <li><a href="#" class="hover:text-brand transition">Kebijakan Privasi</a></li>
                    </ul>
                </div>
            </div>
            
            <div class="pt-12 border-t border-white/5 flex flex-col md:flex-row justify-between items-center gap-8">
                <p class="text-slate-500 text-sm font-light">© 2026 MenuKu SaaS. Seluruh hak cipta dilindungi.</p>
                <div class="flex gap-6">
                    <a href="#" class="text-slate-500 hover:text-brand transition"><i data-lucide="instagram" class="w-5 h-5"></i></a>
                    <a href="#" class="text-slate-500 hover:text-brand transition"><i data-lucide="facebook" class="w-5 h-5"></i></a>
                    <a href="#" class="text-slate-500 hover:text-brand transition"><i data-lucide="twitter" class="w-5 h-5"></i></a>
                    <a href="#" class="text-slate-500 hover:text-brand transition"><i data-lucide="youtube" class="w-5 h-5"></i></a>
                </div>
            </div>
        </div>
    </footer>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>
