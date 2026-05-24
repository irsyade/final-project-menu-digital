<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        \Illuminate\Support\Facades\View::composer('*', function ($view) {
            try {
                $setting = \App\Models\Setting::first();
                if (!$setting) {
                    $setting = \App\Models\Setting::create([
                        'site_name' => 'Flavora Kitchen',
                        'primary_color' => '#f97316'
                    ]);
                }
                $view->with('setting', $setting);
                $view->with('categories_global', \App\Models\Category::all());
            } catch (\Exception $e) {
                // Settings table might not exist yet
            }
        });
    }
}
