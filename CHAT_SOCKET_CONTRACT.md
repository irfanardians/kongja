# Chat Socket Contract

Dokumen ini adalah kontrak final Socket.IO untuk chat yang siap diberikan ke tim frontend.

Versi yang lebih mudah dibaca untuk tim frontend ada di `CHAT_FRONTEND_HANDOFF.md`.

Dokumen ini mengikuti implementasi backend yang sekarang, bukan hanya brief awal. Jika ada perbedaan antara brief dan implementasi, dokumen ini yang menjadi acuan integrasi frontend.

Base path REST:

- `/api/v1`

Socket namespace:

- `/chat`
- `/notifications`

## 1. Auth Socket

Backend menerima salah satu bentuk auth berikut saat connect socket:

Header:

```http
Authorization: Bearer <access_token>
```

Atau auth payload:

```json
{
  "token": "ACCESS_TOKEN"
}
```

## 2. Namespace `/chat`

Namespace ini dipakai untuk detail room chat dan realtime bubble message.

### 2.1 Event Dari Client

#### `join_room`

Payload:

```json
{
  "room_id": "ROOM_ID"
}
```

Ack sukses:

```json
{
  "success": true,
  "event": "room_joined",
  "data": {
    "room_id": "ROOM_ID",
    "joined_at": "2026-04-27T10:00:00.000Z"
  }
}
```

Ack gagal:

```json
{
  "success": false,
  "event": "chat_error",
  "data": {
    "code": "ROOM_NOT_FOUND",
    "message": "Interaction room was not found",
    "room_id": "ROOM_ID"
  }
}
```

#### `send_message`

Payload final yang disarankan frontend:

```json
{
  "room_id": "ROOM_ID",
  "content": "Halo kak, saya mau tanya",
  "message_type": "text",
  "client_message_id": "local-1714210000"
}
```

Catatan:

- `message_type` saat ini hanya menerima `text`
- backend masih menerima field `message` sebagai alias kompatibilitas, tetapi frontend baru sebaiknya mengirim `content`
- `client_message_id` opsional, tetapi disarankan untuk sinkron optimistic UI
- backend memvalidasi minimal `room_id`, `content`, dan `message_type`

Ack sukses:

```json
{
  "success": true,
  "event": "message_sent",
  "data": {
    "id": "MESSAGE_ID",
    "room_id": "ROOM_ID",
    "sender_account_id": "ACCOUNT_SENDER",
    "sender_role": "user",
    "message_type": "text",
    "content": "Halo kak, saya mau tanya",
    "created_at": "2026-04-27T10:00:00.000Z",
    "client_message_id": "local-1714210000",
    "room_status": "pending"
  }
}
```

Ack gagal:

```json
{
  "success": false,
  "event": "chat_error",
  "data": {
    "code": "MESSAGE_VALIDATION_FAILED",
    "message": "Message content must not be empty",
    "room_id": "ROOM_ID",
    "client_message_id": "local-1714210000"
  }
}
```

### 2.2 Event Dari Server

#### `chat_message`

Event ini dikirim ke semua socket participant yang sudah join ke room.

Payload final:

```json
{
  "id": "MESSAGE_ID",
  "room_id": "ROOM_ID",
  "sender_account_id": "ACCOUNT_SENDER",
  "sender_role": "user",
  "message_type": "text",
  "content": "Halo kak, saya mau tanya",
  "created_at": "2026-04-27T10:00:00.000Z",
  "client_message_id": "local-1714210000",
  "room_status": "pending"
}
```

Catatan status:

- `room_status` saat ini mengikuti status database room
- nilai yang sekarang muncul dari backend adalah `pending` atau `confirmed`
- frontend tidak boleh mengasumsikan ada string `active` atau `closed` dari event ini

#### `message_read`

Event ini dikirim ke participant lawan bicara setelah backend memproses `mark_room_read` dengan sukses.

Payload final:

```json
{
  "room_id": "ROOM_ID",
  "reader_account_id": "ACCOUNT_ID_READER",
  "reader_role": "talent",
  "last_read_message_id": "MESSAGE_ID",
  "read_at": "2026-05-01T10:00:00.000Z"
}
```

Fungsi event ini:

- dipakai frontend pengirim untuk mengubah bubble dari `sent` menjadi `read`
- `last_read_message_id` dipakai sebagai batas terakhir pesan yang sudah dibaca

#### `chat_error`

Payload final:

```json
{
  "code": "ROOM_NOT_JOINED",
  "message": "You are not a participant in this room",
  "room_id": "ROOM_ID",
  "client_message_id": "local-1714210000"
}
```

Kode yang sekarang dipakai backend:

