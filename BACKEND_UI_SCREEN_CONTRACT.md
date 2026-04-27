# Backend UI Screen Contract

Dokumen ini dibuat sebagai acuan tetap antara frontend Flutter dan backend.

Tujuan dokumen ini:
- Menjelaskan komponen yang dianggap wajib dan sudah fixed di screen saat ini.
- Memudahkan pembuatan API backend berdasarkan komponen nyata yang sudah ada di frontend.
- Menghindari perubahan struktur UI yang tidak perlu saat backend mulai diintegrasikan.
- Menyiapkan fondasi role system yang lebih aman agar backend dan Copilot tidak mengasumsikan hanya ada `user` dan `talent`.

Dokumen terkait yang juga wajib dibaca:
- `FRONTEND_UI_DEVELOPMENT_GUARDRAILS.md`
- `copilot-instructions.md`
- `FINANCIAL_LEDGER_ARCHITECTURE.md`

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
- Backend harus disiapkan dari awal untuk multi-role access, walaupun UI yang aktif saat ini masih berfokus pada `user` dan `talent`.

## Role System Yang Disarankan

Ya, sangat memungkinkan dan justru disarankan menggunakan kombinasi `RBAC + Level`.

Gunakan pembagian seperti ini:

1. RBAC untuk identitas aktor utama
   - `user`
   - `talent`
   - `admin`
   - `agency`

Catatan struktur aktor:
- `admin` adalah aktor internal yang nantinya bisa bekerja lintas segment `user` dan `talent`
- `agency` adalah aktor untuk platform terpisah, tetapi tetap berada dalam satu domain autentikasi dan satu backend yang sama

2. Level untuk tier atau paket role tertentu
   - khusus saat ini dipersiapkan untuk:
     - `user`
     - `talent`
   - level yang sudah perlu disiapkan dari awal:
     - `basic`
     - `premium`

3. Permission untuk aksi granular
   - contoh:
     - `view_hosts`
     - `create_meet_request`
     - `review_talent`
     - `withdraw_earnings`
     - `manage_talent_verification`
     - `manage_agency_members`
     - `view_admin_dashboard`

## Kenapa RBAC + Level Lebih Tepat

Gunakan pemisahan tanggung jawab berikut:

- `role` menjawab: siapa aktornya?
- `level` menjawab: tier apa yang dia miliki?
- `permission` menjawab: apa saja yang boleh dilakukan?

Contoh:
- `role = user`, `level = basic`
- `role = user`, `level = premium`
- `role = talent`, `level = basic`
- `role = talent`, `level = premium`
- `role = admin`, tanpa level dulu
- `role = agency`, tanpa level dulu

Dengan pendekatan ini:
- backend tidak perlu dirombak saat premium plan mulai aktif,
- Copilot tidak akan terus mengasumsikan hanya ada dua aktor,
- screen frontend saat ini tetap aman karena belum dipaksa menampilkan UI admin atau agency.

## Arsitektur Client dan Auth Yang Disarankan

Untuk kondisi yang Anda jelaskan, struktur yang disarankan adalah:

1. Satu backend utama
  - semua domain data tetap berada di backend yang sama

2. Satu domain autentikasi
  - login, token, session, dan identity tetap dikelola secara terpusat

3. Banyak client atau platform
  - Flutter app segment `user`
  - Flutter app segment `talent`
  - platform `admin`
  - platform `agency` terpisah

Artinya:
- `admin` bisa mengakses dua segment tanpa dipaksa menjadi `user` atau `talent`
- `agency` tidak harus tampil di aplikasi Flutter yang sekarang
- `agency` tetap boleh memakai auth service yang sama

Field tambahan yang disarankan di lapisan auth/session:
- `client_app`
- `login_surface`
- `allowed_surfaces[]`

## Prinsip Implementasi Role

Aturan implementasi yang disarankan:

