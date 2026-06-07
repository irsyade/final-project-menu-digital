<?php

use App\Http\Controllers\Api\FoodController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TableController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC routes — no auth required
// ─────────────────────────────────────────────────────────────────────────────

// Settings
Route::get('/settings', [\App\Http\Controllers\SettingController::class, 'apiSettings']);

// Auth
Route::post('/login',    [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// QR download (called via url_launcher from Flutter)
Route::get('/tables/qr/download-all',      [\App\Http\Controllers\TableController::class, 'downloadAllQr']);
Route::get('/tables/{table}/qr/download',  [\App\Http\Controllers\TableController::class, 'downloadQr']);

// ── Products & Categories (READ-ONLY — public) ──────────────────────────────
// IMPORTANT: named static segments MUST come before wildcard {product} routes
Route::get('/categories',          [FoodController::class, 'categories']);
Route::get('/products/popular',    [FoodController::class, 'popular']);      // ← before {product}
Route::get('/products/search',     [FoodController::class, 'products']);     // ← before {product}
Route::get('/products',            [FoodController::class, 'products']);
Route::get('/products/{product}',  [FoodController::class, 'show']);         // single product detail

// Checkout & order tracking (public)
Route::post('/checkout',              [OrderController::class, 'store']);
Route::get('/orders/track/{id}',      [OrderController::class, 'track']);
Route::post('/orders/{id}/review',    [OrderController::class, 'submitReview']);

// ─────────────────────────────────────────────────────────────────────────────
// PROTECTED routes — require valid Sanctum token
// ─────────────────────────────────────────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', fn(Request $request) => $request->user());

    // Dashboard
    Route::get('/dashboard', [\App\Http\Controllers\AdminController::class, 'dashboard']);

    // Cart
    Route::get('/cart',          [CartController::class, 'index']);
    Route::post('/cart',         [CartController::class, 'store']);
    Route::delete('/cart/{id}',  [CartController::class, 'destroy']);

    // Orders
    Route::get('/orders',                    [OrderController::class, 'index']);
    Route::get('/all-orders',                [OrderController::class, 'allOrders']);
    Route::post('/orders/{id}/status',       [OrderController::class, 'updateStatus']);

    // Tables CRUD
    Route::get('/tables',          [TableController::class, 'index']);
    Route::post('/tables',         [TableController::class, 'store']);
    Route::put('/tables/{id}',     [TableController::class, 'update']);
    Route::delete('/tables/{id}',  [TableController::class, 'destroy']);
    Route::post('/tables/{id}/toggle-status', [TableController::class, 'toggleStatus'])->name('tables.toggle');

    // Settings
    Route::post('/settings', [\App\Http\Controllers\SettingController::class, 'apiUpdateSettings']);

    // ── Categories CRUD (admin) ──────────────────────────────────────────────
    // Named routes before wildcard to prevent conflicts
    Route::post('/categories',       [\App\Http\Controllers\Api\FoodController::class, 'storeCategory']);
    Route::put('/categories/{id}',   [\App\Http\Controllers\Api\FoodController::class, 'updateCategory']);
    Route::post('/categories/{id}',  [\App\Http\Controllers\Api\FoodController::class, 'updateCategory']); // method spoofing fallback
    Route::delete('/categories/{id}',[\App\Http\Controllers\Api\FoodController::class, 'destroyCategory']);

    // ── Products CRUD (admin) ────────────────────────────────────────────────
    // Toggle routes MUST be defined before {product} wildcard routes
    Route::post('/products/{product}/toggle',        [\App\Http\Controllers\ProductController::class, 'toggleStatus']);
    Route::post('/products/{product}/toggle-status', [\App\Http\Controllers\ProductController::class, 'toggleStatus']);

    // Create
    Route::post('/products', [\App\Http\Controllers\ProductController::class, 'store']);

    // Update — Flutter sends PUT (no file) or POST multipart with _method=PUT (with file)
    Route::put('/products/{product}',  [\App\Http\Controllers\ProductController::class, 'update']);
    Route::post('/products/{product}', [\App\Http\Controllers\ProductController::class, 'update']); // multipart fallback

    // Delete
    Route::delete('/products/{product}', [\App\Http\Controllers\ProductController::class, 'destroy']);

    // ── Promos CRUD (admin) ──────────────────────────────────────────────────
    Route::get('/promos',                                    [\App\Http\Controllers\PromoController::class, 'index']);
    Route::post('/promos',                                   [\App\Http\Controllers\PromoController::class, 'store']);
    Route::post('/promos/{promo}/toggle',                    [\App\Http\Controllers\PromoController::class, 'toggleStatus']);
    Route::post('/promos/{promo}/toggle-status',             [\App\Http\Controllers\PromoController::class, 'toggleStatus']);
    Route::put('/promos/{promo}',                            [\App\Http\Controllers\PromoController::class, 'update']);
    Route::post('/promos/{promo}',                           [\App\Http\Controllers\PromoController::class, 'update']); // multipart fallback
    Route::delete('/promos/{promo}',                         [\App\Http\Controllers\PromoController::class, 'destroy']);

    // Reports
    Route::get('/reports/export/csv', [\App\Http\Controllers\ReportController::class, 'exportCsv']);
    Route::get('/reports/export/pdf', [\App\Http\Controllers\ReportController::class, 'exportPdf']);
});
