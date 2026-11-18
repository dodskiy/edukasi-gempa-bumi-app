# PROPOSAL KONSEP & DOKUMENTASI PROYEK MOBILE APP

## **Judul Proyek:**
### **EDUKASI BENCANA GEMPA BUMI BERBASIS GAME INTERAKTIF BAGI SISWA DI WILAYAH RAWAN GEMPA MALUKU UTARA**
*(Nama Aplikasi: **SIGEMPA Malut - Siaga Gempa Maluku Utara**)*

---

## 1. Latar Belakang & Urgensi
Provinsi **Maluku Utara** merupakan salah satu kawasan dengan tingkat seismisitas tertinggi di Indonesia dan dunia. Wilayah ini berada pada pertemuan tiga lempeng tektonik utama (Lempeng Eurasia, Lempeng Pasifik, dan Lempeng Indo-Australia) serta dipengaruhi oleh keberadaan *Halmahera Trench*, *Sesar Mendatar Sorong-Maluku*, dan deretan gunung api aktif (seperti Gamalama di Ternate, Gamkonora di Halmahera Barat, dan Dukono di Halmahera Utara).

Sebagian besar korban bencana gempa bumi disebabkan oleh:
1. **Kurangnya kesiapsiagaan pra-bencana.**
2. **Kepanikan saat gempa terjadi.**
3. **Ketidaktahuan mengenai prosedur evakuasi mandiri.**

Siswa sekolah dasar dan menengah merupakan kelompok rentan sekaligus agen perubahan (*agent of change*) yang paling efektif. Melalui pendekatan **Gamifikasi Interaktif**, materi mitigasi gempa bumi yang biasanya membosankan atau menakutkan dapat dipelajari secara menyenangkan, mudah diingat, dan membentuk **refleks tanggap bencana**.

---

## 2. Tujuan Proyek
1. **Edukasi Kontekstual**: Memberikan pemahaman geologis sederhana mengenai alasan Maluku Utara sering dilanda gempa dan tsunami lokal.
2. **Pembentukan Refleks Cepat Tanggap**: Melatih respon fisik *"Drop, Cover, and Hold On"* (Merunduk, Berlindung, Bertahan) lewat mini-game reaksi cepat.
3. **Pemahaman Tas Siaga Bencana**: Melatih siswa menyiapkan dan memilih kebutuhan esensial saat keadaan darurat.
4. **Pusat Informasi & Kontak Darurat Lokal**: Menyediakan akses cepat ke BPBD Maluku Utara, Basarnas Malut, PMI, dan sirene alarm simulasi sekolah.

---

## 3. Sasaran Pengguna
- Siswa SD (Kelas 4–6), SMP, dan SMA/SMK di Maluku Utara.
- Guru dan staf sekolah sebagai media peraga simulasi gempa (*earthquake drill*).
- Masyarakat umum di kawasan rawan bencana Maluku Utara.

---

## 4. Arsitektur & Fitur Utama Aplikasi

### A. 📚 Modul Edukasi Interaktif (Materi & Ensiklopedia)
- **Zona Cincin Api Maluku Utara**: Karakteristik lempeng, sesar, dan gunung api Malut.
- **Pra-Gempa (Kesiapsiagaan)**: Penataan ruang kelas/kamar aman gempa dan Tas Siaga Bencana (TSB).
- **Saat Gempa (Tanggap Darurat)**: Prosedur *Drop, Cover, Hold On*, hindari kaca/jendela, jangan gunakan lift.
- **Pasca-Gempa (Evakuasi & Tsunami)**: Deteksi air laut surut tiba-tiba (gejala tsunami pantai Halmahera/Ternate) dan menuju titik kumpul (*assembly point*).

### B. 🎮 Mini-Game Interaktif
1. **Game 1: Simulasi Real-Life ("Gedung Runtuh & Evakuasi Gempa Malut")**
   - Simulasi animasi 2D interaktif: gedung sekolah bergoyang, dinding retak, dan puing berjatuhan (*earthquake shake & falling debris*).
   - Pemain memandu 4 siswa (Fandi Ternate, Siti Tidore, Aldi Halmahera, Nisa Morotai) menuju zona aman (Drop & Cover di bawah meja vs bahaya dekat jendela/kaca).
   - Dilanjutkan dengan evakuasi gedung lewat tangga darurat dan peringatan tsunami pesisir menuju dataran tinggi.
2. **Game 2: Simulasi Cepat Tanggap ("Drop, Cover, Hold On")**
   - Mini game reaksi cepat respon fisik dengan batas waktu detik.
3. **Game 3: Pack The Disaster Bag ("Tas Siaga Bencana")**
   - Game memilah 8 barang kebutuhan esensial untuk bertahan 72 jam pertama.

### C. 🏆 Kuis Pahlawan Siaga Gempa
- Kuis evaluasi pemahaman dengan timer dan sistem skor.
- Pemberian badge prestasi ("Pahlawan Siaga Maluku Utara", "Komandan Evakuasi", dll).

### D. 🚨 Pusat Darurat & Sirene Simulasi
- Tombol sirene darurat suara tinggi untuk simulasi sekolah (*drill*).
- Tombol panduan senter darurat (SOS Signal).
- Daftar kontak cepat BPBD Malut, Basarnas Ternate, PMI, dan Kepolisian.

---

## 5. Struktur Folder Proyek Flutter

```text
edukasi_gempa_malut/
├── pubspec.yaml
├── README.md
└── lib/
    ├── main.dart                       # Entry point aplikasi
    ├── theme/
    │   └── app_theme.dart              # Skema warna, typography, styling
    ├── models/
    │   ├── education_model.dart        # Model artikel edukasi
    │   ├── quiz_model.dart             # Model soal kuis & lencana
    │   ├── game_item_model.dart        # Model barang tas siaga & reaksi
    │   └── emergency_model.dart        # Model kontak darurat
    ├── data/
    │   ├── education_data.dart         # Database materi Maluku Utara
    │   ├── quiz_data.dart              # Database kuis mitigasi gempa
    │   ├── game_data.dart              # Data simulasi game
    │   └── emergency_data.dart         # Kontak BPBD, Basarnas, PMI Malut
    ├── widgets/
    │   ├── custom_button.dart          # Komponen tombol interaktif
    │   └── status_badge.dart           # Komponen badge & kartu animasi
    └── screens/
        ├── home_screen.dart            # Halaman utama & dashboard
        ├── education/
        │   ├── education_list_screen.dart    # Daftar topik edukasi
        │   └── education_detail_screen.dart  # Rincian materi edukasi
        ├── games/
        │   ├── game_hub_screen.dart          # Menu pilihan game
        │   ├── earthquake_simulation_game_screen.dart # Game simulasi real-life gedung runtuh
        │   ├── drop_cover_game_screen.dart   # Game respon cepat Drop-Cover
        │   └── safe_spot_game_screen.dart    # Game Misi Zona Aman (Detektif Gempa)
        ├── quiz/
        │   └── quiz_screen.dart              # Layar kuis interaktif
        └── emergency/
            └── emergency_screen.dart         # Sirene simulasi & kontak darurat
```

---

## 6. Cara Menjalankan Aplikasi
1. Pastikan Flutter SDK sudah terpasang di komputer (`flutter --version`).
2. Buka terminal pada folder proyek ini:
   ```bash
   flutter pub get
   flutter run
   ```
3. Pilih perangkat target (Emulator Android / iOS / Chrome Web / Windows Desktop).
