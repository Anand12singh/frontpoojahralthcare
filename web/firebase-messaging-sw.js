

importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCpi-D1HvaNYJqz8yojgfm1mBGxYNIqVtY",
  authDomain: "pooja-healthcare.firebaseapp.com",
  projectId: "pooja-healthcare",
  storageBucket: "pooja-healthcare.appspot.com",
  messagingSenderId: "991470240442",
  appId: "1:991470240442:web:b24f916c64b22dbf42b883",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("📩 Background message received: ", payload);

  const notificationTitle = payload.notification?.title || "New Notification";
  const notificationOptions = {
    body: payload.notification?.body || "You have a new message.",
    icon: "/icons/icon-192x192.png",
    data: payload.data || {},
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
