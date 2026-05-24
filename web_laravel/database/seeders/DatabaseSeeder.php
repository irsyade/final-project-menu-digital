<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Category;
use App\Models\Product;
use App\Models\Promo;
use App\Models\Table;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Admin User
        User::firstOrCreate(
            ['email' => 'admin@menuku.com'],
            [
                'name'     => 'Admin MenuKu',
                'password' => Hash::make('password'),
                'role'     => 'admin',
            ]
        );

        // =====================
        // Meja Restoran dihapus
        // =====================

        // =====================
        // Promo Default
        // =====================
        Promo::firstOrCreate(['code' => 'HEMAT20'], [
            'name'         => 'Hemat Awal Bulan',
            'description'  => 'Potongan 20% untuk semua menu tanpa minimal pembelian!',
            'type'         => 'percentage',
            'value'        => 20,
            'min_purchase' => 0,
            'is_active'    => true,
            'is_banner'    => true,
            'image'        => 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
        ]);

        Promo::firstOrCreate(['code' => 'PESTA50'], [
            'name'         => 'Pesta Makan Besar',
            'description'  => 'Potongan Rp 50.000 untuk pembelian di atas Rp 200.000',
            'type'         => 'fixed',
            'value'        => 50000,
            'min_purchase' => 200000,
            'is_active'    => true,
            'is_banner'    => true,
            'image'        => 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
        ]);

        // =====================
        // Kategori & Produk (20 item)
        // =====================
        $categoriesWithProducts = [

            // ---- KATEGORI 1: Indonesian Food (6 item) ----
            [
                'category' => [
                    'name'  => 'Indonesian Food',
                    'image' => 'https://images.unsplash.com/photo-1541544741938-0af808871cc0?w=500',
                ],
                'products' => [
                    [
                        'name'                => 'Nasi Goreng Special',
                        'cuisine'             => 'Indonesian',
                        'description'         => 'Nasi goreng dengan telur mata sapi, ayam suwir, dan kerupuk udang. Cocok untuk sarapan maupun makan siang.',
                        'tags'                => ['Best Seller', 'Pedas'],
                        'price'               => 25000,
                        'discount_percentage' => 10,
                        'is_popular'          => true,
                        'image'               => 'https://images.unsplash.com/photo-1623653387945-2fd25214f8fc?w=500',
                    ],
                    [
                        'name'                => 'Sate Ayam Madura',
                        'cuisine'             => 'Indonesian',
                        'description'         => '10 tusuk sate ayam dengan bumbu kacang khas Madura yang gurih dan manis.',
                        'tags'                => ['Favorit'],
                        'price'               => 35000,
                        'discount_percentage' => 0,
                        'is_popular'          => true,
                        'image'               => 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500',
                    ],
                    [
                        'name'                => 'Mie Ayam Bakso',
                        'cuisine'             => 'Indonesian',
                        'description'         => 'Mie kenyal dengan topping ayam cincang, bakso sapi, dan pangsit goreng.',
                        'tags'                => ['Hangat', 'Kenyang'],
                        'price'               => 22000,
                        'discount_percentage' => 0,
                        'is_popular'          => false,
                        'image'               => 'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=500',
                    ],
                    [
                        'name'                => 'Ayam Bakar Kecap',
                        'cuisine'             => 'Indonesian',
                        'description'         => 'Ayam bakar dengan bumbu kecap manis, bawang putih, dan jahe. Disajikan dengan lalapan segar.',
                        'tags'                => ['Sehat', 'Favorit'],
                        'price'               => 32000,
                        'discount_percentage' => 5,
                        'is_popular'          => true,
                        'image'               => 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=500',
                    ],
                    [
                        'name'                => 'Rendang Daging Sapi',
                        'cuisine'             => 'Indonesian',
                        'description'         => 'Rendang daging sapi empuk dengan bumbu rempah khas Minang. Disajikan bersama nasi putih.',
                        'tags'                => ['Pedas', 'Best Seller'],
                        'price'               => 45000,
                        'discount_percentage' => 0,
                        'is_popular'          => true,
                        'image'               => 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=500',
                    ],
                    [
                        'name'                => 'Gado-Gado Jakarta',
                        'cuisine'             => 'Indonesian',
                        'description'         => 'Sayuran segar rebus disiram saus kacang khas Jakarta, dilengkapi kerupuk dan telur rebus.',
                        'tags'                => ['Sehat', 'Vegetarian'],
                        'price'               => 20000,
                        'discount_percentage' => 0,
                        'is_popular'          => false,
                        'image'               => 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500',
                    ],
                ],
            ],

            // ---- KATEGORI 2: Western Food (5 item) ----
            [
                'category' => [
                    'name'  => 'Western Food',
                    'image' => 'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=500',
                ],
                'products' => [
                    [
                        'name'                => 'Beef Burger XL',
                        'cuisine'             => 'Western',
                        'description'         => 'Burger sapi premium double patty dengan keju cheddar, selada, tomat, dan kentang goreng.',
                        'tags'                => ['Kenyang', 'Gurih'],
                        'price'               => 55000,
                        'discount_percentage' => 20,
                        'is_popular'          => true,
                        'image'               => 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
                    ],
                    [
                        'name'                => 'Spaghetti Bolognese',
                        'cuisine'             => 'Western',
                        'description'         => 'Spaghetti al dente dengan saus bolognese daging cincang, tomat, dan parmesan.',
                        'tags'                => ['Favorit', 'Creamy'],
                        'price'               => 48000,
                        'discount_percentage' => 0,
                        'is_popular'          => true,
                        'image'               => 'https://images.unsplash.com/photo-1555949258-eb67b1ef0ceb?w=500',
                    ],
                    [
                        'name'                => 'Chicken Schnitzel',
                        'cuisine'             => 'Western',
                        'description'         => 'Ayam fillet tepung renyah digoreng krispi, disajikan dengan kentang tumbuk dan saus jamur.',
                        'tags'                => ['Renyah'],
                        'price'               => 52000,
                        'discount_percentage' => 10,
                        'is_popular'          => false,
                        'image'               => 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=500',
                    ],
                    [
                        'name'                => 'Grilled Salmon',
                        'cuisine'             => 'Western',
                        'description'         => 'Salmon segar panggang dengan lemon butter sauce, kentang goreng, dan sayuran kukus.',
                        'tags'                => ['Sehat', 'Premium'],
                        'price'               => 85000,
                        'discount_percentage' => 0,
                        'is_popular'          => true,
                        'image'               => 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=500',
                    ],
                    [
                        'name'                => 'Fish & Chips',
                        'cuisine'             => 'Western',
                        'description'         => 'Ikan dori batter renyah dengan kentang goreng tebal, disajikan bersama saus tartar.',
                        'tags'                => ['Renyah', 'Gurih'],
                        'price'               => 42000,
                        'discount_percentage' => 0,
                        'is_popular'          => false,
                        'image'               => 'https://images.unsplash.com/photo-1579208575657-c595a05383b7?w=500',
                    ],
                ],
            ],

            // ---- KATEGORI 3: Drinks & Coffee (5 item) ----
            [
                'category' => [
                    'name'  => 'Drinks & Coffee',
                    'image' => 'https://images.unsplash.com/photo-1547928576-a4a33237cea4?w=500',
                ],
                'products' => [
                    [
                        'name'                => 'Es Kopi Susu Gula Aren',
                        'cuisine'             => 'Beverage',
                        'description'         => 'Kopi susu kekinian dengan gula aren asli, espresso shot, dan susu segar.',
                        'tags'                => ['Segar', 'Best Seller'],
                        'price'               => 18000,
                        'discount_percentage' => 0,
                        'is_popular'          => true,
                        'image'               => 'https://images.unsplash.com/photo-1551046710-252f9281353c?w=500',
                    ],
                    [
                        'name'                => 'Thai Tea Milk',
                        'cuisine'             => 'Beverage',
                        'description'         => 'Teh Thai khas dengan rasa vanila dan susu kental manis, disajikan dingin dengan es batu.',
                        'tags'                => ['Segar', 'Manis'],
                        'price'               => 16000,
                        'discount_percentage' => 0,
                        'is_popular'          => true,
                        'image'               => 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500',
                    ],
                    [
                        'name'                => 'Es Matcha Latte',
                        'cuisine'             => 'Beverage',
                        'description'         => 'Matcha premium Jepang dengan susu oat creamy, segar dan sedikit pahit.',
                        'tags'                => ['Segar', 'Hits'],
                        'price'               => 22000,
                        'discount_percentage' => 0,
                        'is_popular'          => true,
                        'image'               => 'https://images.unsplash.com/photo-1515823662972-da6a2e4d3002?w=500',
                    ],
                    [
                        'name'                => 'Jus Alpukat',
                        'cuisine'             => 'Beverage',
                        'description'         => 'Jus alpukat segar dipadukan dengan susu dan sedikit madu, kaya vitamin.',
                        'tags'                => ['Sehat', 'Segar'],
                        'price'               => 18000,
                        'discount_percentage' => 0,
                        'is_popular'          => false,
                        'image'               => 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=500',
                    ],
                    [
                        'name'                => 'Lemon Squash Soda',
                        'cuisine'             => 'Beverage',
                        'description'         => 'Minuman soda dengan perasan lemon segar, menyegarkan di segala suasana.',
                        'tags'                => ['Segar', 'Asam Manis'],
                        'price'               => 15000,
                        'discount_percentage' => 0,
                        'is_popular'          => false,
                        'image'               => 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=500',
                    ],
                ],
            ],

            // ---- KATEGORI 4: Desserts (4 item) ----
            [
                'category' => [
                    'name'  => 'Desserts',
                    'image' => 'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=500',
                ],
                'products' => [
                    [
                        'name'                => 'Lava Cake Cokelat',
                        'cuisine'             => 'Dessert',
                        'description'         => 'Kue cokelat hangat dengan isian cokelat cair lumer, disajikan dengan vanilla ice cream.',
                        'tags'                => ['Manis', 'Favorit'],
                        'price'               => 28000,
                        'discount_percentage' => 0,
                        'is_popular'          => true,
                        'image'               => 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=500',
                    ],
                    [
                        'name'                => 'Cheesecake Strawberry',
                        'cuisine'             => 'Dessert',
                        'description'         => 'Cheesecake creamy dengan topping selai stroberi segar dan graham cracker crust.',
                        'tags'                => ['Manis', 'Creamy'],
                        'price'               => 32000,
                        'discount_percentage' => 15,
                        'is_popular'          => true,
                        'image'               => 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=500',
                    ],
                    [
                        'name'                => 'Es Krim Gelato 3 Rasa',
                        'cuisine'             => 'Dessert',
                        'description'         => 'Tiga scoop gelato pilihan rasa: vanila, cokelat, dan pistachio.',
                        'tags'                => ['Segar', 'Manis'],
                        'price'               => 25000,
                        'discount_percentage' => 0,
                        'is_popular'          => false,
                        'image'               => 'https://images.unsplash.com/photo-1501443762994-82bd5dace89a?w=500',
                    ],
                    [
                        'name'                => 'Pancake Madu Pisang',
                        'cuisine'             => 'Dessert',
                        'description'         => 'Tumpukan pancake fluffy dengan pisang slice, madu, dan whipped cream.',
                        'tags'                => ['Manis', 'Sarapan'],
                        'price'               => 27000,
                        'discount_percentage' => 0,
                        'is_popular'          => false,
                        'image'               => 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=500',
                    ],
                ],
            ],
        ];

        foreach ($categoriesWithProducts as $item) {
            $category = Category::firstOrCreate(
                ['name' => $item['category']['name']],
                ['image' => $item['category']['image']]
            );

            foreach ($item['products'] as $prod) {
                Product::firstOrCreate(
                    ['name' => $prod['name'], 'category_id' => $category->id],
                    array_merge($prod, ['category_id' => $category->id])
                );
            }
        }
    }
}
