# Notifications Integration Guide

Dokumen ini menjelaskan integrasi notifikasi Kongja dari sisi frontend.

Panduan ini sengaja fokus pada notifikasi chat agar selaras dengan flow room chat yang sudah dipakai frontend mobile.

Panduan ini fokus pada:
- unread badge summary chat
- socket event notifikasi realtime chat
- registrasi device token untuk push chat
- revoke token saat logout
- payload push untuk chat activity

Base path default backend:

- `/api/v1`

## Endpoint Ringkas

- `GET /api/v1/notifications/unread-summary`
- `POST /api/v1/devices/token`
- `POST /api/v1/devices/token/revoke`
- `POST /api/v1/auth/logout`

Socket namespace:

- `/notifications`

Socket event masuk:

- `notification_activity`
- `notification_unread_summary`

Semua endpoint pada dokumen ini membutuhkan header berikut kecuali proses login yang menghasilkan token awal:

```http
Authorization: Bearer <access_token>
```

## 1. Load Awal Badge

Saat app dibuka atau user kembali ke foreground, frontend sebaiknya memanggil:

`GET /api/v1/notifications/unread-summary`

Endpoint ini dipakai untuk badge Activity talent, badge inbox, dan ringkasan unread chat saat reconnect. Untuk fase sekarang, summary cukup fokus ke chat.

Contoh response:

```json
{
  "success": true,
  "data": {
    "total_unread_messages": 3,
    "total_unread_rooms": 1,
    "pending_chat_rooms": 2,
    "chat": {
      "unread_messages": 3,
      "unread_rooms": 1,
      "pending_rooms": 2
    },
    "last_updated_at": "2026-04-27T10:00:00.000Z"
  }
}
```

Arti field yang dipakai frontend chat:

- `total_unread_messages`: total pesan chat yang belum dibaca untuk account saat ini
- `total_unread_rooms`: jumlah room chat yang masih punya unread
- `pending_chat_rooms`: jumlah room chat baru yang masih menunggu talent membuka atau membalas
- `chat.unread_messages`: bucket unread khusus channel `chat`
- `chat.unread_rooms`: jumlah room chat dengan unread khusus channel `chat`
- `chat.pending_rooms`: room chat baru khusus channel `chat`

Frontend talent bisa memakai aturan sederhana berikut:

1. badge bottom nav Activity memakai `chat.unread_rooms + chat.pending_rooms`
2. badge icon notifikasi di home memakai `total_unread_rooms + pending_chat_rooms`
3. saat user membuka room chat tertentu, frontend tetap perlu refresh summary agar badge global turun sinkron

## 2. Realtime Saat App Sedang Terbuka

Frontend harus membuka socket ke namespace `/notifications` menggunakan access token.

Contoh handshake auth:

```json
{
  "token": "ACCESS_TOKEN"
}
```

### Event `notification_activity`

Event ini dikirim saat ada aktivitas penting, misalnya:
- room chat baru dibuat oleh user
- ada pesan chat baru
- balasan pertama talent mengaktifkan room

Untuk kebutuhan chat saat ini, backend sebaiknya konsisten mengirim salah satu `type` berikut:

- `chat_room_created`
- `chat_message_created`
- `chat_room_activated`

Contoh payload:

```json
{
  "type": "chat_message_created",
  "room": {
    "id": "ROOM_ID",
    "status": "pending",
    "channel_type": "chat",
    "starts_at": null,
    "ends_at": null,
    "is_active_now": false
  },
  "room_id": "ROOM_ID",
  "channel_type": "chat",
  "actor_account_id": "ACCOUNT_SENDER",
  "recipient_account_id": "ACCOUNT_TARGET",
  "message_id": "MESSAGE_ID",
  "preview_text": "Halo kak",
  "created_at": "2026-04-27T10:00:00.000Z"
}
```

Aturan konsumsi event di frontend chat:

1. jika `recipient_account_id` cocok dengan account aktif, tampilkan badge atau local notification
2. jika `room_id` sedang terbuka di layar chat aktif, append message atau refresh histori
3. jika room tidak sedang terbuka, update unread summary lokal lalu tampilkan badge
4. jika `type` adalah `chat_room_activated`, update label status room dari `pending` ke `confirmed` atau `active` sesuai kontrak backend

