<?php

namespace App\Http\Controllers;

use App\Models\Order;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $status = $request->get('status');
        $query  = Order::with('items.product')->latest();

        if ($status && $status !== 'semua') {
            $query->where('status', $status);
        }

        $orders = $query->get();

        if ($request->expectsJson()) {
            return response()->json($orders);
        }

        return view('admin.orders', compact('orders'));
    }

    public function show(Order $order)
    {
        $order->load('items.product');

        if (request()->expectsJson()) {
            return response()->json($order);
        }

        return view('admin.orders', compact('order'));
    }

    public function updateStatus(Order $order, Request $request)
    {
        $request->validate([
            'status' => 'required|in:pending,processing,completed,cancelled'
        ]);

        $order->update(['status' => $request->status]);

        return response()->json([
            'success' => true,
            'message' => 'Status pesanan berhasil diperbarui ke ' . $request->status
        ]);
    }

    public function updatePaymentStatus(Order $order, Request $request)
    {
        $request->validate([
            'payment_status' => 'required|in:unpaid,paid'
        ]);

        $order->update(['payment_status' => $request->payment_status]);

        return response()->json(['success' => true]);
    }
}