1. Setiap account wajib punya `role`
2. `level` boleh nullable untuk role yang belum memerlukannya
3. `permissions[]` sebaiknya dihitung atau diturunkan dari role dan kebijakan backend
4. Jangan hardcode logika akses hanya berdasarkan route frontend
5. Jangan gabungkan `role` dan `level` menjadi satu string seperti `premium_user`
6. Auth boleh tersentralisasi, tetapi data informasi domain harus dipisah per role

Format yang disarankan:
- `role = user | talent | admin | agency`
- `level = basic | premium | null`

Format tambahan yang disarankan untuk multi-platform:
- `client_app = mobile_user | mobile_talent | admin_portal | agency_portal`
- `allowed_surfaces[] = daftar surface yang boleh diakses account tersebut`

## Prinsip Pemisahan Data Database

Untuk database, arah yang disarankan adalah:

1. Login dan autentikasi boleh disatukan
  - satu tabel account atau auth untuk email, password hash, role, level, dan status login

2. Informasi domain jangan disatukan
  - data `user` harus berada di tabel informasi user sendiri
  - data `talent` harus berada di tabel informasi talent sendiri
  - data `agency` harus berada di tabel informasi agency sendiri

3. Alasan pemisahan ini wajib dipertahankan
  - komponen input tiap role berbeda
  - field bisnis tiap role berbeda
  - tim internal lebih mudah membaca data
  - query dan validasi lebih mudah dijaga
  - tidak menumpuk banyak kolom null di satu tabel campuran

4. Hindari tabel informasi campuran
  - jangan buat satu tabel besar berisi seluruh field user, talent, dan agency sekaligus
  - pendekatan seperti itu memang terlihat cepat di awal, tetapi biasanya menyulitkan pembacaan data, validasi, dan maintainability

## Session Context

Setiap response login atau profile minimal sebaiknya siap mengembalikan:
- `account_id`
- `role`
- `level`
- `client_app` atau `current_surface`
- `allowed_surfaces[]`
- `permissions[]`
- `access_token`
- `refresh_token`
- `profile_summary`

Contoh response minimal:

```json
{
  "success": true,
  "data": {
    "account_id": "acc_123",
    "role": "talent",
    "level": "basic",
    "client_app": "mobile_talent",
    "allowed_surfaces": [
      "mobile_talent"
    ],
    "permissions": [
      "view_talent_dashboard",
      "withdraw_earnings",
      "review_user"
    ],
    "access_token": "...",
    "refresh_token": "...",
    "profile_summary": {
      "display_name": "Jessica Martinez",
      "avatar_url": "https://..."
    }
  }
}
```

## Komponen Wajib di Semua Page

Komponen ini tidak berarti semua page memiliki bentuk visual yang sama, tetapi semua page yang terhubung ke backend harus punya dukungan data dan state berikut:

1. Session context
  - `account_id`
  - `role` = `user` atau `talent` atau `admin` atau `agency`
  - `level` untuk role yang membutuhkan tier
  - `client_app` atau `current_surface`
  - `allowed_surfaces[]`
  - `permissions[]`
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

Catatan penting:
- route frontend yang aktif saat ini masih berfokus pada `user` dan `talent`
- `admin` dan `agency` belum memiliki screen Flutter aktif di repo ini
- walaupun begitu, backend dan Copilot harus menyiapkan struktur aksesnya dari awal
- `agency` diperlakukan sebagai platform terpisah, bukan route tambahan di Flutter app yang sekarang

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

Catatan:
- Kontrak screen di bawah ini menjelaskan screen frontend yang sudah ada saat ini.
- Karena screen `admin` dan `agency` belum dibuat di Flutter, bagian mereka difokuskan pada persiapan contract backend, role, dan permission.
- khusus `agency`, arahnya adalah platform terpisah tetapi tetap satu auth domain dan satu backend

## 1. Login

Route: `/login`

Tujuan:
- Entry point untuk user, talent, admin, dan agency.

Komponen fixed:
- toggle login type saat ini aktif di frontend: `user` atau `talent`
- email input
- password input
- remember me
- tombol login
- navigasi ke register user atau register talent

