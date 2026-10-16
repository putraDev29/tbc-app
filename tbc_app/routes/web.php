<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

// Route helper untuk menjalankan scheduler (Web Cron & Debugging di Hosting)
Route::get('/cron/run', function (\Illuminate\Http\Request $request) {
    $validToken = env('CRON_TOKEN', 'tbc-app-cron-secret');
    if ($request->query('token') !== $validToken) {
        return response()->json(['error' => 'Unauthorized: Invalid cron token'], 403);
    }

    try {
        \Illuminate\Support\Facades\Artisan::call('schedule:run');
        $output = \Illuminate\Support\Facades\Artisan::output();

        return response()->json([
            'status'  => 'success',
            'message' => 'Scheduler executed successfully',
            'output'  => $output ?: 'No scheduled commands were due at this time.'
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status'  => 'error',
            'message' => $e->getMessage()
        ], 500);
    }
});
