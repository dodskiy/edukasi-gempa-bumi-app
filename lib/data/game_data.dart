import 'package:flutter/material.dart';
import '../models/game_item_model.dart';

class GameData {
  // Data Mini Game 1: Simulasi Drop, Cover, Hold On
  static const List<DropCoverScenario> dropCoverScenarios = [
    DropCoverScenario(
      id: 'sc1',
      location: 'Ruang Kelas (Sekolah)',
      situation:
          'Alarm gempa berbunyi keras! Lampu kelas bergoyang kencang dan dinding bergetar. Apa tindakan tercepatmu?',
      imagePlaceholderText: '🏫 Kelas Sekolah Goyang!',
      actions: [
        ScenarioAction(
          actionText:
              'Segera merunduk di bawah meja kokoh, pegang kaki meja, dan tutupi kepala dengan tas.',
          isCorrect: true,
          feedback:
              'Tepat sekali! Drop, Cover, Hold On melindungi kepala dan badan dari reruntuhan.',
          icon: Icons.shield,
        ),
        ScenarioAction(
          actionText:
              'Berlari kencang ke dekat jendela kaca untuk melihat ke luar gedung.',
          isCorrect: false,
          feedback:
              'Bahaya! Kaca jendela bisa pecah berkeping-keping dan melukaimu.',
          icon: Icons.window,
        ),
        ScenarioAction(
          actionText: 'Berdiri di atas kursi sambil berteriak histeris.',
          isCorrect: false,
          feedback:
              'Salah! Kamu bisa terjatuh dan tertimpa benda berat yang jatuh.',
          icon: Icons.warning_amber_rounded,
        ),
      ],
    ),
    DropCoverScenario(
      id: 'sc2',
      location: 'Kamar Tidur (Rumah)',
      situation:
          'Tengah malam terasa gempa darat bergoncang kuat di Pulau Ternate saat kamu di tempat tidur.',
      imagePlaceholderText: '🛏️ Kamar Tidur Bergetar!',
      actions: [
        ScenarioAction(
          actionText:
              'Tengkurap di tempat tidur, lindungi kepala dan wajah dengan bantal tebal.',
          isCorrect: true,
          feedback:
              'Hebat! Bantal berfungsi sebagai pelindung kepala dari pecahan kaca atau plester atap yang rontok.',
          icon: Icons.bed,
        ),
        ScenarioAction(
          actionText:
              'Berdiri di dekat lemari kaca besar dan mencoba menahannya agar tidak jatuh.',
          isCorrect: false,
          feedback: 'Sangat berbahaya! Lemari berat bisa roboh menimpamu.',
          icon: Icons.kitchen,
        ),
        ScenarioAction(
          actionText: 'Menyalakan korek api untuk memeriksa sekeliling.',
          isCorrect: false,
          feedback:
              'Bahaya! Jika ada pipa gas retak atau bocor, nyala api bisa memicu kebakaran.',
          icon: Icons.local_fire_department,
        ),
      ],
    ),
    DropCoverScenario(
      id: 'sc3',
      location: 'Pusat Perbelanjaan / Mall di Maluku Utara',
      situation:
          'Kamu sedang berada di lantai 3 pusat perbelanjaan saat sirine gempa berdering!',
      imagePlaceholderText: '🏬 Mall Bergetar!',
      actions: [
        ScenarioAction(
          actionText: 'Segera berlari menuju lift untuk turun secepatnya.',
          isCorrect: false,
          feedback:
              'Jangan pernah gunakan lift saat gempa! Listrik bisa padam dan membuatmu terjebak di dalam.',
          icon: Icons.elevator,
        ),
        ScenarioAction(
          actionText:
              'Merunduk di samping pilar beton kokoh, jauhi rak barang kaca dan lampu gantung.',
          isCorrect: true,
          feedback:
              'Bagus sekali! Menjauhi rak pajangan dan berada dekat struktur kuat meminimalisir risiko cedera.',
          icon: Icons.domain,
        ),
        ScenarioAction(
          actionText:
              'Berebut menaiki tangga berjalan (eskalator) yang sedang mati.',
          isCorrect: false,
          feedback:
              'Salah! Eskalator licin dan kepanikan massal bisa menimbulkan desak-desakan maut.',
          icon: Icons.escalator,
        ),
      ],
    ),
  ];

