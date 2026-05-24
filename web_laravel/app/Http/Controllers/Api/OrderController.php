<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Cart;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        return response()->json(
            Order::where('user_id', $request->user()->id)
                ->with('items.product')
                ->latest()
                ->get()
        );
    }

    public function store(Request $request)
    {
        $request->validate([
            'payment_method' => 'required',
            'name' => 'required',
            'address' => 'required',
            'phone' => 'required',
            'email' => 'required|email',
            'items' => 'nullable|array',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
        ]);

        $user = $request->user() ?? auth('web')->user();
        
        $orderItems = [];
        $totalPrice = 0;

        if ($request->has('items')) {
            // Items provided in request (Web App)
            foreach ($request->items as $item) {
                $product = \App\Models\Product::find($item['product_id']);
                $orderItems[] = [
                    'product_id' => $product->id,
                    'quantity' => $item['quantity'],
                    'price' => $product->price,
                ];
                $totalPrice += $product->price * $item['quantity'];
            }
        } else if ($user) {
            // Use cart from database (Mobile App)
            $cartItems = Cart::where('user_id', $user->id)
                ->with('product')
                ->get();

            if ($cartItems->isEmpty()) {
                return response()->json(['message' => 'Cart is empty'], 400);
            }

            foreach ($cartItems as $cartItem) {
                $orderItems[] = [
                    'product_id' => $cartItem->product_id,
                    'quantity' => $cartItem->quantity,
                    'price' => $cartItem->product->price,
                ];
                $totalPrice += $cartItem->product->price * $cartItem->quantity;
            }
        } else {
            return response()->json(['message' => 'Unauthorized or cart empty'], 401);
        }

        $totalPrice = $totalPrice * 1.1; // 10% tax matching web UI

        return DB::transaction(function () use ($request, $user, $orderItems, $totalPrice) {
            $order = Order::create([
                'user_id' => $user ? $user->id : null,
                'total_price' => $totalPrice,
                'status' => 'processing',
                'payment_method' => $request->payment_method,
                'payment_status' => $request->payment_method === 'qris' ? 'paid' : 'unpaid', // Simulation: QRIS auto-paid
                'name' => $request->name,
                'address' => $request->address,
                'phone' => $request->phone,
                'email' => $request->email,
            ]);

            foreach ($orderItems as $itemData) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $itemData['product_id'],
                    'quantity' => $itemData['quantity'],
                    'price' => $itemData['price'],
                ]);
            }

            if ($user && !$request->has('items')) {
                Cart::where('user_id', $user->id)->delete();
            }

            return response()->json($order->load('items.product'));
        });
    }

    public function allOrders(Request $request)
    {
        if (!in_array($request->user()->role, ['admin', 'kasir'])) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json(
            Order::with(['items.product', 'user'])->latest()->get()
        );
    }

    public function updateStatus(Request $request, $id)
    {
        if (!in_array($request->user()->role, ['admin', 'kasir'])) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'status' => 'required|in:pending,processing,completed,cancelled'
        ]);

        $order = Order::findOrFail($id);
        $order->update([
            'status' => $request->status
        ]);

        return response()->json($order);
    }

    public function track($id)
    {
        $order = Order::with('items.product')->find($id);
        
        if (!$order) {
            return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
        }

        return response()->json([
            'id' => $order->id,
            'status' => $order->status,
            'total_price' => $order->total_price,
            'payment_method' => $order->payment_method,
            'payment_status' => $order->payment_status,
            'created_at' => $order->created_at,
            'items' => $order->items
        ]);
    }

    public function submitReview(Request $request, $id)
    {
        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'review' => 'nullable|string|max:500'
        ]);

        $order = Order::findOrFail($id);
        
        if ($order->status !== 'completed') {
            return response()->json(['message' => 'Hanya pesanan selesai yang bisa diberi ulasan'], 400);
        }

        $order->update([
            'rating' => $request->rating,
            'review' => $request->review
        ]);

        return response()->json(['success' => true, 'message' => 'Terima kasih atas ulasan Anda!']);
    }
}