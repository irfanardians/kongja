# Chat Frontend Handoff

Dokumen ini dibuat khusus agar tim frontend cepat paham cara pakai chat backend tanpa harus membaca seluruh implementasi backend.

Kalau disederhanakan, frontend hanya perlu memahami 4 hal:

1. room chat tetap diambil dan dibuka lewat REST
2. realtime detail chat memakai socket `/chat`
3. badge dan activity memakai socket `/notifications`
4. jika room lama sudah mati, pakai endpoint `reactivate`, jangan buat room baru lagi

## 1. Yang Harus Dilakukan Frontend

### Saat Masuk ke App

1. login dan simpan `access_token`
2. connect socket `/notifications`
3. emit `subscribe_notifications`
4. panggil `GET /api/v1/notifications/unread-summary`
5. tampilkan badge dari hasil summary

### Saat Buka Daftar Chat

1. panggil `GET /api/v1/chat-sessions`
2. render room list
3. pakai `status`, `last_message_at`, `unread_count`, `is_active_now`

### Saat Buka Detail Room

1. panggil `GET /api/v1/chat/{roomId}/messages`
2. connect socket `/chat`
3. emit `join_room`
4. connect socket `/notifications` jika belum terhubung
5. emit `mark_room_read` agar unread room dan read receipt ikut diproses backend
6. dengarkan event `chat_message`
7. dengarkan event `message_read`

Catatan:

- saat room dibuka, frontend tidak cukup hanya menganggap unread turun secara lokal
- frontend perlu benar-benar emit `mark_room_read`
- setelah `mark_room_read` sukses, backend dapat menurunkan unread summary dan emit `message_read` ke sisi pengirim

### Saat Kirim Pesan

1. emit `send_message` ke namespace `/chat`
2. tunggu ack dari backend
3. jika ack sukses, update optimistic message menjadi confirmed
4. jika ack gagal, tampilkan error dan jangan anggap pesan terkirim

## 2. Endpoint REST Yang Dipakai Frontend

### Buat Room Baru

Jika belum pernah ada room atau frontend memang belum punya `room_id`, pakai:

`POST /api/v1/meet-requests`

Contoh body:

```json
{
  "talent_account_id": "TALENT_ACCOUNT_ID",
  "channel_type": "chat",
  "duration_minutes": 60
}
```

### Ambil Daftar Chat

`GET /api/v1/chat-sessions`

### Ambil Histori Pesan

`GET /api/v1/chat/{roomId}/messages`

### Kirim Pesan via REST Fallback

`POST /api/v1/chat/{roomId}/messages`

Contoh body:

```json
{
  "content": "Halo kak"
}
```

### Reactivate Room Lama

Jika frontend sudah punya `room_id` lama dan room itu sudah mati, pakai:

`POST /api/v1/chat/{roomId}/reactivate`

Contoh body:

```json
{
  "duration_minutes": 60
}
```

Artinya:

- room tetap sama
- `room_id` tidak berubah
- durasi ditambah 60 menit lagi

## 3. Socket Yang Dipakai Frontend

### Namespace `/chat`

Dipakai hanya untuk detail room dan bubble message realtime.

Event dari frontend:

- `join_room`
- `send_message`

Event dari backend:

- `chat_message`
- `message_read`
- `chat_error`

### Namespace `/notifications`

Dipakai untuk badge, unread summary, dan activity chat.

Event dari frontend:

- `subscribe_notifications`
- `mark_room_read`

Event dari backend:

- `notification_activity`
- `notification_unread_summary`

## 4. Payload Yang Paling Penting

### `join_room`

