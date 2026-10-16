importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDJM2G6W3q5pxyGLzfjGvJ-O7vX2jxCpdc",
  appId: "1:968298990752:web:e8452d9c26a0e2438b0dc5",
  messagingSenderId: "968298990752",
  projectId: "tbc-app-3965b",
  authDomain: "tbc-app-3965b.firebaseapp.com",
  storageBucket: "tbc-app-3965b.firebasestorage.app"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  console.log("[firebase-messaging-sw.js] Received background message ", payload);
  const notificationTitle = payload.notification ? payload.notification.title : "Notifikasi TBC";
  const notificationOptions = {
    body: payload.notification ? payload.notification.body : "",
    icon: "/icons/Icon-192.png"
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