### Event `notification_unread_summary`

Event ini dikirim agar badge frontend langsung sinkron setelah ada activity atau room dibaca.

Contoh payload:

```json
{
  "total_unread_messages": 3,
  "total_unread_rooms": 1,
  "pending_chat_rooms": 2,
  "chat": {
    "unread_messages": 3,
    "unread_rooms": 1,
    "pending_rooms": 2
  },
  "last_updated_at": "2026-04-27T10:00:00.000Z"
}
```

Event ini sebaiknya dianggap sebagai sumber kebenaran badge global. Frontend boleh tetap optimistic update, tetapi saat event ini masuk nilainya harus menimpa state badge lokal.

## 2.1 Kontrak Event Socket.IO Notifications

Bagian ini adalah kontrak yang disarankan khusus untuk notifikasi chat pada badge dan inbox talent.

### Namespace

- `/notifications`

### Handshake Auth

Contoh auth handshake:

```json
{
  "token": "ACCESS_TOKEN"
}
```

### Event Dari Server Ke Client

#### 1. `notification_activity`

Event ini dikirim ke account target saat ada activity chat yang perlu diperhatikan.

Type yang disarankan:

- `chat_room_created`
- `chat_message_created`
- `chat_room_activated`

Payload minimum:

```json
{
  "type": "chat_message_created",
  "room_id": "ROOM_ID",
  "channel_type": "chat",
  "actor_account_id": "ACCOUNT_SENDER",
  "recipient_account_id": "ACCOUNT_TARGET",
  "created_at": "2026-04-27T10:00:00.000Z"
}
```

Payload lengkap yang disarankan:

```json
{
  "type": "chat_message_created",
  "room": {
    "id": "ROOM_ID",
    "status": "pending",
    "channel_type": "chat",
    "starts_at": null,
    "ends_at": null,
    "is_active_now": false
  },
  "room_id": "ROOM_ID",
  "channel_type": "chat",
  "actor_account_id": "ACCOUNT_SENDER",
  "recipient_account_id": "ACCOUNT_TARGET",
  "message_id": "MESSAGE_ID",
  "preview_text": "Halo kak",
  "created_at": "2026-04-27T10:00:00.000Z"
}
```

#### 2. `notification_unread_summary`

Event ini dikirim segera setelah backend selesai menghitung ulang unread global.

Payload:

```json
{
  "total_unread_messages": 3,
  "total_unread_rooms": 1,
  "pending_chat_rooms": 2,
  "chat": {
    "unread_messages": 3,
    "unread_rooms": 1,
    "pending_rooms": 2
  },
  "last_updated_at": "2026-04-27T10:00:00.000Z"
}
```

### Event Opsional Dari Client Ke Server

Backend boleh menambahkan event berikut jika ingin sinkronisasi unread lebih cepat tanpa menunggu REST.

#### 1. `subscribe_notifications`

Dipakai setelah connect untuk memastikan socket terikat ke account aktif.

Payload:

```json
{
  "scope": "chat"
}
```

#### 2. `mark_room_read`

Dipakai saat frontend membuka room dan ingin badge global segera turun.

Payload:

```json
{
  "room_id": "ROOM_ID"
}
```

Ack sukses yang disarankan:

```json
{
  "success": true,
  "event": "room_marked_read",
  "data": {
    "room_id": "ROOM_ID"
  }
}
```

### Aturan Emit Backend

1. emit `notification_activity` hanya ke recipient yang relevan, bukan broadcast global
2. setelah emit activity, backend sebaiknya langsung emit `notification_unread_summary` ke recipient yang sama
3. jika satu pesan mempengaruhi dua pihak, summary harus dihitung per account dan dikirim terpisah
4. untuk fase chat saat ini, field `channel_type` harus selalu bernilai `chat`

### Aturan Konsumsi Frontend

1. jika menerima `notification_activity`, frontend boleh update list lokal atau tampilkan local notification
2. badge bottom nav dan icon home harus mengikuti `notification_unread_summary`
3. jika event summary tidak diterima, frontend fallback ke `GET /api/v1/notifications/unread-summary`
4. jika room sedang terbuka, frontend tetap proses `chat_message` di namespace `/chat`; namespace `/notifications` dipakai untuk badge dan activity ringkasan

