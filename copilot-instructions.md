# Copilot Instructions For This Repository

Sebelum membuat perubahan apa pun di repo ini, baca terlebih dahulu:
- `BACKEND_UI_SCREEN_CONTRACT.md`
- `FRONTEND_UI_DEVELOPMENT_GUARDRAILS.md`
- `FINANCIAL_LEDGER_ARCHITECTURE.md`

## Tujuan

Instruksi ini dibuat agar Copilot atau agent lain yang membantu di repo ini tidak merusak keputusan UI dan flow yang sudah ditetapkan.

## Aturan Wajib

1. Anggap semua screen yang ada saat ini sebagai baseline yang sudah fix.
2. Jangan ubah struktur layout utama kecuali memang diminta langsung.
3. Fokus utama perubahan frontend adalah:
   - menghubungkan backend ke UI yang sudah ada,
   - memperbaiki bug,
   - menambah fitur yang benar-benar dibutuhkan,
   - memperbaiki issue layout secara minimal.
4. Jangan memaksa frontend mengikuti bentuk backend yang belum sesuai. Backend harus mengikuti kontrak UI yang sudah ada.
5. Jangan satukan flow user dan talent jika dari desain atau screen memang berbeda.
6. Jangan menghapus status atau rule bisnis yang sudah dipakai lintas screen.
7. Jangan memetakan `admin` sebagai `user` atau `talent` hanya untuk menyesuaikan UI yang ada.
8. Perlakukan `agency` sebagai platform terpisah jika tugas menyangkut auth atau backend contract, kecuali user secara eksplisit meminta membangun UI agency di repo ini.

## Status dan Rule Bisnis yang Harus Dipertahankan

Status yang harus tetap konsisten:
- `pending`
- `accepted`
- `rejected`
- `cancelled`
- `completed`
- `active`
- `archived`

Rule penting yang harus tetap dijaga:
- chat berbasis schedule aktif hanya pada H-3 sampai H+1 acara
- review hanya muncul untuk transaksi yang siap direview
- withdraw talent harus masuk ke payment history dan memengaruhi balance
- route user dan talent tidak boleh tertukar
- backend boleh multi-role dan multi-surface, tetapi app Flutter aktif saat ini tetap fokus pada segment `user` dan `talent`

## Prioritas Saat Diminta Melakukan Perubahan

1. Baca screen target dan dokumentasi repo terlebih dahulu.
2. Ubah seminimal mungkin.
3. Jangan reformat atau refactor area yang tidak relevan.
4. Jika perubahan menyentuh kontrak screen atau data penting, update dokumentasi terkait.
5. Setelah edit, validasi error pada file yang diubah.

## Saat Mengerjakan Backend Integration

Jika tugasnya menghubungkan backend:
- pertahankan layout dan komponen yang ada,
- ganti dummy data dengan data backend,
- tambahkan loading, empty, error state bila perlu,
- pertahankan nama section, label penting, dan flow page.

Jika tugasnya menyentuh auth atau database contract:
- auth boleh terpusat dalam satu sistem account/login,
- tetapi informasi `user`, `talent`, dan `agency` tidak boleh digabung ke satu tabel profil campuran,
- pertahankan pemisahan tabel informasi per domain role agar struktur data tetap terbaca oleh tim internal.

Jika tugasnya menyentuh wallet, transaksi, payout, atau fee:
- jangan campur wallet user dan wallet talent dalam satu saldo domain yang sama,
- gunakan ledger debit atau credit yang eksplisit,
- simpan snapshot rate, gross amount, fee amount, dan net amount untuk transaksi finansial penting,
- jangan mengandalkan satu rule global yang dihitung ulang saat membaca histori lama.

## Saat Mengerjakan Frontend Feature

Jika tugasnya menambah fitur:
- pastikan fitur memang diminta,
- jangan merusak urutan section atau navigasi yang sudah ada,
- jelaskan kontrak backend baru jika fitur memerlukan endpoint tambahan.

## Saat Mengerjakan Bug Fix

Jika tugasnya bug fix:
- cari akar masalah,
- lakukan patch kecil yang fokus,
- jangan lakukan redesign tanpa permintaan.

## Catatan Akhir

Repo ini harus dijaga agar pengembangan backend dan frontend tetap sinkron.

Jika ragu, selalu utamakan mempertahankan UI yang ada dan lihat dokumentasi repo sebelum melakukan perubahan.