# Chat Socket Backend Implementation Brief

Dokumen ini dibuat sebagai versi yang lebih siap dikirim ke tim backend untuk implementasi Socket.IO chat dan chat notification.

Scope dokumen ini sengaja sempit:

- chat room realtime
- chat message realtime
- unread summary chat
- badge notification chat untuk talent
- tidak membahas call, video, atau notifikasi di luar domain chat

Base path auth REST yang sudah dipakai frontend:

- `/api/v1`

Socket namespace yang dibutuhkan:

- `/chat`
- `/notifications`

## 1. Tujuan Implementasi Backend

Backend perlu menyediakan 2 jalur realtime yang terpisah tetapi saling sinkron:

1. namespace `/chat` untuk detail room chat aktif
2. namespace `/notifications` untuk badge unread, room baru, dan activity summary

Target hasil yang diharapkan:

1. saat user mengirim pesan, talent yang sedang membuka room menerima `chat_message`
2. saat talent belum membuka room, talent tetap menerima `notification_activity` dan `notification_unread_summary`
3. saat talent membuka room atau membaca room, unread count global bisa turun sinkron
4. frontend tidak perlu menebak event name atau bentuk payload

## 2. Scope Tiket Backend

Judul tiket yang disarankan:

`Implement Socket.IO contract for chat room updates and unread notification summary`

Acceptance criteria:

1. backend menerima koneksi Socket.IO dengan auth bearer token atau auth token payload
2. backend menerima `join_room` di namespace `/chat`
3. backend menerima `send_message` di namespace `/chat`
4. backend emit `chat_message` ke participant room setelah pesan tersimpan
5. backend emit `notification_activity` ke account target saat ada room baru atau pesan baru
6. backend emit `notification_unread_summary` setelah unread count berubah
7. payload event konsisten dengan field yang sudah dipakai frontend mobile
8. balasan pertama talent pada room `pending` mengubah status room dan ikut memicu notification update

Out of scope:

- voice note
- gift
- telephone realtime
- video realtime
- push provider implementation detail selain field yang dibutuhkan untuk chat activity

## 3. Kontrak Socket Namespace `/chat`

### 3.1 Handshake Auth

Backend harus menerima salah satu bentuk auth berikut:

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

### 3.2 Event Dari Client Ke Server

#### `join_room`

Payload:

```json
{
  "room_id": "ROOM_ID"
}
```

Validasi minimum:

1. token valid
2. room ada
3. account pengirim memang participant room

Ack sukses yang disarankan:

```json
{
  "success": true,
  "event": "room_joined",
  "data": {
    "room_id": "ROOM_ID"
  }
}
```

#### `send_message`

Payload minimum:

```json
{
  "room_id": "ROOM_ID",
  "content": "Halo kak, saya mau tanya",
  "message_type": "text"
}
```

Payload lengkap yang disarankan:

```json
{
  "room_id": "ROOM_ID",
  "content": "Halo kak, saya mau tanya",
  "message_type": "text",
  "client_message_id": "local-1714210000"
}
```

Validasi minimum:

1. token valid
2. room ada
3. sender adalah participant room
4. `content` tidak kosong
5. `message_type` default ke `text` bila tidak dikirim

Ack sukses yang disarankan:

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
    "client_message_id": "local-1714210000"
  }
}
```

### 3.3 Event Dari Server Ke Client

#### `room_joined`

Payload:

```json
{
  "room_id": "ROOM_ID",
  "joined_at": "2026-04-27T10:00:00.000Z"
}
```

#### `chat_message`

Event ini harus dikirim setelah pesan berhasil dipersist ke database.

Payload minimum:

```json
{
  "id": "MESSAGE_ID",
  "room_id": "ROOM_ID",
  "sender_account_id": "ACCOUNT_SENDER",
  "sender_role": "user",
  "message_type": "text",
  "content": "Halo kak, saya mau tanya",
  "created_at": "2026-04-27T10:00:00.000Z"
}
```

Payload lengkap yang disarankan:

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

#### `chat_error`

Payload:

```json
{
  "code": "ROOM_NOT_FOUND",
  "message": "Chat room not found",
  "room_id": "ROOM_ID"
}
```

Kode error yang disarankan:

- `UNAUTHORIZED`
- `ROOM_NOT_FOUND`
- `ROOM_NOT_JOINED`
- `MESSAGE_VALIDATION_FAILED`
- `CHAT_SESSION_CLOSED`

### 3.4 Aturan Emit Backend Untuk `/chat`

1. simpan pesan ke database lebih dulu
2. baru emit `chat_message` ke semua socket pada room Socket.IO yang sesuai
3. emit juga ke pengirim agar optimistic UI frontend bisa dikonfirmasi
4. jika balasan pertama talent mengubah status room dari `pending` ke `confirmed`, sertakan status terbaru pada event atau pastikan notification namespace ikut mengirim update

## 4. Kontrak Socket Namespace `/notifications`

Namespace ini dipakai untuk badge dan activity summary, bukan untuk render detail bubble chat.

### 4.1 Event Dari Server Ke Client

#### `notification_activity`

Type yang dibutuhkan untuk scope chat saat ini:

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

#### `notification_unread_summary`

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

### 4.2 Event Opsional Dari Client Ke Server

#### `subscribe_notifications`

Payload:

```json
{
  "scope": "chat"
}
```

#### `mark_room_read`

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

### 4.3 Aturan Emit Backend Untuk `/notifications`

1. emit `notification_activity` hanya ke recipient yang relevan
2. setelah unread berubah, emit `notification_unread_summary` ke recipient yang sama
3. unread harus dihitung per account, bukan global broadcast
4. untuk fase chat saat ini, `channel_type` selalu `chat`

## 5. DTO Yang Bisa Langsung Dipakai Backend

Contoh DTO TypeScript yang bisa dipakai sebagai acuan NestJS:

```ts
export interface JoinRoomEventDto {
  room_id: string;
}

