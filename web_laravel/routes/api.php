<?php

use App\Http\Controllers\Api\FoodController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Public routes
Route::get('/categories', [FoodController::class, 'categories']);
Route::get('/products', [FoodController::class, 'products']);
Route::get('/products/popular', [FoodController::class, 'popular']);
Route::get('/products/search', [FoodController::class, 'products']);

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::get('/cart', [CartController::class, 'index']);
    Route::post('/cart', [CartController::class, 'store']);
    Route::delete('/cart/{id}', [CartController::class, 'destroy']);

    Route::get('/orders', [OrderController::class, 'index']);
    
    // Cashier/Admin routes
    Route::get('/all-orders', [OrderController::class, 'allOrders']);
    Route::post('/orders/{id}/status', [OrderController::class, 'updateStatus']);
});

Route::post('/checkout', [OrderController::class, 'store']);
Route::get('/orders/track/{id}', [OrderController::class, 'track']);
Route::post('/orders/{id}/review', [OrderController::class, 'submitReview']);
