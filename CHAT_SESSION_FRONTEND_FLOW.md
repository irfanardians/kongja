# Chat Session Frontend Flow

Dokumen ini dibuat agar tim frontend bisa langsung memahami alur chat session dari sisi `user` dan sisi `talent` tanpa harus membaca implementasi backend satu per satu.

Dokumen ini fokus pada:
- urutan endpoint yang harus dipanggil
- perbedaan flow `user` dan `talent`
- kapan room masih `pending`
- kapan chat menjadi `active`
- cara menerima pesan realtime

## Ringkasan Aturan Produk

Aturan chat saat ini adalah sebagai berikut:

1. `user` boleh membuat room chat dan langsung mengirim pesan pertama.
2. Room chat boleh dibuka walaupun statusnya masih `pending`.
3. Chat belum dianggap aktif hanya karena user sudah mengirim pesan.
4. Chat baru dianggap aktif saat `talent` mengirim balasan pertama.
5. Balasan pertama dari `talent` akan mengubah room menjadi `confirmed` dan memulai durasi chat.
6. Setelah itu chat berjalan normal secara realtime.

## Istilah Penting

- `room_id`: id chat room
- `pending`: room sudah dibuat, user boleh chat, tetapi talent belum membalas
- `confirmed`: talent sudah membalas pertama kali, chat aktif
- `starts_at`: waktu chat resmi dimulai
- `ends_at`: waktu chat resmi selesai

## Flow Dari Sisi User

Tujuan dari sisi user:
- memilih talent
- membuat chat room
- masuk ke halaman chat
- mengirim pesan pertama
- menunggu balasan talent
- lanjut chat realtime

### Urutan Implementasi User

1. User membuka detail talent.
2. User menekan tombol `Chat`.
3. Frontend memanggil endpoint pembuatan request chat.
4. Backend mengembalikan data room.
5. Frontend membuka halaman chat berdasarkan `room_id`.
6. Frontend mengambil histori pesan.
7. Frontend membuka koneksi socket.
8. Frontend join ke room tersebut.
9. User mengirim pesan pertama.
10. Frontend menampilkan status `menunggu balasan talent` sampai talent membalas.

### Endpoint Yang Dipanggil User

#### 1. Buat chat room

`POST /api/v1/meet-requests`

Contoh body:

```json
{
  "talent_account_id": "TALENT_ACCOUNT_ID",
  "channel_type": "chat",
  "duration_minutes": 60
}
```

Yang frontend butuhkan dari response:
- `room_id`
- `status`
- `requested_duration_minutes`
- data ringkas talent

#### 2. Ambil histori pesan

`GET /api/v1/chat/{roomId}/messages`

Dipanggil saat halaman chat dibuka.

#### 3. Ambil daftar chat session user

`GET /api/v1/chat-sessions`

Dipakai jika frontend punya halaman daftar chat milik user.

#### 4. Kirim pesan lewat REST

`POST /api/v1/chat/{roomId}/messages`

Contoh body:

```json
{
  "message": "Halo kak, saya mau tanya detail servicenya"
}
```

Catatan:
- untuk pengalaman realtime, lebih baik kirim lewat socket
- endpoint REST tetap berguna sebagai fallback

### State UI Yang Disarankan Untuk User

Saat `status = pending`:
- tampilkan chat room seperti biasa
- izinkan user mengirim pesan
- tampilkan label seperti `Menunggu balasan talent`
- jangan tampilkan chat sebagai sesi aktif penuh

Saat `status = confirmed`:
- tampilkan label seperti `Chat aktif`
- tampilkan timer jika dibutuhkan UI
- gunakan `starts_at` dan `ends_at` untuk countdown

## Flow Dari Sisi Talent

Tujuan dari sisi talent:
- melihat ada chat masuk
- membuka room walaupun masih `pending`
- membaca pesan awal dari user
- mengirim balasan pertama
- mengaktifkan chat secara resmi
- melanjutkan chat realtime

### Urutan Implementasi Talent

1. Talent membuka halaman daftar chat.
2. Frontend memanggil daftar chat session.
3. Talent memilih salah satu room.
4. Frontend mengambil histori pesan room tersebut.
5. Frontend membuka koneksi socket.
6. Frontend join ke room.
7. Talent membaca pesan awal dari user.
8. Talent mengirim balasan pertama.
9. Balasan pertama ini otomatis mengaktifkan chat.
10. Setelah itu frontend menampilkan room sebagai chat aktif.