Catatan role:
- backend tidak boleh mengasumsikan login hanya untuk dua role, walaupun UI Flutter aktif saat ini baru menampilkan `user` dan `talent`
- `admin` boleh memakai auth yang sama dan nantinya mengakses dua segment: `user` dan `talent`
- `agency` juga boleh memakai auth yang sama, tetapi login surface-nya diarahkan ke platform terpisah, bukan ke app Flutter ini

Backend minimal:
- `POST /login`
- request:
  - `email`
  - `password`
  - `type` atau `role`
  - `client_app` atau `login_surface`
- response:
  - token/session
  - role
  - level
  - client app aktif
  - allowed surfaces[]
  - permissions[]
  - profile summary
  - route target default

Catatan implementasi login:
- `role` menjelaskan identitas account
- `client_app` menjelaskan dari aplikasi atau portal mana login dilakukan
- kombinasi keduanya lebih aman daripada memaksa satu login flow untuk semua platform tanpa konteks surface
- login boleh memakai satu sistem auth yang sama, tetapi data profil domain setelah login tetap harus di-resolve ke tabel informasi yang sesuai: `user`, `talent`, atau `agency`

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
- backend juga harus menyiapkan default level untuk user baru, misalnya `basic`.

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
- default system fields:
  - `role = user`
  - `level = basic`

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
- backend juga harus menyiapkan default level untuk talent baru, misalnya `basic`.

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
- default system fields:
  - `role = talent`
  - `level = basic`

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

Catatan level:
- walaupun benefit `premium` belum final, response profile user sebaiknya sudah siap mengembalikan `level` agar frontend tidak perlu migrasi besar nanti.

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

Catatan level:
- talent dashboard sebaiknya juga menerima `level` agar nanti fitur premium talent bisa dibuka tanpa mengubah contract utama.

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

Catatan level:
- jika nanti ada fitur payout, analytics, visibility, atau portfolio limit khusus premium, backend tinggal membaca `level` tanpa mengubah role inti.

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

## 18. Admin

Status frontend saat ini:
- belum ada screen Flutter aktif untuk admin

Tujuan backend:
- menyiapkan role admin dari awal agar Copilot dan developer lain tidak membangun sistem yang hanya mengenal user dan talent.
- menyiapkan admin sebagai operator lintas segment, bukan sebagai turunan dari role user atau talent.

Role:
- `role = admin`
- `level = null` untuk saat ini, kecuali nanti memang dibutuhkan tier admin

Surface:
- `admin_portal`
- dapat diberi akses lintas segment `user` dan `talent`

Contoh permission admin:
- `view_admin_dashboard`
- `manage_users`
- `manage_talents`
- `manage_agencies`
- `manage_reviews`
- `manage_withdrawals`
- `manage_reports`
- `manage_verification`

Backend minimal:
- `GET /admin/dashboard`
- `GET /admin/users`
- `GET /admin/talents`
- `GET /admin/agencies`
- `GET /admin/withdrawals`
- `PATCH /admin/withdrawals/:id`
- `PATCH /admin/talent-verification/:id`

Catatan:
- belum perlu membuat UI Flutter admin sekarang jika belum dibutuhkan
- tetapi schema account, auth, permission, dan audit log harus siap menerima role ini
- admin tidak sebaiknya dipetakan sebagai `user` atau `talent`
- admin lebih tepat diposisikan sebagai operator yang bisa melihat atau mengelola dua segment tersebut

## 19. Agency

Status frontend saat ini:
- belum ada screen Flutter aktif untuk agency

Tujuan backend:
- menyiapkan role agency untuk kemungkinan pengelolaan banyak talent atau talent yang terhubung ke agency.
- menyiapkan agency sebagai platform terpisah yang tetap memakai satu backend dan satu domain autentikasi.

Role:
- `role = agency`
- `level = null` untuk saat ini, kecuali nanti agency juga punya paket layanan

Surface:
- `agency_portal`
- bukan bagian dari route aktif Flutter app saat ini

Contoh permission agency:
- `view_agency_dashboard`
- `manage_agency_profile`
- `view_agency_talents`
- `invite_talent`
- `view_talent_performance`
- `view_agency_payments`

