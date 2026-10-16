<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PatientController;
use App\Http\Controllers\MedicationController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\ChatNotificationController;
use App\Http\Controllers\ManajemenController;
use App\Http\Controllers\PetugasController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// DASHBOARD
Route::get('/patient/{id}/dashboard', [PatientController::class, 'dashboard']);
Route::post('/patient', [PatientController::class, 'store']);
Route::post('/register-patient', [PatientController::class, 'registerPatient']);
Route::put('/patient/{id}', [PatientController::class, 'update']);
Route::get('/test-fcm', [PatientController::class, 'testNotif']);
Route::post('/save-fcm-token', [PatientController::class, 'saveToken']);

// UPLOAD OBAT
Route::post('/patient/{id}/take-medicine', [MedicationController::class, 'store']);

Route::get('/dashboard-petugas', [PetugasController::class, 'dashboardPetugas']);
Route::get('/villages', [PetugasController::class, 'village']);
Route::get('/patients', [PetugasController::class, 'listPasien']);
Route::get('/medication-log/pending', [PetugasController::class, 'pending']);
Route::post('/medication-log/{id}/approve', [PetugasController::class, 'approve']);
Route::post('/medication-log/{id}/reject', [PetugasController::class, 'reject']);

Route::get('/dashboard-manajemen', [ManajemenController::class, 'index']);
Route::get('/test-notif/{userId}', [MedicationController::class, 'testNotif']);
Route::get('/test-fcm/{patientId}/{status}', function ($patientId, $status) {

    return app(App\Http\Controllers\MedicationController::class)
        ->sendNotificationToPetugas($patientId, $status);
});

Route::post('/send-chat-notification', [ChatNotificationController::class, 'sendChatNotificationApi']);

Route::post('/login', [AuthController::class, 'login']);

Route::post('/register', [AuthController::class, 'registerPetugas']);

Route::post('/reset-password', [AuthController::class, 'resetPassword']);

Route::get('/patients/status/{status}', [PatientController::class, 'getPatientsByStatus']);

// PROTECTED
Route::middleware('auth:sanctum')->group(function () {

    Route::get('/profile', [AuthController::class, 'profile']);
    Route::post('/logout', [AuthController::class, 'logout']);
});
