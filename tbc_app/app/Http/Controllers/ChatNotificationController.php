<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\FcmToken;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Firebase\Messaging\AndroidConfig;

class ChatNotificationController extends Controller
{
    public function sendChatNotification($receiverId, $senderName, $chatMessage, $role = null)
    {
        $tokens = FcmToken::where('user_id', $receiverId)
            ->pluck('token')
            ->filter()
            ->unique()
            ->values()
            ->toArray();

        if (empty($tokens)) {
            return;
        }

        $factory = (new Factory)
            ->withServiceAccount(storage_path('firebase/firebase.json'));

        $messaging = $factory->createMessaging();

        foreach ($tokens as $token) {

            $message = CloudMessage::withTarget('token', $token)
                ->withNotification(Notification::create(
                    "Pesan Baru dari $senderName",
                    $chatMessage
                ))
                ->withAndroidConfig(
                    AndroidConfig::fromArray([
                        'priority' => 'high',
                        'notification' => [
                            'sound' => 'default',
                            'channel_id' => 'channel_chat_v1'
                        ],
                    ])
                )
                ->withData([
                    "status"      => "default",
                    "type"        => "chat",
                    "sender_name" => (string) $senderName,
                    "message"     => (string) $chatMessage
                ]);

            try {
                $messaging->send($message);
            } catch (\Exception $e) {
                Log::error("FCM CHAT Error: " . $e->getMessage());
            }
        }
    }

    public function sendChatNotificationApi(Request $request)
    {
        $request->validate([
            'receiver_id' => 'required',
            'sender_name' => 'required|string',
            'message'     => 'required|string',
            'role'        => 'nullable|string',
        ]);

        $this->sendChatNotification(
            $request->receiver_id,
            $request->sender_name,
            $request->message,
            $request->role
        );

        return response()->json([
            'message' => 'Notif chat sent'
        ]);
    }
}