Backend minimal:
- `GET /agency/me`
- `PATCH /agency/me`
- `GET /agency/talents`
- `POST /agency/talents/invite`
- `GET /agency/analytics`
- `GET /agency/payments`

Catatan:
- jika nanti talent bisa berada di bawah agency, relasi talent-agency harus disiapkan dari awal
- jangan menunggu UI agency selesai dulu baru menambah role ini di schema database
- agency tidak perlu dipaksa masuk ke mobile app user/talent
- lebih baik diperlakukan sebagai client app atau portal terpisah yang memakai auth service yang sama

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
   - admin dan agency juga tidak boleh dipaksa memakai contract user atau talent

4a. Jika ada perbedaan domain data, pisahkan tabel informasinya
  - auth boleh satu tempat
  - tetapi informasi `user`, `talent`, dan `agency` harus tetap dipisah

5. Untuk screen yang sudah fixed, fokus backend hanya pada:
   - source data
   - action endpoint
   - validation
   - state update frontend

6. Gunakan role system yang extensible
   - role untuk aktor utama
   - level untuk tier
   - permissions untuk kontrol aksi

7. Bedakan role dan surface
  - role menjelaskan siapa aktornya
  - surface menjelaskan aplikasi atau portal mana yang dipakai login
  - contoh: account `admin` bisa punya akses lintas segment, sedangkan `agency` dibatasi ke `agency_portal`

## Rekomendasi Skema Account

Skema konseptual yang disarankan:

- `accounts`
  - `id`
  - `email`
  - `password_hash`
  - `role`
  - `level`
  - `status`
  - `created_at`
  - `updated_at`

Fungsi tabel `accounts`:
- hanya untuk identitas login dan kontrol akses umum
- jangan dipakai untuk menampung seluruh data profil user, talent, dan agency dalam satu tabel yang sama

- `account_surfaces`
  - `account_id`
  - `surface_key`

- `account_permissions`
  - `account_id`
  - `permission_key`

- `auth_sessions`
  - `id`
  - `account_id`
  - `client_app`
  - `refresh_token`
  - `issued_at`
  - `expired_at`

- `user_profiles`
  - relasi ke `accounts`

- `user_information`
  - relasi ke `accounts`
  - hanya berisi field khusus user

- `talent_profiles`
  - relasi ke `accounts`

- `talent_information`
  - relasi ke `accounts`
  - hanya berisi field khusus talent

- `agency_profiles`
  - relasi ke `accounts`

- `agency_information`
  - relasi ke `accounts`
  - hanya berisi field khusus agency

- `admin_profiles`
  - opsional, jika admin butuh metadata tambahan

Catatan penamaan tabel:
- Anda boleh memakai nama `user_profiles` atau `user_information`
- Anda boleh memakai nama `talent_profiles` atau `talent_information`
- Anda boleh memakai nama `agency_profiles` atau `agency_information`
- yang penting bukan nama tabelnya, tetapi prinsip bahwa datanya dipisah per domain role

Catatan:
- jika ingin lebih sederhana, `permissions` bisa diturunkan dari role tanpa tabel khusus di tahap awal
- tetapi field `role` dan `level` sebaiknya sudah ada sejak awal agar migrasi berikutnya tidak mahal
- untuk kebutuhan multi-platform, field surface atau client app juga sebaiknya disiapkan dari awal
- untuk keterbacaan tim internal, sangat disarankan memisahkan tabel informasi role daripada membuat satu tabel profil campuran

## Contoh Pola Login dan Join Informasi

Pola yang disarankan:

1. Satu tabel login atau account
   - contoh: `accounts`
   - berisi email, password hash, role, level, status

2. Satu account hanya di-resolve ke tabel informasi yang sesuai dengan role-nya
   - jika `role = user`, join ke `user_information`
   - jika `role = talent`, join ke `talent_information`
   - jika `role = agency`, join ke `agency_information`

Contoh konsep relasi:

```text
accounts
  id = acc_001
  email = user@mail.com
  role = user
  level = basic

user_information
  account_id = acc_001
  first_name = Aditya
  last_name = Saputra
  phone = 0812xxxx
```

