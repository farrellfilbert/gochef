# Live Stripe + Uber Direct Integration

Klien sudah setuju untuk beralih dari **Test/Sandbox Mode** ke **Live/Production Mode** untuk Stripe Payment dan Uber Direct delivery — sehingga transaksi benar-benar diproses dan kurir Uber benar-benar dikirim.

---

## Checklist Sebelum Eksekusi

Sebelum menjalankan implementasi ini, pastikan semua item berikut sudah tersedia:

- [ ] **Stripe Live Secret Key** (`sk_live_...`) — dari Stripe Dashboard > Developers > API Keys
- [ ] **Stripe Live Publishable Key** (`pk_live_...`) — dari Stripe Dashboard
- [ ] **Stripe Webhook Secret** (`whsec_...`) — dari Stripe Dashboard > Webhooks (opsional tapi direkomendasikan)
- [ ] **Uber Direct Live Customer ID** — dari Uber Developer Dashboard (Production)
- [ ] **Uber Direct Live Client ID** — dari Uber Developer Dashboard (Production)
- [ ] **Uber Direct Live Client Secret** — dari Uber Developer Dashboard (Production)
- [ ] **Alamat fisik kitchen/pickup point** (format: `Street, City, State ZIP, Country`)
- [ ] Konfirmasi Uber Direct tersedia di area operasional

---

## Open Questions

1. **Stripe Live Keys**: Apakah Anda sudah punya `sk_live_...` dan `pk_live_...`? Jika ya, silakan berikan nilainya.
2. **Uber Direct Live Keys**: Apakah Uber Direct account sudah approved untuk production? Berikan `Client ID`, `Client Secret`, dan `Customer ID` yang baru untuk live.
3. **Alamat Pickup (Kitchen)**: Uber Direct memerlukan alamat pickup yang valid dan dalam jangkauan. Apa alamat fisik kitchen/restoran yang akan digunakan sebagai pickup point?
4. **Uber Direct availability**: Uber Direct hanya tersedia di kota-kota tertentu. Di kota/negara mana operasional ini berjalan?

---

## Proposed Changes

### Backend (`api/`)

#### [MODIFY] api/config.php
- Ganti `sk_test_...` → `sk_live_...` (Stripe Live Secret Key)
- Ganti `pk_test_...` → `pk_live_...` (Stripe Live Publishable Key)
- Isi `STRIPE_WEBHOOK_SECRET` dengan nilai dari Stripe Dashboard
- Ganti Uber credentials dengan Live/Production credentials
- Ubah `IS_TEST_MODE` dari `true` → `false`

#### [MODIFY] api/request_uber_delivery.php
- Hapus hardcode alamat San Francisco (yang sengaja dipasang untuk sandbox testing)
- Gunakan alamat nyata dari database kitchen sebagai pickup address
- Gunakan alamat nyata dari user sebagai dropoff address
- Tambahkan nama dan nomor telepon customer dari database

#### [MODIFY] api/uber_service.php
- Pastikan scope OAuth yang benar untuk Uber Direct production
- Pastikan URL endpoint Production (bukan Sandbox)

#### [MODIFY] api/verify_payment.php
- Setelah pembayaran berhasil dikonfirmasi, **otomatis trigger Uber delivery**
- Alur baru: Bayar → Verified → Uber otomatis dikirim → Status update

#### [MODIFY] api/pay.php
- Pastikan menggunakan `STRIPE_PUBLISHABLE_KEY` yang sudah diupdate (live key)

### Frontend

#### [MODIFY] lib/screens/checkout/
- Tidak ada perubahan signifikan — Flutter app hanya memanggil API yang sama

---

## Catatan Penting — Hal yang Perlu Diperbaiki Sebelum Go-Live

*(Tambahkan di sini hal-hal yang ingin diperbaiki sebelum eksekusi)*

- [ ] ...
- [ ] ...

---

## Verification Plan

### Setelah implementasi:
1. Lakukan test payment kecil ($1) dengan kartu asli di Stripe Live
2. Verifikasi order masuk ke database dengan status `Pending`
3. Verifikasi notifikasi diterima oleh user
4. Verifikasi Uber Direct courier dijadwalkan dan tracking URL aktif
5. Chef menerima order di Chef Dashboard

### Automated Tests
- `https://thegrubnextdoor.com/api/test_stripe_ping.php` — cek koneksi Stripe
- `https://thegrubnextdoor.com/api/test_uber.php` — cek koneksi Uber

---

## Summary

| Komponen | Status Sekarang | Setelah Implementasi |
|---|---|---|
| Stripe Payment | ✅ Working (Test Mode) | ✅ Working (Live — uang nyata) |
| Uber Delivery | ✅ Working (Sandbox — fake courier) | ✅ Working (Live — kurir nyata) |
| Auto-trigger Uber setelah bayar | ❌ Manual (chef harus panggil sendiri) | ✅ Otomatis setelah payment verified |
| Alamat Uber | Hardcode San Francisco | Alamat real dari database |
