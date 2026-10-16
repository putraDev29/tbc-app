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
        $factory = (new Factory)
            ->withServiceAccount(storage_path('firebase/firebase.json'));

        $this->messaging = $factory->createMessaging();
    }

    public function sendToUser($userId, $title, $body, $type = 'obat', array $extraData = [])
    {
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