```text
accounts
  id = acc_002
  email = talent@mail.com
  role = talent
  level = basic

talent_information
  account_id = acc_002
  stage_name = Jessica Martinez
  bio = ...
  years_of_experience = 3
```

```text
accounts
  id = acc_003
  email = agency@mail.com
  role = agency
  level = null

agency_information
  account_id = acc_003
  agency_name = Bright Agency
  company_phone = 021xxxx
  business_address = ...
```

Contoh query konseptual saat login berhasil:

```sql
SELECT a.id, a.email, a.role, a.level, u.first_name, u.last_name
FROM accounts a
JOIN user_information u ON u.account_id = a.id
WHERE a.email = :email AND a.role = 'user';
```

```sql
SELECT a.id, a.email, a.role, a.level, t.stage_name, t.bio
FROM accounts a
JOIN talent_information t ON t.account_id = a.id
WHERE a.email = :email AND a.role = 'talent';
```

```sql
SELECT a.id, a.email, a.role, a.level, ag.agency_name
FROM accounts a
JOIN agency_information ag ON ag.account_id = a.id
WHERE a.email = :email AND a.role = 'agency';
```

Catatan penting:
- jangan membuat satu query join ke semua tabel informasi sekaligus untuk semua kebutuhan bisnis sehari-hari
- resolve data berdasarkan role account yang sudah valid setelah login
- dengan pola ini, tim internal akan lebih mudah membaca data karena struktur domain tetap terpisah

## Prinsip Untuk Skema Transaksi dan Data Bisnis

Tujuan pemisahan ini memang benar: agar transaksi dan data bisnis lain tidak tertukar di masa depan.

Prinsip yang disarankan:

1. Semua transaksi tetap boleh berangkat dari `account_id`
2. Tetapi detail domain tetap mengacu ke entitas role yang benar
3. Jangan simpan transaksi dengan asumsi semua actor berasal dari satu tabel profil campuran

Contoh arah relasi:
- transaksi top up user mengacu ke `accounts.id` dan konteks `user_information`
- payout talent mengacu ke `accounts.id` dan konteks `talent_information`
- pembayaran agency mengacu ke `accounts.id` dan konteks `agency_information`

Contoh tabel konseptual:

```text
wallet_transactions
  id
  account_id
  role_snapshot
  transaction_type
  amount
  status
  created_at
```

```text
withdraw_requests
  id
  account_id
  role_snapshot = talent
  coin_amount
  cash_amount
  withdraw_method
  status
  created_at
```

```text
agency_payments
  id
  account_id
  payment_type
  amount
  status
  created_at
```

Catatan penting:
- simpan `role_snapshot` jika transaksi perlu audit histori yang stabil
- ini berguna jika suatu hari ada perubahan level, permission, atau struktur role
- tabel transaksi tidak harus dipisah semua, tetapi konteks actor dan domainnya harus tetap jelas

## Prinsip Keuangan dan Ledger Yang Disarankan

Karena ini menyangkut keuangan langsung, saran utamanya adalah:

1. Jangan campur saldo user dan saldo talent dalam satu tabel saldo yang sama
2. Pisahkan wallet domain per aktor keuangan
3. Simpan ledger transaksi yang eksplisit debit dan credit
4. Simpan snapshot kurs, fee, dan nilai payout pada saat transaksi terjadi

## Arah Model Wallet Yang Disarankan

Model yang lebih aman:

1. User wallet terpisah
  - menyimpan saldo coin milik user
  - sumber utamanya: top up, refund, bonus, pengurangan saat memakai layanan

2. Talent wallet terpisah
  - menyimpan saldo coin milik talent sebagai earning balance
  - sumber utamanya: credit hasil layanan, adjustment, payout request

3. Agency wallet terpisah jika nanti diperlukan
  - dipakai hanya jika agency memang punya arus saldo sendiri

Catatan penting:
- `1000 coin user` boleh tetap dianggap `1000 coin` saat berpindah ke domain earning talent
- tetapi nilai rupiah saat payout talent tidak harus sama dengan nilai rupiah saat user top up
- selisih ini harus direpresentasikan sebagai fee, margin, atau revenue platform secara eksplisit

