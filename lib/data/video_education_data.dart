import '../models/video_education_model.dart';

class VideoEducationData {
  static const List<VideoEducationModel> videos = [
    VideoEducationModel(
      id: 'apa_itu_gempa',
      youtubeId: '1nXkJq5OZl0',
      youtubeUrl: 'https://youtu.be/1nXkJq5OZl0?si=ajEOY62DoSnzHceD',
      title: 'Apasih Gempa Bumi Itu?',
      category: 'Sains Dasar Gempa',
      duration: '04:12',
      shortDescription:
          'Memahami bagaimana kerak bumi bergerak dan pelepasan energi gelombang seismik.',
      fullSummary:
          'Video animasi interaktif yang menjelaskan lapisan struktur bumi, pergerakan lempeng tektonik, titik hiposenter (pusat gempa di dalam bumi), dan episenter (titik di permukaan bumi). Sangat cocok untuk mengawali pemahaman dasar sebelum mempelajari mitigasi gempa.',
      learningPoints: [
        'Bumi tersusun dari lapisan kerak, mantel, dan inti.',
        'Lempeng tektonik bergerak secara konvergen, divergen, dan sesar geser.',
        'Gempa terjadi ketika batuan di bawah tanah tiba-tiba patah akibat tekanan lempeng.',
        'Energi getaran merambat ke segala arah melalui gelombang seismik.',
      ],
    ),
    VideoEducationModel(
      id: 'jenis_jenis_gempa',
      youtubeId: 'oRxj1ATzDYs',
      youtubeUrl: 'https://youtu.be/oRxj1ATzDYs?si=cYX9C9D3yCNqci9i',
      title: 'Mengenal Jenis-Jenis Gempa Bumi',
      category: 'Klasifikasi Ilmiah',
      duration: '05:30',
      shortDescription:
          'Perbedaan gempa tektonik, gempa vulkanik gunung api, dan gempa runtuhan.',
      fullSummary:
          'Video ini mengupas tuntas klasifikasi gempa berdasarkan penyebabnya. Penjelasan mencakup gempa tektonik (paling sering dan berdaya rusak tinggi), gempa vulkanik (aktivitas magma gunung berapi aktif seperti di Maluku Utara), serta gempa runtuhan (terban).',
      learningPoints: [
        'Gempa Tektonik: Disebabkan oleh pergeseran lempeng litosfer bumi.',
        'Gempa Vulkanik: Terjadi akibat pergerakan magma sebelum atau saat gunung api meletus.',
        'Gempa Terban/Runtuhan: Runtuhnya gua kapur atau terowongan tambang bawah tanah.',
        'Karakteristik gempa di Indonesia khususnya Maluku Utara yang kaya gunung api aktif.',
      ],
    ),
    VideoEducationModel(
      id: 'edukasi_gempa_bumi',
      youtubeId: 'O6GjGUWmRmc',
      youtubeUrl: 'https://youtu.be/O6GjGUWmRmc?si=TQY40OJWM-FphjXc',
      title: 'Penjelasan & Edukasi Gempa Bumi',
      category: 'Edukasi Bencana',
      duration: '06:45',
      shortDescription:
          'Pengenalan dampak gempa, skala kekuatan gempa (Richter/MMI), dan kesiapsiagaan.',
      fullSummary:
          'Panduan komprehensif seputar bahaya yang ditimbulkan oleh gempa bumi, cara membaca informasi gempa dari BMKG, serta pentingnya mengenali lingkungan tempat tinggal kita agar selalu siap siaga jika sewaktu-waktu getaran terjadi.',
      learningPoints: [
        'Pengukuran kekuatan gempa dengan Magnitudo dan intensitas MMI.',
        'Bahaya sekunder gempa bumi: likuifaksi, tanah longsor, dan tsunami.',
        'Pentingnya jalur evakuasi sekolah dan rumah yang tidak terhalang barang.',
        'Mencari informasi akurat dari BMKG dan tidak termakan isu hoaks.',
      ],
    ),
    VideoEducationModel(
      id: 'drop_cover_hold_on',
      youtubeId: 'aV89_yUJunM',
      youtubeUrl: 'https://youtu.be/aV89_yUJunM?si=I0KalaXp58J0ycFm',
      title: 'Edukasi Drop, Cover, Hold On!',
      category: 'Aksi Penyelamatan',
      duration: '03:50',
      shortDescription:
          'Langkah praktis merunduk, berlindung di bawah meja kokoh, dan berpegangan erat.',
      fullSummary:
          'Panduan video visual tata cara penyelamatan diri standar internasional saat gempa terjadi di dalam ruangan. Menunjukkan posisi tubuh yang benar, cara melindungi kepala dan leher, serta kapan waktu yang aman untuk mulai keluar gedung menuju titik kumpul.',
      learningPoints: [
        'DROP: Segera jatuhkan lutut ke lantai sebelum terpelanting guncangan.',
        'COVER: Lindungi kepala dan leher di bawah meja kokoh.',
        'HOLD ON: Pegang kaki meja erat-erat hingga getaran gempa berhenti.',
        'Hindari jendela kaca, kaca gantung, dan lemari yang berisiko roboh.',
      ],
    ),
  ];
}