## 3. Registrasi Device Token Untuk Push

Setelah login sukses dan app sudah memperoleh token FCM, frontend panggil:

`POST /api/v1/devices/token`

Contoh body:

```json
{
  "token": "fcm-device-token-value",
  "platform": "android",
  "device_id": "emulator-5554",
  "app_version": "1.0.0+12",
  "provider": "fcm"
}
```

Contoh response sukses:

```json
{
  "success": true,
  "message": "Device token registered successfully",
  "data": {
    "token": "fcm-device-token-value",
    "platform": "android",
    "device_id": "emulator-5554",
    "provider": "fcm",
    "is_active": true,
    "updated_at": "2026-04-27T10:00:00.000Z"
  }
}
```

Catatan implementasi frontend chat:

1. token dikirim setelah login sukses dan `auth/me` selesai jika frontend butuh bootstrap session penuh
2. jika Firebase mengembalikan token baru, kirim ulang ke endpoint yang sama
3. registrasi token tidak menggantikan socket realtime; push dipakai saat app background atau terminated

## 4. Revoke Device Token

Saat user logout, frontend sebaiknya mengirim request logout dengan `device_token` atau `device_id` agar token push device ini tidak terus dipakai.

Contoh request logout:

```json
{
  "refresh_token": "refresh-token-value",
  "device_token": "fcm-device-token-value",
  "device_id": "emulator-5554"
}
```

Jika frontend ingin revoke tanpa logout penuh, gunakan:

`POST /api/v1/devices/token/revoke`

Contoh body:

```json
{
  "token": "fcm-device-token-value",
  "device_id": "emulator-5554"
}
```

## 5. Perilaku Push Saat Ini

Backend saat ini sudah bisa mengirim push FCM untuk activity chat jika environment FCM diisi dan `PUSH_ENABLED=true`.

Event yang akan memicu push:
- `chat_room_created`
- `chat_message_created`
- `chat_room_activated`

Payload `data` pada push akan membawa field activity yang sama seperti socket event agar frontend bisa menentukan route tujuan.

Contoh payload `data` yang aman untuk flow chat frontend:

```json
{
  "type": "chat_message_created",
  "room_id": "ROOM_ID",
  "channel_type": "chat",
  "status": "pending",
  "sender_account_id": "ACCOUNT_SENDER",
  "recipient_account_id": "ACCOUNT_TARGET",
  "message_id": "MESSAGE_ID"
}
```

Dengan payload ini, frontend bisa langsung mengarahkan user ke daftar activity atau detail room chat yang sesuai.

## 6. Environment Yang Diperlukan Backend

