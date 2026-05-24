@php
    $setting = \App\Models\Setting::first() ?? new \App\Models\Setting;
@endphp
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lupa Password - MenuKu</title>
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
<body class="bg-[#F7F6F3] min-h-screen flex items-center justify-center p-6">

    <div class="max-w-md w-full">
        <!-- Logo -->
        <div class="flex flex-col items-center mb-10">
            <div class="w-14 h-14 bg-brand rounded-2xl flex items-center justify-center shadow-xl shadow-brand/30 mb-4">
                <i data-lucide="utensils-crossed" class="w-8 h-8 text-white"></i>
            </div>
            <h1 class="text-3xl font-black tracking-tighter">Menu<span class="text-brand">Ku</span></h1>
        </div>

        <!-- Card -->
        <div class="bg-white rounded-[2.5rem] p-10 shadow-xl shadow-slate-200/60 border border-slate-100">
            <div class="mb-8">
                <div class="flex items-center gap-2 mb-2">
                    <a href="/login" class="text-slate-400 hover:text-brand transition">
                        <i data-lucide="arrow-left" class="w-5 h-5"></i>
                    </a>
                    <h2 class="text-2xl font-black text-slate-900">Lupa Password?</h2>
                </div>
                <p class="text-slate-500 font-medium text-sm">Jangan panik! Masukkan email Anda dan kami akan mengirimkan link reset.</p>
            </div>

            <form id="forgotForm" onsubmit="handleForgot(event)" class="space-y-6">
                <!-- Email -->
                <div>
                    <label class="block text-sm font-bold text-slate-700 mb-2">Email Terdaftar</label>
                    <div class="relative group">
                        <input type="email" name="email" required 
                            class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-brand focus:border-brand transition outline-none pl-12 text-sm font-medium" 
                            placeholder="nama@restoran.com">
                        <i data-lucide="mail" class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 group-focus-within:text-brand transition"></i>
                    </div>
                </div>

                <div id="successMessage" class="hidden p-4 bg-blue-50 border border-blue-100 text-blue-700 rounded-2xl flex items-center gap-3 animate-in fade-in zoom-in duration-300">
                    <i data-lucide="info" class="w-5 h-5"></i>
                    <p class="text-sm font-bold">Link reset password sudah dikirim ke email kamu.</p>
                </div>

                <!-- Button -->
                <button type="submit" class="w-full py-5 bg-brand text-white rounded-2xl font-black text-lg shadow-2xl shadow-brand/40 hover:-translate-y-1 transition-all active:scale-[0.98] flex items-center justify-center gap-3">
                    <span>Kirim Link Reset</span>
                    <i data-lucide="send" class="w-5 h-5"></i>
                </button>
            </form>

            <div class="mt-10 text-center">
                <p class="text-slate-500 text-sm font-medium">
                    Tiba-tiba ingat? 
                    <a href="/login" class="text-brand font-black hover:underline">Kembali Login</a>
                </p>
            </div>
        </div>
    </div>

    <script>
        lucide.createIcons();

        function handleForgot(e) {
            e.preventDefault();
            const message = document.getElementById('successMessage');
            message.classList.remove('hidden');
            
            // Optional: disable button after success
            e.target.querySelector('button').disabled = true;
            e.target.querySelector('button').classList.add('opacity-50');
        }
    </script>
</body>
</html>
