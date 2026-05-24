<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Product;

class ProductTagSeeder extends Seeder
{
    public function run(): void
    {
        foreach (Product::all() as $p) {
            $name = strtolower($p->name);
            if (str_contains($name, 'nasi') || str_contains($name, 'mie')) {
                $p->tags = ['Gurih', 'Pedas'];
            } elseif (str_contains($name, 'es') || str_contains($name, 'teh') || str_contains($name, 'jeruk')) {
                $p->tags = ['Segar', 'Manis'];
            } elseif (str_contains($name, 'ayam') || str_contains($name, 'daging')) {
                $p->tags = ['Crispy', 'Gurih'];
            } else {
                $p->tags = ['Lezat'];
            }
            $p->save();
        }
    }
}
