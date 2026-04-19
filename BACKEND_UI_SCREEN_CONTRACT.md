# Backend UI Screen Contract

Dokumen ini dibuat sebagai acuan tetap antara frontend Flutter dan backend.

Tujuan dokumen ini:
- Menjelaskan komponen yang dianggap wajib dan sudah fixed di screen saat ini.
- Memudahkan pembuatan API backend berdasarkan komponen nyata yang sudah ada di frontend.
- Menghindari perubahan struktur UI yang tidak perlu saat backend mulai diintegrasikan.

Dokumen terkait yang juga wajib dibaca:
- `FRONTEND_UI_DEVELOPMENT_GUARDRAILS.md`
- `copilot-instructions.md`

## Aturan Utama

Semua screen yang tercantum di dokumen ini dianggap sudah fix dari sisi struktur UI.

Artinya:
- Backend harus mengikuti kebutuhan komponen yang sudah ada di frontend.
- Perubahan frontend hanya dilakukan untuk:
  - binding data dari backend ke komponen yang sudah ada,
  - perbaikan bug,
  - penambahan fitur yang benar-benar dibutuhkan,
  - perubahan yang memang diminta langsung oleh produk/desain.
- Jangan ubah bentuk layout utama hanya karena format data backend belum siap.

## Komponen Wajib di Semua Page

Komponen ini tidak berarti semua page memiliki bentuk visual yang sama, tetapi semua page yang terhubung ke backend harus punya dukungan data dan state berikut:

1. Session context
   - `user_id` atau `talent_id`
   - `role` = `user` atau `talent`
   - token/session aktif

2. Request state
   - loading state
   - success state
   - empty state
   - error state

3. Action state
   - disabled state saat submit/request sedang berjalan
   - feedback sukses atau gagal
   - validasi field wajib

4. Media support
   - image URL untuk avatar, portfolio, gallery, document preview
   - fallback bila media kosong atau gagal dimuat

5. Status support
   - badge/label status untuk data seperti `active`, `archived`, `pending`, `accepted`, `rejected`, `completed`

6. Formatting
   - timestamp/date
   - amount/coin/currency
   - number formatting untuk count, rating, total, history

7. Navigation context
   - route target harus tetap mengikuti flow yang sudah ada di frontend
   - badge count pada menu atau notification harus berasal dari backend jika data memang dinamis

## Route Aktif Saat Ini

### Auth dan shared entry
- `/login`
- `/register`
- `/register-talent`

### User routes
- `/home`
- `/profile`
- `/chat`
- `/messages`
- `/settings`
- `/favorites`
- `/topup`
- `/transactions`
- `/user-profile`

### Talent routes
- `/talent-home`
- `/talent-profile`
- `/talent-messages`
- `/talent-settings`

## Kontrak Screen per Role

## 1. Login

Route: `/login`

Tujuan:
- Entry point untuk user dan talent.

Komponen fixed:
- toggle login type: `user` atau `talent`
- email input
- password input
- remember me
- tombol login
- navigasi ke register user atau register talent

Backend minimal:
- `POST /login`
- request:
  - `email`
  - `password`
  - `type`
- response:
  - token/session
  - role
  - profile summary
  - route target default

## 2. Register User

Route: `/register`

Tujuan:
- Membuat akun user biasa.

Komponen fixed:
- account credentials
  - username
  - password
  - confirm password
- personal information
  - first name
  - last name
  - call name
  - gender
  - date of birth
  - email
  - phone
- address information
  - address
  - country
  - city
  - postcode
- agreement checkbox
- tombol create account

Implikasi backend:
- register user tidak memakai field talent seperti stage name, specialties, portfolio, identity verification.
- backend harus memisahkan payload register user dari register talent.

Backend minimal:
- `POST /register`
- request fields:
  - `username`
  - `password`
  - `confirm_password`
  - `first_name`
  - `last_name`
  - `call_name`
  - `gender`
  - `date_of_birth`
  - `email`
  - `phone`
  - `address`
  - `country`
  - `city`
  - `postcode`
  - `agree_terms`

## 3. Register Talent

Route: `/register-talent`

Tujuan:
- Onboarding khusus talent.

Komponen fixed:
- account credentials
  - username
  - password
  - confirm password
- talent profile
  - stage name
  - bio/description
  - referral agency
  - years of experience
- languages
  - multi select
- specialties
  - multi select
- identity and media
  - upload identity card
  - upload selfie verification
  - upload portfolio photos
- tombol create talent account

Implikasi backend:
- register talent harus berbeda dari register user.
- backend perlu menerima upload/media + data profil talent.
- status verifikasi talent sebaiknya dipisahkan, misalnya `draft`, `submitted`, `verified`, `rejected`.

