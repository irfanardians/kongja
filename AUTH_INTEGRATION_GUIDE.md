# Auth Integration Guide

Dokumen ini menjelaskan cara integrasi auth backend Kongja dari sisi frontend.

Panduan ini fokus pada:

- login
- session bootstrap
- `auth/me`
- auto refresh token
- bootstrap notifikasi chat setelah login
- forgot password
- reset password

Base path default backend:

- `/api/v1`

## Endpoint Ringkas

- `POST /api/v1/login`
- `GET /api/v1/auth/me`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`
- `POST /api/v1/auth/request-password-reset`
- `POST /api/v1/auth/reset-password`

## 1. Login

Frontend mengirim satu field `identifier` dan backend akan mendeteksi account berdasarkan email, username, atau phone.

Contoh request:

```json
{
  "identifier": "jane@example.com",
  "password": "Password123!",
  "client_app": "mobile_user"
}
```

Contoh request dengan phone:

```json
{
  "identifier": "+6281319090066",
  "password": "Password123!",
  "client_app": "mobile_talent"
}
```

Contoh response sukses:

```json
{
  "success": true,
  "data": {
    "account_id": "acc_123",
    "role": "user",
    "level": "basic",
    "client_app": "mobile_user",
    "allowed_surfaces": [
      "mobile_user"
    ],
    "permissions": [
      "view_profile",
      "update_profile"
    ],
    "access_token": "access-token-value",
    "refresh_token": "refresh-token-value",
    "route_target_default": "/home",
    "profile_summary": {
      "display_name": "Jane",
      "avatar_url": null
    }
  }
}
```

Contoh error yang perlu ditangani frontend:

```json
{
  "statusCode": 401,
  "message": "Invalid login credentials",
  "error": "Unauthorized"
}
```

```json
{
  "statusCode": 401,
  "message": "Email verification is required before login",
  "error": "Unauthorized"
}
```

Instruksi frontend setelah login sukses:

1. simpan `access_token`
2. simpan `refresh_token`
3. simpan `account_id`, `role`, `level`, `permissions`, dan `profile_summary`
4. arahkan user ke `route_target_default` atau route yang dipetakan dari role di frontend

Untuk flow chat notification, ada langkah lanjutan yang disarankan setelah login sukses:

1. bootstrap session dengan `GET /api/v1/auth/me` bila app perlu context lengkap
2. connect socket notifikasi atau chat menggunakan `access_token`
3. ambil FCM device token di app
4. kirim token itu ke `POST /api/v1/devices/token`
5. panggil `GET /api/v1/notifications/unread-summary` untuk badge awal chat

Detail payload device token dan unread summary ada di `NOTIFICATIONS_INTEGRATION_GUIDE.md`.

## 2. Session Bootstrap Dengan auth/me

Endpoint:

- `GET /api/v1/auth/me`

Header:

```http
Authorization: Bearer <access_token>
```

Contoh response sukses:

```json
{
  "success": true,
  "data": {
    "account_id": "acc_123",
    "role": "user",
    "level": "basic",
    "client_app": "mobile_user",
    "allowed_surfaces": [
      "mobile_user"
    ],
    "permissions": [
      "view_profile",
      "update_profile"
    ],
    "route_target_default": "/home",
    "profile_summary": {
      "display_name": "Jane",
      "avatar_url": "http://localhost:3000/uploads/users/avatar/jane.jpg"
    }
  }
}
```

Kapan frontend sebaiknya memanggil endpoint ini:

1. saat app dibuka dan token lokal masih ada
2. setelah login sukses jika butuh sinkronisasi state tambahan
3. setelah refresh token sukses jika frontend ingin me-refresh context session
4. sebelum bootstrap socket notification jika frontend ingin memastikan role dan account context terbaru

Kapan tidak perlu:

- tidak perlu dipanggil di setiap perpindahan page
- tidak perlu dipanggil di setiap klik atau activity kecil

## 3. Auto Refresh Token

TTL default backend saat ini:

- `access_token`: `15m`
- `refresh_token`: `7d`

Endpoint:

- `POST /api/v1/auth/refresh`

Contoh request:

```json
{
  "refresh_token": "refresh-token-value"
}
```

Contoh response sukses:

```json
{
  "success": true,
  "data": {
    "account_id": "acc_123",
    "role": "user",
    "level": "basic",
    "client_app": "mobile_user",
    "allowed_surfaces": [
      "mobile_user"
    ],
    "permissions": [
      "view_profile",
      "update_profile"
    ],
    "access_token": "new-access-token-value",
    "refresh_token": "new-refresh-token-value",
    "route_target_default": "/home",
    "profile_summary": {
      "display_name": "Jane",
      "avatar_url": null
    }
  }
}
```

Contoh error:

```json
{
  "statusCode": 401,
  "message": "Refresh token has expired",
  "error": "Unauthorized"
}
```

```json
{
  "statusCode": 401,
  "message": "Refresh token is invalid",
  "error": "Unauthorized"
}
```

Instruksi implementasi frontend:

1. kirim request biasa dengan `access_token`
2. jika dapat `401`, cek apakah ini kasus token expired atau session tidak valid
3. jika token access expired, panggil `POST /api/v1/auth/refresh`
4. jika refresh sukses, ganti token lama dengan token baru
5. ulangi request sebelumnya satu kali
6. jika refresh gagal, hapus semua session lokal dan arahkan ke login

Catatan:

- endpoint refresh saat ini stateless
- backend belum melakukan revoke refresh token per device
- karena itu frontend wajib mengganti `refresh_token` lama dengan yang baru setiap kali refresh berhasil

## 3.1 Logout

Endpoint:

- `POST /api/v1/auth/logout`

Contoh request:

```json
{
  "refresh_token": "refresh-token-value",
  "device_token": "fcm-device-token-value",
  "device_id": "emulator-5554"
}
```

Contoh response sukses:

```json
{
  "success": true,
  "message": "Logout successful",
  "data": {
    "account_id": "acc_123",
    "revoked_device_tokens": 1
  }
}
```

Catatan frontend:

- `device_token` dan `device_id` bersifat opsional tetapi disarankan
- jika dikirim, backend akan menonaktifkan token device tersebut untuk push notification
- setelah logout sukses, frontend tetap harus memutus socket dan menghapus session lokal
- untuk flow chat, kirim field ini agar device lama tidak terus menerima push unread room atau chat message

## 4. Forgot Password

Endpoint:

- `POST /api/v1/auth/request-password-reset`

Contoh request:

```json
{
  "email": "jane@example.com"
}
```

Contoh response sukses:

```json
{
  "success": true,
  "message": "If the email is registered, a password reset link has been sent.",
  "data": {
    "email": "jane@example.com",
    "expires_at": "2026-04-20T10:00:00.000Z"
  }
}
```

Catatan frontend:

- selalu tampilkan pesan netral sukses
- jangan membedakan UI antara email terdaftar dan email tidak terdaftar
- ini penting untuk mengurangi email enumeration

## 5. Reset Password

Endpoint:

- `POST /api/v1/auth/reset-password`

Contoh request:

```json
{
  "token": "password-reset-token-from-email",
  "password": "NewPassword123!",
  "confirm_password": "NewPassword123!"
}
```

Contoh response sukses:

```json
{
  "success": true,
  "message": "Password has been reset successfully. You can now login.",
  "data": {
    "account_id": "acc_123",
    "email": "jane@example.com"
  }
}
```

Contoh error:

```json
{
  "statusCode": 400,
  "message": "Password confirmation does not match",
  "error": "Bad Request"
}
```

```json
{
  "statusCode": 400,
  "message": "Password reset token is invalid",
  "error": "Bad Request"
}
```

```json
{
  "statusCode": 400,
  "message": "Password reset token has expired",
  "error": "Bad Request"
}
```

Instruksi implementasi frontend:

1. buka screen forgot password
2. kirim email ke endpoint request password reset
3. user menerima email dari SMTP backend
4. user membuka link reset atau memasukkan token ke form reset password
5. frontend kirim `token`, `password`, dan `confirm_password`
6. jika sukses, arahkan user ke login
7. jangan auto login setelah reset password kecuali memang ada requirement produk yang eksplisit

## 6. Rekomendasi Penyimpanan Token Di Frontend

Minimal data yang disimpan:

- `access_token`
- `refresh_token`
- `account_id`
- `role`
- `level`
- `permissions[]`
- `profile_summary`

Prinsip implementasi:

- simpan token di storage yang aman sesuai platform
- jangan hardcode role dari toggle UI login
- selalu percaya hasil role final dari backend
- saat logout, hapus seluruh session lokal
- jika frontend juga menyimpan `device_id` atau `device_token`, perlakukan itu sebagai metadata session device dan hapus bila user logout total dari device ini

## 6.1 Kaitannya Dengan Notifikasi Chat

Auth flow dan notification flow saling terkait untuk chat realtime:

1. login menghasilkan `access_token`
2. `access_token` dipakai untuk `auth/me`, socket `/chat`, socket `/notifications`, dan unread summary
3. device token FCM harus diregistrasikan setelah login agar push chat bisa dikirim saat app background
4. saat refresh token sukses, frontend tidak perlu registrasi ulang device token kecuali token FCM berubah
5. saat logout, frontend sebaiknya ikut mengirim `device_token` atau `device_id`

Rujukan implementasi detail ada di `NOTIFICATIONS_INTEGRATION_GUIDE.md`.

## 7. Rekomendasi Error Handling Di Frontend

Pemetaan sederhana yang disarankan:

- `400`: validasi input salah, tampilkan pesan dari backend
- `401`: token tidak valid, token expired, login gagal, atau session tidak aktif
- `404`: resource atau account tertentu tidak ditemukan
- `500`: tampilkan fallback error umum

Untuk auth flow, prioritas UI handling biasanya seperti ini:

1. jika login gagal, tampilkan pesan error login
2. jika request biasa kena `401`, coba refresh token sekali
3. jika refresh gagal, paksa logout dan buka login
4. jika reset password gagal karena token expired, minta user ulangi forgot password