Kirim:

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
    "joined_at": "2026-05-01T10:00:00.000Z"
  }
}
```

### `send_message`

Kirim:

```json
{
  "room_id": "ROOM_ID",
  "content": "hi apakah ini masih tersambung",
  "message_type": "text",
  "client_message_id": "local-1714210000"
}
```

Ack sukses:

```json
{
  "success": true,
  "event": "message_sent",
  "data": {
    "id": "MESSAGE_ID",
    "room_id": "ROOM_ID",
    "sender_account_id": "ACCOUNT_ID",
    "sender_role": "user",
    "message_type": "text",
    "content": "hi apakah ini masih tersambung",
    "created_at": "2026-05-01T10:00:00.000Z",
    "client_message_id": "local-1714210000",
    "room_status": "confirmed"
  }
}
```

Ack gagal:

```json
{
  "success": false,
  "event": "chat_error",
  "data": {
    "code": "ROOM_NOT_JOINED",
    "message": "You are not a participant in this room",
    "room_id": "ROOM_ID",
    "client_message_id": "local-1714210000"
  }
}
```

### `chat_message`

Frontend juga harus tetap dengarkan event ini, karena ini event realtime yang masuk ke room.

```json
{
  "id": "MESSAGE_ID",
  "room_id": "ROOM_ID",
  "sender_account_id": "ACCOUNT_ID",
  "sender_role": "user",
  "message_type": "text",
  "content": "hi apakah ini masih tersambung",
  "created_at": "2026-05-01T10:00:00.000Z",
  "client_message_id": "local-1714210000",
  "room_status": "confirmed"
}
```

### `message_read`

Kalau lawan bicara membuka room atau menandai room sudah dibaca, backend akan mengirim event ini:

```json
{
  "room_id": "ROOM_ID",
  "reader_account_id": "ACCOUNT_ID_READER",
  "reader_role": "talent",
  "last_read_message_id": "MESSAGE_ID",
  "read_at": "2026-05-01T10:00:00.000Z"
}
```

Frontend pengirim harus memakai event ini untuk mengubah status bubble dari `sent` menjadi `read`.

Frontend pembaca tetap harus emit `mark_room_read` lebih dulu agar backend punya trigger untuk mengirim event ini.

### `notification_unread_summary`

Payload badge global:

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
  "last_updated_at": "2026-05-01T10:00:00.000Z"
}
```

## 5. Aturan Penting Untuk Frontend

1. Jangan menunggu event `message_sent` biasa. Untuk pengiriman pesan, frontend sebaiknya menunggu ack `emitWithAck`.
2. Tetap dengarkan `chat_message`, karena itu dipakai untuk update bubble realtime.
3. Saat detail room dibuka, emit `mark_room_read`; jangan hanya mengubah unread secara lokal.
4. Jangan membuat room baru kalau room lama hanya mati. Pakai `POST /api/v1/chat/{roomId}/reactivate`.
5. Status room yang aman diasumsikan saat ini hanya `pending` dan `confirmed`.
6. Untuk tahu room aktif atau tidak, gunakan `is_active_now`, `starts_at`, dan `ends_at`.
7. `message_type` saat ini hanya `text`.

## 6. Rumus Frontend Yang Paling Aman

Kalau diringkas ke logika frontend:

- belum punya `room_id` -> buat room baru
- sudah punya `room_id` dan room masih aktif -> buka room itu
- sudah punya `room_id` tapi room mati -> tampilkan konfirmasi lalu hit `reactivate`
- kirim pesan -> `emitWithAck('send_message', payload)`
- kalau ack sukses -> tandai terkirim
- kalau ack gagal -> tampilkan error
- saat room dibuka -> `emitWithAck('mark_room_read', { room_id })`
- kalau ada `chat_message` -> append ke list chat
- kalau ada `message_read` -> tandai outgoing message sampai `last_read_message_id` sebagai `read`
- kalau ada `notification_unread_summary` -> update badge

## 7. Dokumen Rujukan

Untuk detail yang lebih teknis, lihat:

- `CHAT_SOCKET_CONTRACT.md`
- `CHAT_SESSION_FRONTEND_FLOW.md`
- `NOTIFICATIONS_INTEGRATION_GUIDE.md`