Backend minimal:
- `POST /talent/register`
- request fields:
  - `username`
  - `password`
  - `confirm_password`
  - `stage_name`
  - `bio`
  - `referral_agency`
  - `years_of_experience`
  - `languages[]`
  - `specialties[]`
  - `identity_document`
  - `selfie_verification`
  - `portfolio_photos[]`

## 4. User Home

Route: `/home`

Tujuan:
- Discovery page untuk mencari talent.

Komponen fixed:
- header title
- coin balance preview
- notification bell
- search by name or city
- city search/dropdown
- filter chips
  - `People`
  - `Online`
  - `New`
  - `VIP`
- section list host
  - `Top Hosts`
  - `New Hosts`
- host card

Backend minimal:
- `GET /hosts`
- query support:
  - `query`
  - `city`
  - `filter`
  - `online`
  - `vip`
  - `sort`
- notification count atau ringkasan user
- wallet summary untuk header

Data host minimal:
- `id`
- `name`
- `age`
- `city`
- `country_code`
- `image_url`
- `is_online`
- `badges[]`
- `description`
- `price_per_minute`

## 5. User Talent Detail

Route: `/profile`

Tujuan:
- Halaman detail talent saat dilihat oleh user.

Komponen yang harus dipertahankan backend-nya:
- hero/profile summary
- rating dan reviews
- about/bio
- languages
- specialties
- portfolio/media
- pricing/service options
- action ke chat/call/video/schedule
- review list bila ada

Backend minimal:
- `GET /talents/:id`
- `GET /talents/:id/reviews`
- `GET /talents/:id/portfolio`
- `POST /meet-requests`

## 6. User Activity

Route: `/messages`

Tujuan:
- Activity user untuk message, phone, dan video.

Komponen fixed:
- tabs: `All`, `Active`, `Archived`
- search activity
- activity item type:
  - message
  - phone
  - video
- active/archived status
- schedule-based message window untuk chat event

Aturan backend penting:
- message activity untuk schedule harus mengikuti window H-3 sampai H+1 dari event accepted.
- archived item tidak boleh dianggap active.

Backend minimal:
- `GET /user/activities`
- `GET /meet-requests`
- `GET /chat-sessions`
- `GET /call-sessions`

## 7. User Chat

Route: `/chat`

Tujuan:
- 1-on-1 chat user dengan talent.

Komponen fixed:
- chat header
- message list
- text composer
- send action

Backend minimal:
- `GET /chat/:sessionId/messages`
- `POST /chat/:sessionId/messages`
- optional realtime:
  - websocket
  - socket
  - SSE

## 8. User Favorites

Route: `/favorites`

Tujuan:
- Menyimpan talent favorit user.

Komponen fixed:
- list favorite talent
- empty state
- remove/unfavorite action
- tap ke detail profile

Backend minimal:
- `GET /favorites`
- `POST /favorites/:talentId`
- `DELETE /favorites/:talentId`

## 9. User Settings

Route: `/settings`

Tujuan:
- Pengaturan akun user.

Komponen fixed:
- account settings
- privacy/settings toggle
- notification preferences
- logout

Backend minimal:
- `GET /me/settings`
- `PATCH /me/settings`
- `POST /logout`

## 10. User Profile

Route: `/user-profile`

Tujuan:
- Profil milik user sendiri.

Komponen fixed:
- identity/profile summary
- menu list
- ready to review talent
- reviews about talent written by user flow
- my schedule section
- schedule status badge

Backend minimal:
- `GET /me`
- `PATCH /me`
- `GET /me/review-pending`
- `POST /reviews/talent`
- `GET /me/schedules`

## 11. Top Up

Route: `/topup`

Tujuan:
- Membeli coin.

Komponen fixed:
- package selection
- payment method selection
- success state

Backend minimal:
- `GET /topup/packages`
- `GET /payment-methods`
- `POST /topup`

Data minimal:
- `package_id`
- `coins`
- `price`
- `bonus`
- `payment_method`
- `status`

## 12. Transaction History

Route: `/transactions`

Tujuan:
- Riwayat top up dan spending user.

Komponen fixed:
- summary total top up
- summary total spent
- filter chips
- list transaksi
- label method/payment jika relevan

Backend minimal:
- `GET /transactions`
- filter support:
  - `all`
  - `topup`
  - `spending`

## 13. Talent Home

Route: `/talent-home`

Tujuan:
- Dashboard utama talent.

Komponen fixed:
- online/offline state
- analytics summary
- weekly earnings
- requests/schedule section
- accept/reject request action
- insight/performance section

Backend minimal:
- `GET /talent/home`
- `GET /talent/analytics`
- `GET /talent/meet-requests`
- `PATCH /talent/meet-requests/:id`

Status penting:
- `pending`
- `accepted`
- `rejected`
- `completed`
- `cancelled`

## 14. Talent Activity

Route: `/talent-messages`

Tujuan:
- Activity talent untuk message, phone, video, dan message schedule.

