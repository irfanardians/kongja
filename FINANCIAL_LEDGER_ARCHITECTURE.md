# Financial Ledger Architecture

Dokumen ini menjelaskan fondasi data keuangan yang disarankan untuk project ini.

Tujuan dokumen ini:
- memastikan arus uang dan coin antara user, talent, agency, dan platform tidak tertukar,
- memastikan debit dan credit tercatat jelas,
- memastikan histori transaksi tetap bisa diaudit walaupun rule fee atau konversi berubah di masa depan,
- menjadi acuan backend saat mulai membangun wallet, top up, payout, dan fee.

## Prinsip Utama

1. Jangan campur wallet user dan wallet talent dalam satu saldo yang sama.
2. Gunakan ledger debit dan credit yang eksplisit.
3. Simpan snapshot nilai finansial per transaksi.
4. Jangan mengandalkan perhitungan ulang dari config global untuk histori lama.
5. Pisahkan saldo berjalan dan histori ledger.

## Konteks Bisnis Dasar

Contoh rule bisnis yang perlu diakomodasi:
- user membeli `1000 coin = Rp 100.000`
- user memakai `1000 coin` untuk layanan talent
- talent menerima `1000 earning coin`
- saat withdraw, `1000 earning coin = Rp 65.000`
- selisih `Rp 35.000` adalah revenue atau fee platform

Catatan penting:
- `coin` tidak selalu identik dengan nilai payout final dalam rupiah
- karena itu sistem harus menyimpan nilai coin dan nilai rupiah secara terpisah

## Struktur Domain Finansial

## 1. Wallet domain

Wallet dipisah berdasarkan domain aktor:

- `user_wallets`
  - saldo coin yang dipakai user untuk konsumsi layanan

- `talent_wallets`
  - saldo earning coin yang dimiliki talent

- `agency_wallets`
  - opsional, hanya jika agency benar-benar punya arus saldo sendiri

## 2. Ledger domain

Ledger adalah catatan immutable untuk setiap perubahan saldo.

Ledger harus menyimpan:
- siapa aktornya
- wallet domain apa yang berubah
- apakah debit atau credit
- berapa coin yang berubah
- berapa nilai rupiah gross, fee, dan net
- referensi transaksi sumbernya

## 3. Payout domain

Payout adalah proses ketika earning coin talent diubah menjadi uang nyata.

Payout harus menyimpan:
- nilai coin
- rate snapshot
- gross amount
- fee amount
- net amount
- method dan account payout
- status payout

## Rekomendasi Tabel Minimal

## accounts

Dipakai untuk auth dan identity umum.

