<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Table;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DashboardSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Bersihkan data lama
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        OrderItem::truncate();
        Order::truncate();
        Product::truncate();
        Category::truncate();
        Table::truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // 2. Buat Kategori
        $categories = [
            ['name' => 'Makanan Utama', 'image' => 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500'],
            ['name' => 'Minuman Segar', 'image' => 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=500'],
            ['name' => 'Cemilan', 'image' => 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=500'],
        ];

        foreach ($categories as $cat) {
            $category = Category::create($cat);

            // 3. Buat Produk untuk setiap kategori
            if ($cat['name'] == 'Makanan Utama') {
                $products = [
                    ['name' => 'Nasi Goreng Spesial', 'price' => 25000, 'is_popular' => true],
                    ['name' => 'Mie Goreng Seafood', 'price' => 28000, 'is_popular' => true],
                    ['name' => 'Ayam Bakar Madu', 'price' => 35000, 'is_popular' => true],
                    ['name' => 'Sate Ayam Madura', 'price' => 22000, 'is_popular' => false],
                ];
            } elseif ($cat['name'] == 'Minuman Segar') {
                $products = [
                    ['name' => 'Es Teh Manis', 'price' => 5000, 'is_popular' => true],
                    ['name' => 'Es Jeruk Peras', 'price' => 12000, 'is_popular' => false],
                    ['name' => 'Soda Gembira', 'price' => 18000, 'is_popular' => true],
                    ['name' => 'Kopi Susu Gula Aren', 'price' => 15000, 'is_popular' => false],
                ];
            } else {
                $products = [
                    ['name' => 'Kentang Goreng', 'price' => 15000, 'is_popular' => false],
                    ['name' => 'Cireng Bumbu Rujak', 'price' => 12000, 'is_popular' => false],
                    ['name' => 'Pisang Goreng Keju', 'price' => 18000, 'is_popular' => true],
                ];
            }

            foreach ($products as $p) {
                Product::create([
                    'category_id' => $category->id,
                    'name' => $p['name'],
                    'description' => 'Menu lezat kualitas premium dari dapur kami.',
                    'price' => $p['price'],
                    'is_popular' => $p['is_popular'],
                    'is_available' => true,
                    'image' => null, // Biarkan placeholder di view bekerja
                ]);
            }
        }

        // 4. Buat Meja (15 Meja)
        for ($i = 1; $i <= 15; $i++) {
            Table::create([
                'number' => 'Meja ' . str_pad($i, 2, '0', STR_PAD_LEFT),
                'capacity' => rand(2, 6),
                'status' => $i <= 3 ? 'occupied' : 'available',
            ]);
        }

        // 5. Buat Transaksi Dummy (7 Hari Terakhir)
        $allProducts = Product::all();
        $statuses = ['pending', 'processing', 'completed'];

        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i);
            
            // Jumlah transaksi per hari (acak antara 5 sampai 15)
            $orderCount = rand(5, 15);
            
            for ($j = 0; $j < $orderCount; $j++) {
                $order = Order::create([
                    'name' => 'Meja ' . str_pad(rand(1, 15), 2, '0', STR_PAD_LEFT),
                    'address' => 'Restoran Dine-in',
                    'phone' => '08123456789',
                    'email' => 'customer@example.com',
                    'total_price' => 0, // Akan diupdate setelah item ditambahkan
                    'status' => $i == 0 ? $statuses[array_rand($statuses)] : 'completed',
                    'payment_method' => rand(0, 1) ? 'QRIS' : 'Cash',
                    'payment_status' => $i == 0 ? (rand(0, 1) ? 'paid' : 'unpaid') : 'paid',
                    'created_at' => $date->copy()->addHours(rand(10, 21))->addMinutes(rand(0, 59)),
                ]);

                $total = 0;
                // Tambahkan 1-4 item per order
                $itemCount = rand(1, 4);
                $selectedProducts = $allProducts->random($itemCount);

                foreach ($selectedProducts as $prod) {
                    $qty = rand(1, 3);
                    $subtotal = $prod->price * $qty;
                    
                    OrderItem::create([
                        'order_id' => $order->id,
                        'product_id' => $prod->id,
                        'quantity' => $qty,
                        'price' => $prod->price,
                    ]);
                    
                    $total += $subtotal;
                }

                $order->update(['total_price' => $total]);
            }
        }
    }
}