Komponen fixed:
- tabs: `All`, `Active`, `Archived`
- search
- activity card
- message schedule dari accepted meet
- chat availability mengikuti window event yang sama seperti user

Backend minimal:
- `GET /talent/activities`
- `GET /talent/meet-requests`
- `GET /chat-sessions`
- `GET /call-sessions`

Aturan penting:
- jika ada accepted schedule antara talent dan user, activity message schedule harus tersedia untuk kedua sisi.
- status active/archived harus konsisten antara frontend user dan talent.

## 15. Talent Chat

File screen aktif: `lib/screens/talent/talent_chat_screen.dart`

Tujuan:
- Chat detail talent dengan user.

Komponen fixed:
- header user info
- earning label
- message list
- text composer

Backend minimal:
- `GET /talent/chat/:sessionId/messages`
- `POST /talent/chat/:sessionId/messages`

## 16. Talent Profile

Route: `/talent-profile`

Tujuan:
- Halaman profile milik talent sendiri.

Komponen fixed:
- profile card
- avatar edit
- stats grid
- portfolio and preview
- available balance
- withdraw earnings
- ready to review users
- reviews received
- schedule and availability
- payment history
- settings shortcut
- logout

Backend minimal:
- `GET /talent/me`
- `PATCH /talent/me`
- `POST /talent/profile/avatar`
- `POST /talent/profile/portfolio`
- `GET /talent/review-pending`
- `POST /reviews/user`
- `GET /talent/reviews`
- `GET /talent/schedules`
- `GET /talent/payments/history`
- `POST /talent/withdraw`

Withdraw contract minimal:
- request:
  - `coin_amount`
  - `withdraw_method`
  - `account_name`
  - `account_number`
- response:
  - `withdraw_id`
  - `status`
  - `cash_amount`
  - `coin_amount`
  - `created_at`

## 17. Talent Settings

Route: `/talent-settings`

Tujuan:
- Pengaturan akun talent.

Komponen fixed:
- account preferences
- privacy settings
- notification settings
- payout related setting jika nanti diperlukan
- logout

Backend minimal:
- `GET /talent/settings`
- `PATCH /talent/settings`
- `POST /logout`

## Shared UI Contract

### Review Composer

File: `lib/screens/shared/review_composer_sheet.dart`

Dipakai untuk:
- user review talent
- talent review user

Komponen fixed:
- star rating
- review text
- optional photo attachment
- source upload dari gallery atau camera
- confirm action

Backend minimal:
- `POST /reviews`
- request:
  - `target_type`
  - `target_id`
  - `rating`
  - `comment`
  - `photo`
  - `session_reference`

### Activity Session Screen

File: `lib/screens/shared/activity_session_screen.dart`

Dipakai untuk:
- phone session
- video session

Komponen fixed:
- peer identity
- mode: phone atau video
- mute/speaker/camera state
- session label

Backend minimal:
- `GET /sessions/:id`
- `POST /sessions/:id/start`
- `POST /sessions/:id/end`
- `POST /sessions/:id/control`

## Prinsip Integrasi Backend

Saat Anda memberi instruksi backend, gunakan pola berikut:

1. Sebutkan screen target lebih dulu
   - contoh: `Register Talent`, `User Home`, `Talent Profile`

2. Sebutkan komponen di screen itu
   - contoh: `languages`, `specialties`, `identity upload`, `withdraw form`

3. Backend mengikuti komponen yang benar-benar muncul di UI
   - jangan menambah field yang belum dipakai UI kecuali memang dibutuhkan dan disepakati

4. Jika ada perbedaan role, pisahkan kontraknya
   - contoh: register user dan register talent tidak boleh memakai payload yang sama penuh

5. Untuk screen yang sudah fixed, fokus backend hanya pada:
   - source data
   - action endpoint
   - validation
   - state update frontend

## Contoh Instruksi Backend yang Disarankan

Contoh 1:

`Buat backend untuk Register Talent sesuai screen saat ini. Field wajib: username, password, confirm password, stage name, bio, referral agency, years of experience, languages, specialties, upload identity card, selfie verification, portfolio photos.`

Contoh 2:

`Hubungkan Talent Profile untuk bagian withdraw earnings tanpa mengubah layout. Backend harus menerima coin_amount, withdraw_method, account_name, account_number, lalu mengembalikan status payout dan memperbarui payment history.`

Contoh 3:

`Hubungkan User Activity dan Talent Activity agar message schedule aktif untuk kedua sisi hanya pada window H-3 sampai H+1 dari accepted meet request.`

## Catatan Penutup

Dokumen ini adalah kontrak kerja antara UI frontend dan backend untuk kondisi screen saat ini.

Jika ada fitur baru, update dokumen ini terlebih dahulu atau bersamaan dengan perubahan screen agar backend dan frontend tetap sinkron.