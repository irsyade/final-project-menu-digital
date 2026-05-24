@php
    $setting = \App\Models\Setting::first() ?? new \App\Models\Setting;
    $restoName = $setting->site_name ?? 'MenuKu';
@endphp
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>{{ $restoName }} - Menu Digital</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    @livewireStyles
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        brand: '{{ $setting->primary_color ?? "#E8781A" }}',
                    },
                    borderRadius: {
                        '3xl': '1.5rem',
                        '4xl': '2rem',
                        '5xl': '2.5rem',
                    }
                }
            }
        }
    </script>
    <style>
        body { font-family: 'Outfit', sans-serif; -webkit-tap-highlight-color: transparent; }
        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
        .custom-scrollbar::-webkit-scrollbar { width: 4px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #CBD5E1; border-radius: 9999px; }
    </style>
</head>
<body class="bg-[#F8FAFC] text-slate-900 overflow-x-hidden min-h-screen">

    <!-- App Container (Mobile Centered) -->
    <div class="max-w-[430px] mx-auto min-h-screen bg-white shadow-2xl relative flex flex-col">
        <livewire:menu.cart :tableName="$tableName" />
    </div>

    @livewireScripts
    <script>
        function initializeLucide() {
            if (typeof lucide !== 'undefined') {
                lucide.createIcons();
            }
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', initializeLucide);

        // Re-initialize on Livewire DOM updates
        document.addEventListener('livewire:navigated', initializeLucide);
        
        // Listen to screen change and cart updates
        Livewire.hook('morph.updated', ({ el, component }) => {
            initializeLucide();
        });
    </script>
</body>
</html>
