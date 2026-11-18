import 'package:flutter/material.dart';
import '../models/education_model.dart';

/// Materi modul untuk siswa sekolah dasar.
///
/// Setiap modul memakai kalimat pendek, paragraf kecil, dan contoh yang
/// dekat dengan kehidupan anak. Paragraf pada [EducationTopic.fullContent]
/// dipisahkan dengan baris kosong agar mudah dibaca di layar kecil.
class EducationData {
  static const List<EducationTopic> topics = [
    EducationTopic(
      id: 'malut_geology',
      title: 'Kenapa Maluku Utara Sering Gempa?',
      category: 'Kenali Daerahmu',
      shortDescription:
          'Maluku Utara berada di antara tiga lempeng bumi yang besar.',
      icon: Icons.public,
      color: Color(0xFF0284C7),
      keyPoints: [
        'Maluku Utara diapit tiga lempeng besar: Pasifik, Eurasia, dan Indo-Australia.',
        'Ketiga lempeng itu saling mendorong, sehingga batuan di bawah bumi bergeser.',
        'Di Maluku Utara ada banyak gunung berapi aktif, seperti Gamalama dan Dukono.',
        'Karena itu, gempa sering terasa di Ternate, Tidore, Morotai, dan Halmahera.',
      ],
      fullContent:
          'Bumi kita tersusun dari kepingan batu raksasa yang disebut lempeng. '
          'Lempeng bergerak sangat pelan, tetapi tenaganya besar.\n\n'
          'Maluku Utara berada di tempat tiga lempeng bertemu. Saat lempeng '
          'saling mendorong atau bergeser, tanah di atasnya ikut bergetar. '
          'Itulah yang kita rasakan sebagai gempa bumi.\n\n'
          'Gempa tidak bisa dihentikan. Tetapi kita bisa bersiap supaya '
          'tetap aman.',
      malukuUtaraContext:
          'Pulau Ternate, Tidore, Morotai, dan Halmahera sering merasakan '
          'gempa. Gempa di laut juga bisa membuat air laut naik. Karena itu, '
          'kita perlu tahu jalan ke tempat tinggi.',
      doAndDonts: [
        'PAHAMI: Gempa tidak bisa dicegah, tetapi kita bisa bersiap.',
        'KENALI: Jalan keluar dan tempat aman di sekolah serta di rumah.',
        'JANGAN: Percaya kabar palsu tentang tanggal gempa. Ikuti info BMKG.',
      ],
      remember:
          'Maluku Utara diapit tiga lempeng besar. Itu sebabnya gempa sering '
          'terjadi di sini.',
    ),
    EducationTopic(
      id: 'pra_gempa',
      title: 'Siap Sebelum Gempa',
      category: 'Ayo Bersiap',
      shortDescription:
          'Menyiapkan kelas, rumah, dan tas siaga sebelum gempa datang.',
      icon: Icons.home_repair_service,
      color: Color(0xFF10B981),
      keyPoints: [
        'Kaitkan lemari dan rak buku ke dinding agar tidak tumbang.',
        'Taruh barang berat di rak paling bawah.',
        'Siapkan tas siaga berisi air, makanan, senter, dan obat-obatan.',
        'Sepakati tempat kumpul keluarga di halaman terbuka.',
      ],
      fullContent: 'Persiapan membuat kita lebih tenang saat gempa datang.\n\n'
          'Di kelas, perhatikan denah jalan keluar. Ikuti latihan gempa '
          'bersama guru. Di rumah, bereskan barang yang mudah jatuh.\n\n'
          'Jangan lupa menyimpan nomor penting, seperti BPBD dan Basarnas. '
          'Minta bantuan orang dewasa untuk mencatatnya.',
      malukuUtaraContext:
          'Banyak sekolah dan rumah di Maluku Utara berada di dekat bukit '
          'atau pantai. Pastikan jalan menuju tempat aman tidak terhalang '
          'pohon tumbang atau tebing.',
      doAndDonts: [
        'LAKUKAN: Periksa kabel listrik dan tabung gas bersama orang dewasa.',
        'LAKUKAN: Simpan nomor darurat di buku atau ponsel keluarga.',
        'JANGAN: Menggantung cermin berat di atas tempat tidur.',
      ],
      remember: 'Tas siaga, jalan keluar, dan tempat kumpul membuat kita siap '
          'sebelum gempa.',
    ),
    EducationTopic(
      id: 'saat_gempa',
      title: 'Saat Gempa: Drop, Cover, Hold On',
      category: 'Langkah Cepat',
      shortDescription: 'Merunduk, berlindung, lalu berpegangan erat.',
      icon: Icons.security,
      color: Color(0xFFF59E0B),
      keyPoints: [
        'DROP: merunduk ke lantai dan lindungi kepala.',
        'COVER: berlindung di bawah meja yang kuat.',
        'HOLD ON: pegang kaki meja sampai gempa berhenti.',
        'Jauhi jendela kaca, lemari tinggi, dan benda yang mudah jatuh.',
      ],
      fullContent:
          'Saat gempa, tanah bergoyang dan kita sulit berlari. Jangan mencoba '
          'lari ke luar selama getaran masih terasa.\n\n'
          'Merunduklah dulu. Lalu cari meja yang kuat untuk berlindung. '
          'Pegang kaki meja erat-erat sampai getaran berhenti.\n\n'
          'Kalau tidak ada meja, merunduklah di dekat dinding yang kuat dan '
          'lindungi kepala dengan kedua tangan atau tas.',
      malukuUtaraContext:
          'Kalau kamu sedang di pantai Maluku Utara dan gempa terasa kuat, '
          'segera naik ke tempat tinggi. Jangan menunggu bunyi sirine.',
      doAndDonts: [
        'LAKUKAN: Lindungi kepala dengan tas atau kedua tangan.',
        'JANGAN: Memakai lift saat gempa.',
        'JANGAN: Mendorong teman di pintu keluar.',
      ],
      remember: 'Urutannya selalu DROP, lalu COVER, lalu HOLD ON.',
    ),
    EducationTopic(
      id: 'pasca_gempa',
      title: 'Setelah Gempa: Keluar dengan Aman',
      category: 'Ayo Evakuasi',
      shortDescription: 'Keluar dengan tertib dan waspada gempa susulan.',
      icon: Icons.run_circle,
      color: Color(0xFFEF4444),
      keyPoints: [
        'Keluar dengan tertib setelah getaran berhenti.',
        'Pergi ke titik kumpul di halaman terbuka.',
        'Waspadai gempa susulan.',
        'Ikuti arahan guru atau orang dewasa.',
      ],
      fullContent:
          'Setelah gempa berhenti, jangan langsung masuk kembali ke gedung. '
          'Bangunan bisa retak dan berbahaya.\n\n'
          'Keluar dengan tenang. Jangan berlari atau berebutan. Pergi ke '
          'titik kumpul agar guru bisa menghitung siswa.\n\n'
          'Jika ada gempa susulan, lakukan lagi Drop, Cover, Hold On.',
      malukuUtaraContext:
          'Di Maluku Utara, gempa kuat bisa diikuti tsunami. Jika air laut '
          'surut tiba-tiba atau terdengar suara keras dari laut, segera '
          'pergi ke bukit terdekat.',
      doAndDonts: [
        'LAKUKAN: Pakai alas kaki agar kaki aman dari pecahan kaca.',
        'LAKUKAN: Tetap di titik kumpul sampai guru bilang aman.',
        'JANGAN: Menyalakan api jika tercium bau gas.',
      ],
      remember:
          'Setelah gempa, keluar tertib ke titik kumpul dan tunggu arahan '
          'guru.',
    ),
  ];
}