- `UNAUTHORIZED`
- `ROOM_NOT_FOUND`
- `ROOM_NOT_JOINED`
- `MESSAGE_VALIDATION_FAILED`
- `CHAT_SESSION_CLOSED`

## 3. Namespace `/notifications`

Namespace ini dipakai untuk badge, unread summary, dan chat activity. Namespace ini bukan untuk render bubble chat detail.

### 3.1 Event Dari Client

#### `subscribe_notifications`

Payload opsional yang direkomendasikan frontend:

```json
{
  "scope": "chat"
}
```

Ack sukses:

```json
{
  "success": true,
  "event": "notifications_subscribed",
  "data": {
    "scope": "chat"
  }
}
```

#### `mark_room_read`

Payload:

```json
{
  "room_id": "ROOM_ID"
}
```

Setelah `mark_room_read` sukses, backend saat ini juga akan:

- emit `notification_unread_summary` jika unread berubah
- emit `message_read` ke participant lawan bicara di namespace `/chat`

Ack sukses:

```json
{
  "success": true,
  "event": "room_marked_read",
  "data": {
    "room_id": "ROOM_ID"
  }
}
```

### 3.2 Event Dari Server

#### `notification_activity`

Type yang saat ini bisa muncul:

- `chat_room_created`
- `chat_message_created`
- `chat_room_activated`
- `chat_room_reactivated`

Payload final:

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

Untuk `chat_room_reactivated`, payload juga dapat membawa:

```json
{
  "extension_minutes": 60
}
```

#### `notification_unread_summary`

Payload final:

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

## 4. REST Endpoint Yang Terkait Langsung Dengan Socket

Endpoint REST yang frontend masih perlu pakai bersama socket:

- `POST /api/v1/meet-requests`
- `GET /api/v1/chat-sessions`
- `GET /api/v1/chat/{roomId}/messages`
- `POST /api/v1/chat/{roomId}/messages`
- `POST /api/v1/chat/{roomId}/reactivate`
- `GET /api/v1/notifications/unread-summary`

## 5. Mismatch Antara Brief dan REST Yang Sekarang

Bagian ini penting supaya frontend tidak salah asumsi.

### 5.1 Pembuatan Room Baru

Brief socket fokus ke chat, tetapi REST untuk membuat room baru masih memakai endpoint umum:

- `POST /api/v1/meet-requests`

Bukan endpoint yang lebih spesifik seperti `/chat/rooms`.

Artinya frontend harus tetap mengirim:

```json
{
  "talent_account_id": "TALENT_ACCOUNT_ID",
  "channel_type": "chat",
  "duration_minutes": 60
}
```

### 5.2 List Chat Session

Summary controller saat ini berbunyi “List confirmed chat sessions”, tetapi implementasi service sebenarnya mengembalikan:

- room `pending`
- room `confirmed`

Jadi frontend harus siap menerima room pending di `GET /api/v1/chat-sessions`.

### 5.3 Kirim Pesan REST

Summary controller saat ini berbunyi “Send a text chat message in an active confirmed chat room”, tetapi implementasi service sebenarnya mengizinkan:

- room `pending`
- room `confirmed` yang masih aktif

Jadi frontend boleh mengirim pesan pertama walaupun room masih `pending`.

### 5.4 Reactivate Room

Brief awal belum membahas endpoint extension khusus, tetapi backend sekarang sudah punya:

- `POST /api/v1/chat/{roomId}/reactivate`

Frontend sebaiknya memakai endpoint ini saat room lama sudah mati dan user menekan konfirmasi tambah durasi, bukan membuat room baru lagi.

### 5.5 `room_status` Di Event Socket

Brief sempat membuka kemungkinan nilai seperti `active` atau `closed`, tetapi backend sekarang mengirim status database room apa adanya.

Nilai yang aman diasumsikan frontend saat ini:

- `pending`
- `confirmed`

Status aktif/nonaktif sebaiknya dibaca dari:

- `starts_at`
- `ends_at`
- `is_active_now`

## 6. Rekomendasi Frontend

Urutan yang paling aman untuk frontend sekarang:

1. load room list dari `GET /api/v1/chat-sessions`
2. load histori dari `GET /api/v1/chat/{roomId}/messages`
3. connect socket `/notifications`
4. emit `subscribe_notifications`
5. connect socket `/chat`
6. emit `join_room`
7. kirim pesan dengan `send_message` atau fallback REST
8. jika room lama mati, tampilkan konfirmasi lalu hit `POST /api/v1/chat/{roomId}/reactivate`

## 7. Status Dokumen

Dokumen ini dibuat berdasarkan implementasi backend saat ini. Jika nantinya endpoint REST chat dibuat lebih spesifik, dokumen ini perlu diperbarui lagi.