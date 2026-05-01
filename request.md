# Request Backend: Read Receipt Chat

Dokumen ini adalah request perubahan backend agar status centang pesan chat bisa berjalan lancar dari sisi frontend.

## Latar Belakang

Saat ini frontend sudah mendukung:

- kirim pesan via socket-only
- optimistic bubble
- status `pending`, `sent`, `failed`
- emit `mark_room_read` saat talent membuka room atau menerima pesan user baru

Namun centang pesan di sisi pengirim masih berhenti di satu centang karena frontend belum menerima sinyal eksplisit bahwa pesan tersebut sudah dibaca oleh lawan bicara.

`mark_room_read` yang ada sekarang cukup untuk menurunkan unread summary, tetapi belum cukup untuk mengubah status bubble per pesan menjadi `read`.

## Tujuan

Backend perlu menambahkan read receipt yang eksplisit agar frontend pengirim bisa mengubah status pesan dari `sent` menjadi `read` secara realtime.

## Kondisi Yang Sudah Ada

### 1. Namespace chat

Frontend sudah memakai namespace:

- `/chat`
- `/notifications`

### 2. Event yang sudah dipakai frontend

- `join_room`
- `send_message`
- `chat_message`
- `subscribe_notifications`
- `mark_room_read`

### 3. Behavior frontend saat ini

- saat room dibuka di sisi talent, frontend akan emit `mark_room_read`
- saat pesan user baru masuk ke room yang sedang terbuka di sisi talent, frontend juga akan emit `mark_room_read`
- frontend pengirim belum punya event untuk mengetahui bahwa pesan tertentu sudah dibaca

## Request Perubahan Backend

### 1. Pertahankan `mark_room_read`

Mohon backend tetap menerima dan meng-ack event berikut di namespace `/notifications`:

```json
{
  "room_id": "ROOM_ID"
}
```

Ack sukses yang diharapkan:

```json
{
  "success": true,
  "event": "room_marked_read",
  "data": {
    "room_id": "ROOM_ID"
  }
}
```

### 2. Tambahkan event read receipt ke sisi pengirim

Setelah backend memproses `mark_room_read`, mohon emit event baru ke participant lawan bicara yang mengirim pesan.

Nama event yang disarankan:

- `message_read`

Namespace yang disarankan:

- `/chat`

Alasan:

- event ini dipakai untuk render bubble detail, bukan sekadar badge summary
- frontend chat detail saat ini sudah subscribe ke `/chat`

### 3. Payload minimum untuk read receipt

Payload minimum yang dibutuhkan frontend:

```json
{
  "room_id": "ROOM_ID",
  "reader_account_id": "ACCOUNT_ID_READER",
  "reader_role": "talent",
  "last_read_message_id": "MESSAGE_ID",
  "read_at": "2026-05-01T10:00:00.000Z"
}
```

Catatan:

- `last_read_message_id` dipakai frontend untuk menandai semua outgoing message sampai titik itu sebagai `read`
- `read_at` dipakai untuk fallback kalau frontend ingin membandingkan berbasis waktu
- `reader_role` dan `reader_account_id` membantu validasi participant yang membaca room

### 4. Bentuk event yang direkomendasikan

Contoh event realtime:

```json
{
  "event": "message_read",
  "data": {
    "room_id": "ROOM_ID",
    "reader_account_id": "ACCOUNT_ID_READER",
    "reader_role": "talent",
    "last_read_message_id": "MESSAGE_ID",
    "read_at": "2026-05-01T10:00:00.000Z"
  }
}
```

## Alur Yang Diharapkan

### Saat talent membuka room dan membaca pesan user

1. frontend talent emit `mark_room_read`
2. backend update unread state untuk room tersebut
3. backend ack `room_marked_read`
4. backend emit `notification_unread_summary` jika memang unread summary berubah
5. backend emit `message_read` ke sisi user sebagai pengirim pesan

### Saat user membuka room dan membaca pesan talent

1. frontend user nantinya bisa emit `mark_room_read` dengan pola yang sama
2. backend proses read state
3. backend emit `message_read` ke sisi talent

## Acceptance Criteria

Perubahan backend dianggap cukup jika semua kondisi berikut terpenuhi:

1. `mark_room_read` selalu mengembalikan ack sukses atau gagal secara konsisten.
2. Setelah `mark_room_read` sukses, backend mengirim read receipt ke participant lawan bicara.
3. Read receipt membawa `room_id` dan `last_read_message_id` atau field setara yang bisa dipakai frontend untuk memetakan status read.
4. Event hanya dikirim ke participant room yang relevan, bukan broadcast global.
5. `sender_role` dan `sender_account_id` pada `chat_message` tetap konsisten agar frontend tidak salah menentukan bubble kiri atau kanan.

## Catatan Implementasi

- Jika backend belum ingin menambah event baru, alternatif sementara adalah menambahkan field seperti `is_read` atau `read_at` pada response `GET /api/v1/chat/{roomId}/messages`.
- Alternatif itu tetap kurang ideal untuk realtime karena status centang dua baru akan berubah setelah polling atau refresh.
- Karena itu event `message_read` tetap menjadi solusi yang paling stabil.

## Ringkasan Singkat Untuk Tim Backend

Yang perlu ditambahkan bukan hanya unread summary, tetapi sinyal read receipt per room agar frontend pengirim bisa mengubah centang satu menjadi centang dua.