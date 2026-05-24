@php
    $setting = \App\Models\Setting::first() ?? new \App\Models\Setting;
@endphp
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daftar - MenuKu</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body { font-family: 'Outfit', sans-serif; }
    </style>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: { brand: '#E8781A' }
                }
            }
        }
    </script>
</head>
<body class="bg-[#F7F6F3] min-h-screen flex items-center justify-center p-6 py-20">

    <div class="max-w-xl w-full">
        <!-- Logo -->
        <div class="flex flex-col items-center mb-10">
            <div class="w-14 h-14 bg-brand rounded-2xl flex items-center justify-center shadow-xl shadow-brand/30 mb-4">
                <i data-lucide="utensils-crossed" class="w-8 h-8 text-white"></i>
            </div>
            <h1 class="text-3xl font-black tracking-tighter">Menu<span class="text-brand">Ku</span></h1>
        </div>

        <!-- Card -->
        <div class="bg-white rounded-[2.5rem] p-10 shadow-xl shadow-slate-200/60 border border-slate-100">
            <div class="mb-10 text-center">
                <h2 class="text-2xl font-black text-slate-900 mb-2">Mulai Perjalanan Digitalmu</h2>
                <p class="text-slate-500 font-medium text-sm">Bergabunglah dengan ribuan pemilik restoran lainnya.</p>
            </div>

            @if($errors->any())
                <div class="mb-6 p-4 bg-red-50 border border-red-100 text-red-600 rounded-2xl text-xs font-bold flex items-center gap-2">
                    <i data-lucide="alert-circle" class="w-4 h-4"></i>
                    <span>{{ $errors->first() }}</span>
                </div>
            @endif

            <form id="registerForm" action="{{ route('admin.register.post') }}" method="POST" class="space-y-6">
                @csrf
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Nama Restoran -->
                    <div>
                        <label class="block text-sm font-bold text-slate-700 mb-2">Nama Restoran</label>
                        <div class="relative group">
                            <input type="text" name="restaurant_name" required 
                                class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand focus:border-brand transition outline-none pl-12 text-sm font-medium" 
                                placeholder="Bakso Juara">
                            <i data-lucide="store" class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 group-focus-within:text-brand transition"></i>
                        </div>
                    </div>

                    <!-- Nama Admin -->
                    <div>
                        <label class="block text-sm font-bold text-slate-700 mb-2">Nama Admin</label>
                        <div class="relative group">
                            <input type="text" name="admin_name" required 
                                class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand focus:border-brand transition outline-none pl-12 text-sm font-medium" 
                                placeholder="Budi Santoso">
                            <i data-lucide="user" class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 group-focus-within:text-brand transition"></i>
                        </div>
                    </div>
                </div>

                <!-- Email -->
                <div>
                    <label class="block text-sm font-bold text-slate-700 mb-2">Email Bisnis</label>
                    <div class="relative group">
                        <input type="email" name="email" required 
                            class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand focus:border-brand transition outline-none pl-12 text-sm font-medium" 
                            placeholder="nama@restoran.com">
                        <i data-lucide="mail" class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 group-focus-within:text-brand transition"></i>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Password -->
                    <div>
                        <label class="block text-sm font-semibold text-slate-700 mb-2">Password</label>
                        <div class="relative group">
                            <input type="password" id="password" name="password" required 
                                class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand focus:border-brand transition outline-none pl-12 pr-12 text-sm font-medium" 
                                placeholder="••••••••">
                            <i data-lucide="lock" class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 group-focus-within:text-brand transition"></i>
                            <button type="button" onclick="togglePassword('password')" class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition">
                                <i data-lucide="eye" class="w-5 h-5"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Confirm Password -->
                    <div>
                        <label class="block text-sm font-semibold text-slate-700 mb-2">Konfirmasi Password</label>
                        <div class="relative group">
                            <input type="password" id="password_confirmation" name="password_confirmation" required 
                                class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand focus:border-brand transition outline-none pl-12 pr-12 text-sm font-medium" 
                                placeholder="••••••••">
                            <i data-lucide="shield-check" class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 group-focus-within:text-brand transition"></i>
                            <button type="button" onclick="togglePassword('password_confirmation')" class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition">
                                <i data-lucide="eye" class="w-5 h-5"></i>
                            </button>
                        </div>
                    </div>
                </div>



                <!-- Button -->
                <button type="submit" class="w-full py-5 bg-brand text-white rounded-2xl font-bold text-lg shadow-2xl shadow-brand/40 hover:-translate-y-1 transition-all active:scale-[0.98] flex items-center justify-center gap-3">
                    <span>DAFTAR SEKARANG</span>
                    <i data-lucide="sparkles" class="w-5 h-5"></i>
                </button>
            </form>

            <div class="mt-10 text-center">
                <p class="text-slate-500 text-sm font-medium">
                    Sudah punya akun? 
                    <a href="/login" class="text-brand font-bold hover:underline">Login</a>
                </p>
            </div>
        </div>

        <p class="mt-10 text-center text-slate-400 text-xs font-medium uppercase tracking-[0.2em]">
            &copy; 2026 MenuKu SaaS &bull; Grow Faster with Us
        </p>
    </div>

    <script>
        lucide.createIcons();

        function togglePassword(inputId) {
            const passwordInput = document.getElementById(inputId);
            const eyeIconBtn = event.currentTarget;
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                eyeIconBtn.innerHTML = '<i data-lucide="eye-off" class="w-5 h-5"></i>';
            } else {
                passwordInput.type = 'password';
                eyeIconBtn.innerHTML = '<i data-lucide="eye" class="w-5 h-5"></i>';
            }
            lucide.createIcons();
        }

    </script>
</body>
</html>
