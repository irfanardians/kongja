# Frontend UI Development Guardrails

Dokumen ini adalah guardrail untuk pengembangan frontend berikutnya.

Tujuan dokumen ini:
- Menjaga agar UI yang sudah disetujui tidak berubah sembarangan.
- Memastikan siapa pun yang pull project ini memahami aspek layout, flow, dan komponen yang sudah dianggap final.
- Menjadi acuan sebelum memberi instruksi ke Copilot atau melakukan perubahan manual.

## Status UI Saat Ini

UI yang ada saat ini dianggap sebagai baseline yang harus dijaga.

Perubahan frontend hanya boleh dilakukan untuk:
- menghubungkan data backend ke komponen yang sudah ada,
- memperbaiki bug,
- memperbaiki responsive/layout issue,
- menambah fitur baru yang memang dibutuhkan,
- perubahan yang diminta langsung oleh produk atau desain.

Perubahan berikut tidak boleh dilakukan tanpa instruksi yang jelas:
- mengganti struktur utama screen,
- menghapus komponen yang sudah dipakai flow,
- mengubah route atau alur bottom navigation,
- mengganti label atau status penting yang sudah dipakai di beberapa screen,
- menyederhanakan UI dengan menghapus state seperti active, archived, pending, accepted, rejected.

## Dokumen yang Wajib Dibaca Sebelum Mengubah UI

Sebelum memberi instruksi ke Copilot atau mengubah frontend secara manual, baca dokumen berikut:

1. `BACKEND_UI_SCREEN_CONTRACT.md`
   - kontrak screen dan kebutuhan backend per page

2. `FRONTEND_UI_DEVELOPMENT_GUARDRAILS.md`
   - guardrail pengembangan UI dan aturan perubahan frontend

3. `copilot-instructions.md`
   - instruksi khusus repo agar Copilot tidak mengubah hal yang sudah ditetapkan

## Prinsip Utama Pengembangan Frontend

1. Ikuti screen yang sudah ada
- Screen yang sudah ada adalah sumber kebenaran UI saat ini.
- Jika backend belum siap, jangan ubah layout untuk menyesuaikan backend.

2. Data mengikuti UI, bukan sebaliknya
- Field dan state backend harus mengisi komponen yang sudah ada.
- Jika ada data tambahan dari backend yang belum dipakai UI, jangan memaksa tampilkan tanpa kebutuhan produk.

3. Jangan ubah flow role user dan talent
- User dan talent punya flow berbeda.
- Register user dan register talent tidak boleh disatukan secara sembarangan.
- Activity user dan talent boleh mirip, tapi tetap mengikuti peran masing-masing.

Catatan multi-role:
- `admin` bukan turunan UI dari `user` atau `talent` di app Flutter ini
- `agency` diarahkan sebagai platform terpisah walaupun tetap satu backend dan satu domain autentikasi
- jangan menambah screen agency ke app ini tanpa instruksi produk yang jelas

4. Pertahankan status bisnis yang sudah dipakai UI
- `pending`
- `accepted`
- `rejected`
- `cancelled`
- `completed`
- `active`
- `archived`

5. Pertahankan rule yang sudah disepakati
- chat/message berbasis schedule aktif pada H-3 sampai H+1 acara
- review hanya muncul pada transaksi yang memang siap direview
- withdraw talent harus mengurangi balance dan masuk ke payment history

6. Perbaikan visual harus minimal dan terukur
- jangan re-style seluruh screen hanya untuk memperbaiki satu bug
- jika ada overflow atau spacing issue, perbaiki di sumber masalahnya
- hindari reformat besar atau refactor UI luas tanpa kebutuhan nyata

## Area Frontend yang Dianggap Fixed

## Auth
- Login
- Register User
- Register Talent

## User
- Home
- Talent detail profile
- Activity
- Chat
- Favorites
- Settings
- Top Up
- Transaction History
- User Profile

## Talent
- Talent Home
- Talent Activity
- Talent Chat
- Talent Profile
- Talent Settings

## Shared
- Review Composer Sheet
- Activity Session Screen

## Aturan Perubahan per Kategori

