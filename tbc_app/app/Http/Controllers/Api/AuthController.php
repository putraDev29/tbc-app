<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Petugas;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    // 🔐 LOGIN
    public function login(Request $request)
    {
        $request->validate([
            'username' => 'required',
            'password' => 'required',
        ]);

        $user = User::where('username', $request->username)->first();

        // ❌ user tidak ditemukan / password salah
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Username atau password salah'
            ], 401);
        }

        // 🔥 generate token
        $token = $user->createToken('auth_token')->plainTextToken;

        // 🔥 ambil detail berdasarkan role
        $detail = null;

        if ($user->role == 'pasien') {
            $detail = $user->pasien;
        } elseif ($user->role == 'petugas') {
            $detail = $user->petugas;
        } elseif ($user->role == 'manajemen') {
            $detail = $user->manajemen;
        }

        return response()->json([
            'token' => $token,
            'user' => $user,
            'detail' => $detail
        ]);
    }

    // 🚪 LOGOUT
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout berhasil'
        ]);
    }

    // 👤 PROFILE
    public function profile(Request $request)
    {
        $user = $request->user();

        $detail = null;

        if ($user->role == 'pasien') {
            $detail = $user->pasien;
        } elseif ($user->role == 'petugas') {
            $detail = $user->petugas;
        } elseif ($user->role == 'manajemen') {
            $detail = $user->manajemen;
        }

        return response()->json([
            'user' => $user,
            'detail' => $detail
        ]);
    }


    public function registerPetugas(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nip' => 'required|unique:petugas,nip',
            'name' => 'required|string|max:255',
            'date_born' => 'required|date',
            'jabatan' => 'required|string|max:255',
            'address' => 'required',
            'phone' => 'required',
            'username' => 'required|unique:users,username',
            'password' => 'required|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation Error',
                'errors' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();

        try {

            $petugas = Petugas::create([
                'nip' => $request->nip,
                'name' => $request->name,
                'date_born' => $request->date_born,
                'jabatan' => $request->jabatan,
                'address' => $request->address,
                'phone' => $request->phone,
            ]);

            $user = User::create([
                'username' => $request->username,
                'password' => Hash::make($request->password),
                'role' => 'petugas',
                'ref_id' => $petugas->id,
            ]);

            // Generate Sanctum Token
            $token = $user->createToken('petugas-token')->plainTextToken;

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Registrasi berhasil',
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'username' => $user->username,
                    'role' => $user->role,
                ],
                'petugas' => $petugas
            ], 201);

        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Registrasi gagal',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username' => 'required|exists:users,username',
            'password' => 'required|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation Error',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('username', $request->username)->first();

        $user->update([
            'password' => Hash::make($request->password)
        ]);

        // Hapus semua token lama (opsional)
        $user->tokens()->delete();

        // Buat token baru
        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil direset',
            'token' => $token
        ]);
    }
}