  // Data Mini Game 2: Pack Your Disaster Bag (Tas Siaga Bencana)
  static const List<DisasterBagItem> allBagItems = [
    DisasterBagItem(
      id: 'b1',
      name: 'Air Mineral (1.5L)',
      category: 'Kebutuhan Pokok',
      emoji: '💧',
      isEssential: true,
      reason: 'Sangat krusial untuk mencegah dehidrasi selama masa evakuasi.',
    ),
    DisasterBagItem(
      id: 'b2',
      name: 'Kotak P3K & Obat Pribadi',
      category: 'Kesehatan',
      emoji: '🩹',
      isEssential: true,
      reason: 'Untuk pertolongan pertama luka lecet/cedera darurat.',
    ),
    DisasterBagItem(
      id: 'b3',
      name: 'Senter & Baterai Cadangan',
      category: 'Penerangan',
      emoji: '🔦',
      isEssential: true,
      reason: 'Membantu navigasi saat listrik padam di malam hari.',
    ),
    DisasterBagItem(
      id: 'b4',
      name: 'Peluit Darurat',
      category: 'Sinyal SAR',
      emoji: '📢',
      isEssential: true,
      reason:
          'Memberikan sinyal suara kepada tim evakuasi tanpa menghabiskan suara.',
    ),
    DisasterBagItem(
      id: 'b5',
      name: 'Makanan Tahan Lama (Biskuit/Roti)',
      category: 'Kebutuhan Pokok',
      emoji: '🍞',
      isEssential: true,
      reason: 'Sumber kalori cepat tanpa perlu dimasak dalam 72 jam.',
    ),
    DisasterBagItem(
      id: 'b6',
      name: 'Dokumen Penting (Plastik Anti Air)',
      category: 'Administrasi',
      emoji: '📁',
      isEssential: true,
      reason: 'Fotokopi KK, Akta, Rapor, Ijazah yang terbungkus rapat.',
    ),
    DisasterBagItem(
      id: 'b7',
      name: 'PlayStation / Game Console',
      category: 'Hiburan',
      emoji: '🎮',
      isEssential: false,
      reason: 'Tidak esensial, berat, dan memakan ruang evakuasi penting.',
    ),
    DisasterBagItem(
      id: 'b8',
      name: 'Bantal Guling Besar',
      category: 'Tidur',
      emoji: '🛌',
      isEssential: false,
      reason: 'Terlalu besar dan menyulitkan pergerakan evakuasi cepat.',
    ),
    DisasterBagItem(
      id: 'b9',
      name: 'Pakaian Ganti & Selimut Tipis',
      category: 'Pakaian',
      emoji: '👕',
      isEssential: true,
      reason: 'Menjaga suhu tubuh agar tidak kedinginan di posko pengungsian.',
    ),
    DisasterBagItem(
      id: 'b10',
      name: 'Radio Portabel / Baterai',
      category: 'Informasi',
      emoji: '📻',
      isEssential: true,
      reason: 'Mendengar arahan resmi BMKG/BPBD saat sinyal internet lumpuh.',
    ),
    DisasterBagItem(
      id: 'b11',
      name: 'Boneka Beruang Raksasa',
      category: 'Mainan',
      emoji: '🧸',
      isEssential: false,
      reason: 'Bukan prioritas bertahan hidup dan memperberat tas siaga.',
    ),
    DisasterBagItem(
      id: 'b12',
      name: 'Alat Masker & Hand Sanitizer',
      category: 'Kebersihan',
      emoji: '😷',
      isEssential: true,
      reason:
          'Melindungi pernapasan dari debu reruntuhan bangunan atau abu vulkanik.',
    ),
  ];
}