### Endpoint Yang Dipanggil Talent

#### 1. Ambil daftar chat session

`GET /api/v1/chat-sessions`

Endpoint ini dipakai untuk halaman inbox atau daftar percakapan talent.

Yang frontend butuhkan dari response:
- `room_id`
- `status`
- `last_message_at`
- data ringkas user
- `permissions.can_chat` bila tersedia di response room

#### 2. Ambil histori pesan

`GET /api/v1/chat/{roomId}/messages`

Dipanggil saat talent membuka detail room.

#### 3. Kirim pesan pertama atau balasan berikutnya

`POST /api/v1/chat/{roomId}/messages`

Contoh body:

```json
{
  "message": "Halo, silakan disampaikan pertanyaannya"
}
```

Catatan penting:
- jika room masih `pending`, balasan pertama dari talent akan mengubah status room menjadi `confirmed`
- pada saat itu backend juga akan mengisi `starts_at` dan `ends_at`

### State UI Yang Disarankan Untuk Talent

Saat `status = pending`:
- tampilkan bahwa ada chat masuk yang belum diaktifkan
- talent tetap boleh membuka room
- talent tetap boleh membalas
- saat tombol kirim pertama ditekan, frontend harus siap menerima perubahan room menjadi aktif

Saat `status = confirmed`:
- tampilkan chat sebagai sesi aktif
- tampilkan timer jika diperlukan
- perbarui UI berdasarkan data room terbaru

## Realtime Socket Flow

Agar pesan muncul realtime, frontend tidak cukup hanya memakai REST API. Frontend juga harus membuka koneksi socket ke namespace chat.

Namespace:

`/chat`

Event utama:
- `join_room`
- `send_message`
- `chat_message`
- `room_joined`
- `chat_error`

### Urutan Realtime Yang Disarankan

1. Login dan dapatkan `access_token`.
2. Saat halaman chat dibuka, connect ke socket `/chat` menggunakan token.
3. Setelah connect, emit `join_room` dengan `room_id`.
4. Dengarkan event `chat_message`.
5. Saat user atau talent mengirim pesan, emit `send_message`.
6. Saat event `chat_message` diterima, append pesan ke list chat.

### Contoh Payload Socket

Contoh join room:

```json
{
  "room_id": "ROOM_ID"
}
```

Contoh kirim pesan:

```json
{
  "room_id": "ROOM_ID",
  "content": "Halo"
}
```

## Kontrak Event Socket.IO Chat

Bagian ini adalah kontrak yang disarankan agar backend dan frontend memakai nama event serta payload yang sama.

### Namespace

- `/chat`

### Handshake Auth

Client mengirim access token saat connect.

Contoh auth handshake:

```json
{
  "token": "ACCESS_TOKEN"
}
```

Jika backend lebih nyaman membaca header, boleh juga menerima:

```http
Authorization: Bearer <access_token>
```

### Event Dari Client Ke Server

#### 1. `join_room`

