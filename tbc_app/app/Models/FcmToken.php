<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\User;

class FcmToken extends Model
{
    protected $fillable = ['user_id', 'token', 'device'];

    public function user()
    {
        return $this->belongsTo(User::class);
        //                foreign key ↑      owner key ↑
    }
}