## 1. Binding Backend

Boleh dilakukan:
- mengganti dummy data menjadi data API
- menambah model, repository, service, provider, bloc, atau state layer
- menambah loading, empty, dan error state

Tidak boleh menjadi alasan untuk:
- menghapus section yang sudah ada
- mengganti urutan screen utama tanpa instruksi
- mengubah label status bisnis yang sudah dipakai lintas screen

## 2. Bug Fix

Boleh dilakukan:
- overflow fix
- state fix
- navigation fix
- modal/sheet fix
- null state atau empty state fix

Harus dihindari:
- refactor besar jika bug bisa selesai dengan patch kecil
- menyentuh banyak file yang tidak relevan

## 3. Penambahan Fitur

Boleh dilakukan jika:
- fitur memang diminta jelas
- tidak merusak flow existing
- data contract baru bisa dijelaskan dengan jelas

Wajib dilakukan saat menambah fitur:
- jelaskan screen yang terdampak
- jelaskan komponen baru
- jelaskan kebutuhan backend baru
- update dokumentasi bila fitur mengubah contract

## 4. Refactor UI

Refactor besar tidak boleh dilakukan tanpa alasan kuat.

Contoh alasan yang valid:
- duplicate UI sudah benar-benar menghambat maintainability
- ada bug berulang karena struktur sekarang tidak aman
- dibutuhkan komponen reusable yang dipakai banyak screen

## Panduan Memberi Instruksi ke Copilot

Saat orang lain pull UI ini dan ingin meminta bantuan Copilot, gunakan pola instruksi berikut:

1. Sebutkan screen target
   - contoh: `Talent Profile`, `User Home`, `Register Talent`

2. Tegaskan bahwa layout existing harus dipertahankan
   - contoh: `jangan ubah struktur UI yang sudah ada, hanya hubungkan ke backend`

3. Sebutkan komponen yang boleh disentuh
   - contoh: `hanya bagian withdraw earnings dan payment history`

4. Sebutkan apa yang tidak boleh diubah
   - contoh: `jangan ubah bottom nav, jangan ubah urutan section profile`

5. Minta Copilot membaca dokumentasi dulu
   - contoh: `baca BACKEND_UI_SCREEN_CONTRACT.md dan FRONTEND_UI_DEVELOPMENT_GUARDRAILS.md sebelum mengubah kode`

## Contoh Instruksi Aman untuk Copilot

Contoh 1:

`Baca BACKEND_UI_SCREEN_CONTRACT.md dan FRONTEND_UI_DEVELOPMENT_GUARDRAILS.md terlebih dahulu. Hubungkan User Home ke backend tanpa mengubah layout, filter, atau struktur host card yang sudah ada.`

Contoh 2:

`Baca dokumentasi repo terlebih dahulu. Di Talent Profile, hanya hubungkan withdraw earnings dan payment history ke backend. Jangan ubah urutan section, gaya card, atau flow profile yang sudah ada.`

Contoh 3:

`Baca guardrail frontend repo terlebih dahulu. Perbaiki overflow di screen terkait tanpa refactor besar dan tanpa mengubah visual utama.`

## Checklist Sebelum Merge Perubahan Frontend

Pastikan hal ini tetap benar:
- route utama tidak berubah sembarangan
- label tab dan menu masih konsisten
- status bisnis masih sama
- flow user dan talent tidak tertukar
- role `admin` tidak dipaksakan menjadi flow `user` atau `talent`
- `agency` tidak disisipkan ke mobile app ini jika memang arahnya platform terpisah
- komponen schedule, review, withdraw, activity tetap berjalan sesuai tujuan awal
- perubahan tidak merusak screen lain yang sudah stabil
- jika contract berubah, dokumentasi ikut diupdate

## Catatan Penutup

Frontend project ini bukan area bebas ubah bentuk.

Siapa pun yang mengembangkan berikutnya harus memperlakukan UI sekarang sebagai baseline produk yang sudah diarahkan. Perubahan harus fokus pada integrasi data, kestabilan flow, dan fitur yang memang dibutuhkan, bukan re-interpretasi desain ulang.