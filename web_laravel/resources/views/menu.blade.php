@php
    $setting   = \App\Models\Setting::first() ?? new \App\Models\Setting;
    $restoName = $setting->site_name ?? 'MenuKu';
    $brand     = $setting->primary_color ?? '#E8781A';
@endphp
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>{{ $restoName }} - Menu Digital</title>
    @if($setting->site_logo)
        <link rel="icon" href="{{ str_starts_with($setting->site_logo, 'http') ? $setting->site_logo : asset('storage/' . $setting->site_logo) }}">
    @endif

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

    {{-- Tailwind via CDN (development only — for production use compiled CSS) --}}
    <script>
        // Configure BEFORE loading tailwind CDN
        window.tailwind = window.tailwind || {};
        tailwind = {
            config: {
                theme: {
                    extend: {
                        colors: { brand: '{{ $brand }}' },
                        borderRadius: { '3xl': '1.5rem', '4xl': '2rem', '5xl': '2.5rem' }
                    }
                }
            }
        };
    </script>
    <script src="https://cdn.tailwindcss.com?plugins=forms"></script>

    {{--
        IMPORTANT: Do NOT load Alpine.js from CDN here.
        Livewire v3 bundles its own Alpine instance via @livewireScripts.
        Loading a second Alpine causes "Detected multiple instances" error.
    --}}

    <script src="https://unpkg.com/lucide@latest"></script>

    @livewireStyles

    <style>
        body { font-family: 'Outfit', sans-serif; -webkit-tap-highlight-color: transparent; }
        .no-scrollbar::-webkit-scrollbar  { display: none; }
        .no-scrollbar                     { -ms-overflow-style: none; scrollbar-width: none; }
        .custom-scrollbar::-webkit-scrollbar       { width: 4px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #CBD5E1; border-radius: 9999px; }

        /* Brand color as CSS variable so blade components can use it */
        :root { --brand: {{ $brand }}; }
        .bg-brand   { background-color: {{ $brand }} !important; }
        .text-brand { color: {{ $brand }} !important; }
        .border-brand { border-color: {{ $brand }} !important; }
        .shadow-brand\/20 { --tw-shadow-color: {{ $brand }}33 !important; }
        .shadow-brand\/25 { --tw-shadow-color: {{ $brand }}40 !important; }
        .ring-brand  { --tw-ring-color: {{ $brand }} !important; }
        .focus\:ring-brand:focus { --tw-ring-color: {{ $brand }} !important; }
    </style>
</head>
<body class="bg-[#F8FAFC] text-slate-900 overflow-x-hidden min-h-screen">

    <!-- App Container — mobile centred, max 430 px -->
    <div class="max-w-[430px] mx-auto min-h-screen bg-white shadow-2xl relative flex flex-col">
        {{--
            Pass tableName as a prop.
            The Cart component also reads ?table= / ?meja= directly inside mount()
            so the value is correct even if Livewire skips re-mounting.
        --}}
        <livewire:menu.cart :tableName="$tableName" />
    </div>

    @livewireScripts
    {{-- Livewire v3 already boots Alpine internally — no extra Alpine script needed --}}

    <script>
        function initializeLucide() {
            if (typeof lucide !== 'undefined') lucide.createIcons();
        }
        document.addEventListener('DOMContentLoaded', initializeLucide);
        document.addEventListener('livewire:navigated', initializeLucide);
        document.addEventListener('livewire:update', initializeLucide);

        if (window.Livewire) {
            Livewire.hook('morph.updated', ({ el }) => initializeLucide());
        }
    </script>
</body>
</html>