Dipakai saat user atau talent membuka detail room chat.

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
  "event": "room_joined",
  "data": {
    "room_id": "ROOM_ID"
  }
}
```

#### 2. `send_message`

Dipakai untuk kirim pesan realtime dari room yang sedang dibuka.

Payload minimum:

```json
{
  "room_id": "ROOM_ID",
  "content": "Halo kak, saya mau tanya",
  "message_type": "text"
}
```

Field yang disarankan:

- `room_id`: room tujuan
- `content`: isi pesan chat
- `message_type`: default `text`
- `client_message_id`: opsional untuk optimistic UI frontend
- pada mode socket-only, backend harus mengembalikan ack atau mengirim `chat_message` balik ke sender agar bubble optimistic bisa dikonfirmasi

Contoh payload lengkap:

```json
{
  "room_id": "ROOM_ID",
  "content": "Halo kak, saya mau tanya",
  "message_type": "text",
  "client_message_id": "local-1714210000"
}
```

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

Catatan integrasi backend:

- frontend dapat langsung menampilkan bubble optimistic memakai `client_message_id`
- backend harus mengirim ack `send_message` atau echo `chat_message` ke sender dengan `client_message_id` yang sama
- jika backend hanya broadcast ke penerima dan tidak ke sender, frontend akan menganggap kirim gagal setelah timeout

### Event Dari Server Ke Client

#### 1. `room_joined`

Dikirim ke socket pengirim sebagai konfirmasi bahwa room subscription berhasil.

Payload:

```json
{
  "room_id": "ROOM_ID",
  "joined_at": "2026-04-27T10:00:00.000Z"
}
```

#### 2. `chat_message`

Dikirim ke semua participant room setelah pesan berhasil dipersist.

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

Jika backend ingin membantu sinkronisasi room card, payload boleh ditambah:

- `room_status`
- `last_message_preview`
- `counterpart_account_id`
- `client_message_id`

Untuk mode socket-only, `client_message_id` sebaiknya dianggap wajib pada echo ke sender.

#### 3. `chat_error`

Dikirim saat join room atau kirim pesan gagal.

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

### Aturan Emit Backend

1. backend harus menyimpan pesan lebih dulu sebelum emit `chat_message`
2. backend harus emit `chat_message` ke room Socket.IO yang sama dengan `room_id`
3. backend sebaiknya tetap kirim event ke pengirim agar optimistic UI frontend bisa dikonfirmasi
4. jika balasan pertama talent mengubah status room, backend tetap emit `chat_message` dan juga update status room pada notification channel

### Aturan Konsumsi Frontend

1. frontend selalu fetch histori awal dengan REST sebelum mengandalkan socket
2. frontend append event `chat_message` jika `room_id` cocok dengan room aktif
3. frontend harus deduplicate berdasarkan `id` atau `client_message_id`
4. jika socket gagal atau event tidak datang, frontend boleh fallback ke polling histori seperti implementasi saat ini

Catatan implementasi frontend:
- selalu fetch histori lebih dulu saat membuka room
- socket dipakai untuk update realtime setelah histori awal dimuat
- jangan mengandalkan socket saja untuk initial message list

## Perbedaan Flow User dan Talent

### User

- membuat room lebih dulu
- bisa langsung kirim pesan
- melihat state menunggu balasan
- chat belum aktif penuh sampai talent membalas

### Talent

- tidak membuat room dari nol
- menerima room yang sudah dibuat user
- membuka room yang masih `pending`
- balasan pertama dari talent menjadi trigger aktivasi sesi

## Urutan Singkat Yang Bisa Langsung Diberikan Ke Frontend

### User

1. `POST /api/v1/meet-requests`
2. buka halaman chat pakai `room_id`
3. `GET /api/v1/chat/{roomId}/messages`
4. connect socket ke `/chat`
5. emit `join_room`
6. kirim pesan pertama
7. tunggu event `chat_message` dari talent

### Talent

1. `GET /api/v1/chat-sessions`
2. pilih room
3. `GET /api/v1/chat/{roomId}/messages`
4. connect socket ke `/chat`
5. emit `join_room`
6. kirim balasan pertama
7. room otomatis menjadi aktif

## Saran Implementasi UI

### Untuk Halaman User

- tombol `Mulai chat`
- halaman room chat
- label status `Menunggu balasan talent` saat masih `pending`
- ubah label menjadi `Chat aktif` saat room sudah `confirmed`

### Untuk Halaman Talent

- daftar incoming chat
- badge unread jika diperlukan
- indikator room `pending`
- setelah balasan pertama sukses, ubah tampilan menjadi sesi aktif

## Checklist Frontend

- simpan `access_token`
- attach token ke semua request REST
- attach token saat connect socket
- fetch chat list dari `GET /api/v1/chat-sessions`
- fetch histori dari `GET /api/v1/chat/{roomId}/messages`
- emit `join_room` setiap kali membuka detail room
- dengarkan event `chat_message`
- handle state `pending` dan `confirmed`
- update timer memakai `starts_at` dan `ends_at` bila room sudah aktif

## Kesimpulan Praktis

Kalau dijelaskan paling sederhana:

- dari sisi user, flow-nya adalah: buat room, masuk room, kirim pesan, tunggu talent balas
- dari sisi talent, flow-nya adalah: buka daftar chat, masuk room, baca pesan user, balas pertama kali, lalu chat menjadi aktif

Artinya frontend tidak perlu menunggu proses confirm terpisah untuk chat. Untuk chat, balasan pertama dari talent adalah momen aktivasi session.