```sql
CREATE TABLE accounts (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role VARCHAR(50) NOT NULL,
  level VARCHAR(50),
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## user_information

```sql
CREATE TABLE user_information (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT NOT NULL UNIQUE REFERENCES accounts(id),
  first_name VARCHAR(120) NOT NULL,
  last_name VARCHAR(120),
  call_name VARCHAR(120),
  phone VARCHAR(50),
  gender VARCHAR(30),
  date_of_birth DATE,
  address TEXT,
  country VARCHAR(120),
  city VARCHAR(120),
  postcode VARCHAR(30),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## talent_information

```sql
CREATE TABLE talent_information (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT NOT NULL UNIQUE REFERENCES accounts(id),
  stage_name VARCHAR(180) NOT NULL,
  bio TEXT,
  referral_agency VARCHAR(180),
  years_of_experience INTEGER,
  verification_status VARCHAR(50) NOT NULL DEFAULT 'draft',
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## agency_information

```sql
CREATE TABLE agency_information (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT NOT NULL UNIQUE REFERENCES accounts(id),
  agency_name VARCHAR(180) NOT NULL,
  company_phone VARCHAR(50),
  business_address TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## user_wallets

```sql
CREATE TABLE user_wallets (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT NOT NULL UNIQUE REFERENCES accounts(id),
  available_coin_balance BIGINT NOT NULL DEFAULT 0,
  pending_coin_balance BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## talent_wallets

```sql
CREATE TABLE talent_wallets (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT NOT NULL UNIQUE REFERENCES accounts(id),
  available_earning_coin_balance BIGINT NOT NULL DEFAULT 0,
  pending_withdraw_coin_balance BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## agency_wallets

Opsional, jika agency memang punya arus saldo sendiri.

```sql
CREATE TABLE agency_wallets (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT NOT NULL UNIQUE REFERENCES accounts(id),
  available_balance BIGINT NOT NULL DEFAULT 0,
  pending_balance BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## wallet_ledger_entries

Ini tabel paling penting untuk audit.

```sql
CREATE TABLE wallet_ledger_entries (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT NOT NULL REFERENCES accounts(id),
  wallet_domain VARCHAR(50) NOT NULL,
  role_snapshot VARCHAR(50) NOT NULL,
  entry_type VARCHAR(80) NOT NULL,
  direction VARCHAR(20) NOT NULL,
  coin_amount BIGINT NOT NULL DEFAULT 0,
  rupiah_gross_amount BIGINT NOT NULL DEFAULT 0,
  rupiah_fee_amount BIGINT NOT NULL DEFAULT 0,
  rupiah_net_amount BIGINT NOT NULL DEFAULT 0,
  reference_type VARCHAR(80),
  reference_id BIGINT,
  notes TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## topup_orders

```sql
CREATE TABLE topup_orders (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT NOT NULL REFERENCES accounts(id),
  package_name VARCHAR(120),
  coin_amount BIGINT NOT NULL,
  rupiah_amount BIGINT NOT NULL,
  bonus_coin_amount BIGINT NOT NULL DEFAULT 0,
  payment_method VARCHAR(80) NOT NULL,
  status VARCHAR(50) NOT NULL,
  provider_reference VARCHAR(180),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## withdraw_requests

```sql
CREATE TABLE withdraw_requests (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT NOT NULL REFERENCES accounts(id),
  talent_wallet_id BIGINT NOT NULL REFERENCES talent_wallets(id),
  coin_amount BIGINT NOT NULL,
  payout_rate_snapshot NUMERIC(18,4) NOT NULL,
  rupiah_gross_amount BIGINT NOT NULL,
  rupiah_fee_amount BIGINT NOT NULL,
  rupiah_net_amount BIGINT NOT NULL,
  withdraw_method VARCHAR(80) NOT NULL,
  account_name VARCHAR(180) NOT NULL,
  account_number VARCHAR(120) NOT NULL,
  status VARCHAR(50) NOT NULL,
  processed_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## Tabel Fee Configuration

Kalau ingin rate fleksibel, simpan config terpisah. Namun histori transaksi tetap wajib menyimpan snapshot saat event terjadi.

```sql
CREATE TABLE financial_rules (
  id BIGSERIAL PRIMARY KEY,
  rule_key VARCHAR(100) NOT NULL UNIQUE,
  coin_to_rupiah_rate NUMERIC(18,4),
  fee_percentage NUMERIC(8,4),
  fee_flat_amount BIGINT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## Debit Dan Credit Yang Disarankan

## 1. User top up

Contoh:
- user beli `1000 coin` seharga `Rp 100.000`

Pencatatan:
- `topup_orders`: dibuat `completed`
- `user_wallets.available_coin_balance`: `+1000`
- `wallet_ledger_entries`: `credit`, `wallet_domain = user_coin`

## 2. User memakai layanan talent

Contoh:
- user pakai `1000 coin` untuk meet atau chat

Pencatatan minimum:
- `user_wallets.available_coin_balance`: `-1000`
- `talent_wallets.available_earning_coin_balance`: `+1000`
- ledger user: `debit`
- ledger talent: `credit`

Jika platform ingin mencatat revenue secara eksplisit:
- buat entry tambahan pada domain finance internal atau platform settlement

## 3. Talent withdraw

Contoh:
- talent withdraw `1000 earning coin`
- payout net `Rp 65.000`

Pencatatan minimum:
- `withdraw_requests`: dibuat `pending`
- `talent_wallets.available_earning_coin_balance`: `-1000`
- `talent_wallets.pending_withdraw_coin_balance`: `+1000`
- ledger talent: `debit`
- snapshot gross, fee, dan net disimpan di request dan ledger

Saat payout selesai:
- `withdraw_requests.status = completed`
- `talent_wallets.pending_withdraw_coin_balance`: `-1000`
- ledger tambahan bisa dibuat untuk `withdraw_complete`

## 4. Refund user

Jika transaksi dibatalkan:
- user wallet: `credit`
- talent wallet: `debit` jika sebelumnya earning sudah masuk
- semua entry harus punya `reference_type` dan `reference_id` yang sama dengan transaksi asal

## Wallet Domain Yang Disarankan

Gunakan domain yang eksplisit pada ledger:
- `user_coin`
- `talent_earning_coin`
- `agency_balance`
- `platform_fee`

Ini membantu audit dan memisahkan arus nilai.

## Contoh Ledger Dari Kasus Anda

Kasus:
- user top up `1000 coin = Rp 100.000`
- user transfer `1000 coin` ke talent
- talent withdraw `1000 coin = Rp 65.000`

Contoh ledger ringkas:

```text
1. user_coin credit +1000 | gross 100000 | fee 0 | net 100000 | entry_type topup
2. user_coin debit -1000 | gross 100000 | fee 0 | net 100000 | entry_type spend_meet
3. talent_earning_coin credit +1000 | gross 100000 | fee 0 | net 100000 | entry_type earning_credit
4. talent_earning_coin debit -1000 | gross 100000 | fee 35000 | net 65000 | entry_type withdraw_request
```

Jika Anda ingin lebih akurat secara finance internal, Anda juga bisa menambah:

```text
5. platform_fee credit 35000 | entry_type withdraw_fee
```

## Saran Teknis Penting

1. Gunakan transaksi database saat mengubah balance dan ledger.
2. Jangan ubah saldo tanpa membuat entry ledger.
3. Ledger sebaiknya immutable.
4. Balance wallet adalah hasil posisi berjalan, bukan sumber kebenaran utama.
5. Sumber kebenaran audit tetap ledger.

## Kesimpulan

Model yang saya sarankan untuk kondisi Anda:
- auth/account tetap satu pintu
- user, talent, dan agency information tetap terpisah
- `user_wallets` dan `talent_wallets` dipisah
- semua arus coin dan rupiah dicatat di `wallet_ledger_entries`
- payout talent harus menyimpan gross, fee, net, dan rate snapshot

Ini adalah fondasi paling aman jika Anda ingin sistem tetap terbaca, tidak tertukar, dan siap diaudit saat volume transaksi membesar.