```env
PUSH_ENABLED=true
PUSH_PROVIDER=fcm
FCM_PROJECT_ID=your-project-id
FCM_CLIENT_EMAIL=firebase-adminsdk-xxx@your-project.iam.gserviceaccount.com
FCM_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

Jika env ini belum diisi:
- socket notifications tetap jalan
- unread summary endpoint tetap jalan
- register device token tetap tersimpan
- push FCM tidak akan dikirim

## 6.1 Cara Membuat Project Firebase

Urutan praktisnya seperti ini:

1. Buka Firebase Console.
2. Klik `Create a project`.
3. Isi nama project, misalnya `kongja-production` atau `kongja-dev`.
4. Jika diminta Google Analytics, boleh dimatikan dulu bila belum dibutuhkan.
5. Tunggu project selesai dibuat.

Setelah project jadi:

1. Buka menu `Project settings`.
2. Catat `Project ID` karena ini akan dipakai sebagai `FCM_PROJECT_ID`.
3. Masuk ke tab `Cloud Messaging`.
4. Pastikan Firebase Cloud Messaging aktif.

## 6.2 Cara Mengambil Credential Backend

Untuk backend NestJS ini, yang dibutuhkan adalah credential service account Firebase Admin SDK.

Langkahnya:

1. Di Firebase Console, buka `Project settings`.
2. Buka tab `Service accounts`.
3. Klik `Generate new private key`.
4. File JSON akan terunduh.

Dari file JSON itu, ambil field berikut:

- `project_id` untuk `FCM_PROJECT_ID`
- `client_email` untuk `FCM_CLIENT_EMAIL`
- `private_key` untuk `FCM_PRIVATE_KEY`

Contoh isi file JSON biasanya seperti ini:

```json
{
  "type": "service_account",
  "project_id": "kongja-dev",
  "private_key_id": "xxxxx",
  "private_key": "-----BEGIN PRIVATE KEY-----\nABCDEF...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxx@kongja-dev.iam.gserviceaccount.com"
}
```

Mapping ke `.env` backend:

```env
PUSH_ENABLED=true
PUSH_PROVIDER=fcm
FCM_PROJECT_ID=kongja-dev
FCM_CLIENT_EMAIL=firebase-adminsdk-xxx@kongja-dev.iam.gserviceaccount.com
FCM_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nABCDEF...\n-----END PRIVATE KEY-----\n"
```

Catatan penting:

- `FCM_PRIVATE_KEY` harus tetap memakai `\n` jika ditaruh dalam satu line `.env`
- jangan commit file JSON service account ke repository
- setelah `.env` diubah, backend harus direstart

## 6.3 Cara Menghubungkan App Flutter ke Firebase

Untuk frontend mobile, project Firebase yang sama juga harus didaftarkan ke app Android dan iOS.

### Android

1. Di Firebase Console, klik `Add app` lalu pilih Android.
2. Isi `Android package name` sesuai `applicationId` Flutter Android.
3. Download file `google-services.json`.
4. Letakkan file itu di folder Android app frontend.
5. Pastikan frontend menginstall Firebase Messaging SDK.

### iOS

1. Di Firebase Console, klik `Add app` lalu pilih iOS.
2. Isi `iOS bundle ID` sesuai project Flutter iOS.
3. Download file `GoogleService-Info.plist`.
4. Tambahkan file itu ke target iOS frontend.
5. Aktifkan capability push notification di project iOS jika diperlukan.

## 6.4 Cara Mengambil FCM Device Token di Frontend

Setelah Firebase terpasang di app frontend:

1. minta izin notifikasi ke user
2. ambil FCM device token dari SDK Firebase Messaging
3. kirim token itu ke backend lewat `POST /api/v1/devices/token`
4. jika token berubah, kirim ulang ke endpoint yang sama

## 6.5 Checklist Aktivasi Push

Checklist cepatnya:

1. buat project Firebase
2. aktifkan Cloud Messaging
3. generate service account JSON
4. isi `.env` backend dengan `FCM_PROJECT_ID`, `FCM_CLIENT_EMAIL`, `FCM_PRIVATE_KEY`
5. set `PUSH_ENABLED=true`
6. restart backend
7. pasang Firebase Messaging di Flutter
8. ambil device token
9. kirim device token ke `POST /api/v1/devices/token`
10. tes kirim chat baru untuk memastikan push masuk

## 7. Urutan Frontend Yang Disarankan

Saat login:

1. login
2. simpan access token dan refresh token
3. bootstrap session dengan `GET /api/v1/auth/me` bila diperlukan
4. connect socket `/notifications`
5. ambil FCM device token
6. `POST /api/v1/devices/token`
7. `GET /api/v1/notifications/unread-summary`

Saat app menerima activity:

1. tangkap `notification_activity`
2. update local state list atau inbox bila perlu
3. tangkap `notification_unread_summary`
4. update badge secara langsung
5. jika event tidak lengkap atau socket terputus, fallback ke `GET /api/v1/notifications/unread-summary`

Saat logout:

1. panggil `POST /api/v1/auth/logout`
2. kirim `refresh_token`
3. kirim `device_token` atau `device_id` bila tersedia
4. putuskan socket
5. hapus session lokal

## 8. Hubungan Dengan Auth Guide

Supaya flow chat notifikasi konsisten, baca dokumen auth bersamaan dengan panduan ini:

- login dan token bootstrap ada di `AUTH_INTEGRATION_GUIDE.md`
- registrasi device token dilakukan setelah login sukses
- logout sebaiknya ikut mengirim `device_token` dan `device_id` agar push chat ke device lama langsung berhenti