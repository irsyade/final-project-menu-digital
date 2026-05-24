<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function index(Request $request)
    {
        return response()->json(
            Cart::where('user_id', $request->user()->id)->with('product')->get()
        );
    }

    public function store(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
        ]);

        $cart = Cart::updateOrCreate(
            ['user_id' => $request->user()->id, 'product_id' => $request->product_id],
            ['quantity' => $request->quantity]
        );

        return response()->json($cart);
    }

    public function destroy($id, Request $request)
    {
        $cart = Cart::where('user_id', $request->user()->id)->where('id', $id)->first();
        if ($cart) {
            $cart->delete();
            return response()->json(['message' => 'Removed from cart']);
        }
        return response()->json(['message' => 'Item not found'], 404);
    }
}