## Contoh Rule Yang Anda Jelaskan

Contoh rule:
- user memiliki `1000 coin`
- nilai beli user: `1000 coin = Rp 100.000`
- saat dipakai untuk layanan talent, talent menerima `1000 earning coin`
- saat talent withdraw, `1000 earning coin = Rp 65.000`
- selisih `Rp 35.000` adalah bagian platform

Saran saya:
- jangan hanya simpan nilai coin
- simpan juga nilai rupiah yang relevan di setiap event finansial
- jangan hitung ulang dari rule global saat audit histori lama

## Struktur Finansial Yang Lebih Aman

Gunakan minimal tiga lapisan:

1. Wallet balance table
  - untuk saldo berjalan

2. Ledger table
  - untuk catatan debit atau credit yang immutable

3. Withdrawal or payout table
  - untuk proses pencairan ke uang nyata

Contoh konsep tabel:

```text
user_wallets
  id
  account_id
  available_coin_balance
  pending_coin_balance
  updated_at
```

```text
talent_wallets
  id
  account_id
  available_earning_coin_balance
  pending_withdraw_coin_balance
  updated_at
```

```text
wallet_ledger_entries
  id
  account_id
  wallet_domain
  entry_type
  direction
  coin_amount
  rupiah_gross_amount
  rupiah_fee_amount
  rupiah_net_amount
  reference_type
  reference_id
  role_snapshot
  created_at
```

```text
withdraw_requests
  id
  account_id
  wallet_id
  coin_amount
  payout_rate_snapshot
  rupiah_gross_amount
  rupiah_fee_amount
  rupiah_net_amount
  withdraw_method
  status
  created_at
```

## Arti Field Ledger Yang Disarankan

Penjelasan penting:
- `wallet_domain`
  - contoh: `user_coin`, `talent_earning_coin`, `agency_balance`

- `entry_type`
  - contoh: `topup`, `spend_chat`, `spend_video`, `spend_meet`, `earning_credit`, `withdraw_request`, `withdraw_complete`, `refund`, `adjustment`, `platform_fee`

- `direction`
  - `debit` = saldo berkurang
  - `credit` = saldo bertambah

- `rupiah_gross_amount`
  - nilai bruto sebelum fee

- `rupiah_fee_amount`
  - potongan platform atau fee lain

- `rupiah_net_amount`
  - nilai bersih setelah fee

- `reference_type` dan `reference_id`
  - menghubungkan ledger ke chat session, meet request, topup order, withdrawal, dan seterusnya

## Debit dan Credit Yang Harus Jelas

Contoh arus yang disarankan:

1. User top up
  - user wallet: `credit`
  - platform cash record: masuk

2. User memakai layanan chat atau meet
  - user wallet: `debit`
  - talent wallet: `credit`
  - platform fee/revenue: dicatat eksplisit jika diperlukan

3. Talent withdraw
  - talent wallet: `debit`
  - withdraw request: dibuat
  - payout rupiah net: dicatat dengan fee snapshot

4. Refund
  - user wallet: `credit`
  - talent wallet: `debit` jika transaksi sebelumnya sudah di-credit
  - semua arus harus punya referensi transaksi asal

## Saran Penting Untuk Konversi Coin dan Fee

Saran saya untuk kasus Anda:

1. Pisahkan konsep `purchase value` dan `payout value`
  - nilai beli coin oleh user tidak harus sama dengan nilai payout ke talent

2. Gunakan snapshot rate per transaksi
  - jangan hanya mengandalkan satu config global yang bisa berubah sewaktu-waktu

3. Simpan fee secara eksplisit
  - jangan biarkan fee hanya implisit dari selisih perhitungan

4. Simpan nilai gross dan net
  - supaya tim finance dan tim internal mudah audit

Contoh snapshot yang baik saat withdraw:
- `coin_amount = 1000`
- `user_purchase_equivalent = Rp 100.000`
- `talent_payout_gross = Rp 100.000` atau sesuai rule bisnis yang dipakai
- `platform_fee = Rp 35.000`
- `talent_payout_net = Rp 65.000`

