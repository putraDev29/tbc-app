<?php

namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Firebase\Messaging\AndroidConfig;
use App\Models\FcmToken;

class FcmService
{
    protected $messaging;

    public function __construct()
    {
        $firebasePath = storage_path('firebase/firebase.json');

        if (!file_exists($firebasePath)) {
            \Illuminate\Support\Facades\Log::warning("FCM Warning: Service account file not found at $firebasePath");
            return;
        }

        try {
            $factory = (new Factory)->withServiceAccount($firebasePath);
            $this->messaging = $factory->createMessaging();
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error("FCM Init Error: " . $e->getMessage());
        }
    }

    public function sendToUser($userId, $title, $body, $type = 'obat', array $extraData = [])
    {
        if (!$this->messaging) {
            \Illuminate\Support\Facades\Log::warning("FCM Warning: Messaging service is not initialized, skipping notification.");
            return;
        }

        $tokens = FcmToken::where('user_id', $userId)
            ->pluck('token')
            ->filter()
            ->unique()
            ->values()
            ->toArray();

        if (empty($tokens)) {
            return;
        }

        $dataPayload = array_merge([
            "type"   => $type,
            "status" => "default",
        ], $extraData);

        foreach ($tokens as $token) {

            $message = CloudMessage::withTarget('token', $token)
                ->withNotification(Notification::create($title, $body))
                ->withAndroidConfig(
                    AndroidConfig::fromArray([
                        'priority' => 'high',
                        'notification' => [
                            'sound' => 'notif_sound',
                            'channel_id' => 'channel_medicine_v1'
                        ],
                    ])
                )
                ->withData($dataPayload);

            try {
                $this->messaging->send($message);
            } catch (\Exception $e) {
                \Illuminate\Support\Facades\Log::error('FCM Error: ' . $e->getMessage());
            }
        }
    }
}