export interface SendMessageEventDto {
  room_id: string;
  content: string;
  message_type?: 'text';
  client_message_id?: string;
}

export interface ChatMessageSocketDto {
  id: string;
  room_id: string;
  sender_account_id: string;
  sender_role: 'user' | 'talent';
  message_type: 'text';
  content: string;
  created_at: string;
  client_message_id?: string;
  room_status?: 'pending' | 'confirmed' | 'active' | 'closed';
}

export interface NotificationActivitySocketDto {
  type: 'chat_room_created' | 'chat_message_created' | 'chat_room_activated';
  room_id: string;
  channel_type: 'chat';
  actor_account_id: string;
  recipient_account_id: string;
  message_id?: string;
  preview_text?: string;
  created_at: string;
  room?: {
    id: string;
    status: 'pending' | 'confirmed' | 'active' | 'closed';
    channel_type: 'chat';
    starts_at: string | null;
    ends_at: string | null;
    is_active_now: boolean;
  };
}

export interface NotificationUnreadSummarySocketDto {
  total_unread_messages: number;
  total_unread_rooms: number;
  pending_chat_rooms: number;
  chat: {
    unread_messages: number;
    unread_rooms: number;
    pending_rooms: number;
  };
  last_updated_at: string;
}
```

## 6. Urutan Logic Backend Yang Disarankan

### Saat User Membuat Room Chat Baru

1. backend membuat meet request chat atau room chat
2. backend set status awal room `pending`
3. backend emit `notification_activity` type `chat_room_created` ke talent target
4. backend hitung unread summary talent
5. backend emit `notification_unread_summary` ke talent target

### Saat Salah Satu Pihak Mengirim Pesan

1. backend validasi participant room
2. backend simpan pesan
3. backend emit `chat_message` ke room Socket.IO `/chat`
4. backend emit `notification_activity` type `chat_message_created` ke pihak lawan
5. backend hitung ulang unread summary pihak lawan
6. backend emit `notification_unread_summary` ke pihak lawan

### Saat Talent Membalas Pertama Kali Pada Room Pending

1. backend simpan pesan talent
2. backend ubah status room menjadi `confirmed`
3. backend isi `starts_at` dan `ends_at` jika memang itu kontrak bisnis chat
4. backend emit `chat_message` ke room
5. backend emit `notification_activity` type `chat_room_activated` ke user target
6. backend emit `notification_unread_summary` ke account yang relevan

## 7. Checklist Implementasi Backend

1. buat gateway `/chat`
2. buat gateway `/notifications`
3. validasi auth token saat socket connect
4. implement `join_room`
5. implement `send_message`
6. persist pesan sebelum emit event
7. implement per-account routing untuk notification events
8. implement unread summary calculator khusus chat
9. emit `notification_unread_summary` setelah unread berubah
10. sediakan logging untuk event gagal dan auth gagal
11. uji user kirim pesan ke talent saat talent online
12. uji user kirim pesan ke talent saat talent tidak membuka room tapi masih connect `/notifications`
13. uji balasan pertama talent mengubah status room dan mengirim update ke user

## 8. Catatan Penting Untuk Tim Backend

1. frontend saat ini sudah memakai field `content` untuk kirim pesan REST dan kontrak socket ini harus mengikuti pola yang sama
2. frontend saat ini masih punya fallback polling pada histori chat, tetapi target akhirnya event socket ini menjadi sumber realtime utama
3. badge navigator talent dan notifikasi home talent akan jauh lebih stabil jika `notification_unread_summary` selalu dikirim segera setelah state unread berubah
4. jangan memakai event name yang terlalu banyak alias jika tidak perlu; satu nama final per event akan menurunkan kompleksitas frontend