Jika rule bisnis sebenarnya adalah langsung:
- `1000 earning coin talent = Rp 65.000`

maka tetap simpan:
- `payout_rate_snapshot`
- `rupiah_net_amount`
- `rupiah_fee_amount` jika ada

## Rekomendasi Arsitektur Praktis

Kalau ingin sederhana tapi tetap aman, saya sarankan:

1. `accounts`
2. `user_information`
3. `talent_information`
4. `agency_information`
5. `user_wallets`
6. `talent_wallets`
7. `wallet_ledger_entries`
8. `withdraw_requests`
9. `topup_orders`

Dengan model ini:
- auth tetap satu pintu
- informasi role tetap terpisah
- wallet user dan talent tidak tercampur
- fee dan debit or credit bisa diaudit dengan jelas

## Kesimpulan Saran

Untuk kasus Anda, saya sangat menyarankan:
- pisahkan tabel wallet user dan talent
- gunakan ledger terpusat untuk audit debit atau credit
- simpan snapshot rate dan fee di setiap transaksi keuangan penting
- jangan hitung nilai payout berdasarkan asumsi global saat membaca histori lama

## Matriks Role dan Level Awal

| Role | Level | Status Saat Ini |
| --- | --- | --- |
| user | basic | aktif dipakai |
| user | premium | disiapkan dari awal |
| talent | basic | aktif dipakai |
| talent | premium | disiapkan dari awal |
| admin | null | disiapkan dari awal |
| agency | null | disiapkan dari awal |

## Matriks Role dan Surface Awal

| Role | Surface Utama | Catatan |
| --- | --- | --- |
| user | mobile_user | aktif dipakai |
| talent | mobile_talent | aktif dipakai |
| admin | admin_portal | lintas segment user dan talent |
| agency | agency_portal | platform terpisah, satu backend dan satu auth |

## Contoh Instruksi Backend yang Disarankan

Contoh 1:

`Buat backend untuk Register Talent sesuai screen saat ini. Field wajib: username, password, confirm password, stage name, bio, referral agency, years of experience, languages, specialties, upload identity card, selfie verification, portfolio photos.`

Contoh 2:

`Hubungkan Talent Profile untuk bagian withdraw earnings tanpa mengubah layout. Backend harus menerima coin_amount, withdraw_method, account_name, account_number, lalu mengembalikan status payout dan memperbarui payment history.`

Contoh 3:

`Hubungkan User Activity dan Talent Activity agar message schedule aktif untuk kedua sisi hanya pada window H-3 sampai H+1 dari accepted meet request.`

Contoh 4:

`Buat auth dan account schema dengan RBAC + level. Role yang harus didukung dari awal: user, talent, admin, agency. Level disiapkan untuk user dan talent: basic, premium. Walaupun UI aktif sekarang baru user dan talent, response login dan profile harus sudah mengembalikan role, level, dan permissions.`

Contoh 5:

`Siapkan single auth domain dengan multi-surface access. Admin harus bisa mengelola segment user dan talent melalui surface yang sesuai. Agency berjalan di platform terpisah tetapi tetap memakai backend dan auth service yang sama.`

## Catatan Penutup

Dokumen ini adalah kontrak kerja antara UI frontend dan backend untuk kondisi screen saat ini.

Jika ada fitur baru, update dokumen ini terlebih dahulu atau bersamaan dengan perubahan screen agar backend dan frontend tetap sinkron.

Secara arsitektur, arah yang disarankan untuk project ini adalah:
- gunakan `RBAC + Level`
- siapkan `admin` dan `agency` dari awal di backend
- siapkan `basic` dan `premium` untuk `user` dan `talent` dari awal, walaupun behavior premium belum final
- jangan tunggu UI admin, agency, atau premium selesai baru menyiapkan schema account dan auth
- bedakan dengan jelas antara `role` dan `surface/platform`
- perlakukan `agency` sebagai platform terpisah dalam satu ekosistem backend dan autentikasi