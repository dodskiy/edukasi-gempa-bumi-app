import '../models/quiz_model.dart';

/// Dua belas soal Kuis Siaga Gempa untuk siswa sekolah dasar.
///
/// Sebaran materi:
/// - Pengertian gempa: 1 soal
/// - Penyebab gempa: 3 soal
/// - Dampak gempa: 1 soal
/// - Langkah sebelum gempa: 1 soal
/// - Langkah saat gempa (Drop, Cover, Hold On): 5 soal
/// - Langkah setelah gempa dan evakuasi: 1 soal
///
/// Setiap soal memakai satu kalimat pendek, tiga pilihan singkat, dan
/// penjelasan dengan kata sehari-hari.
class QuizData {
  static const List<QuizQuestion> questions = [
    // ---------- Pengertian gempa ----------
    QuizQuestion(
      id: 'q1',
      question: 'Apa itu gempa bumi?',
      options: [
        'Hujan deras yang turun terus',
        'Tanah terasa bergetar atau bergoyang',
        'Angin kencang yang berputar',
      ],
      correctOptionIndex: 1,
      explanation:
          'Gempa bumi adalah getaran di permukaan bumi. Tanah terasa bergoyang karena batuan di dalam bumi bergerak.',
      hint: 'Ciri gempa: tanah dan benda di sekitar kita ikut bergoyang.',
    ),

    // ---------- Penyebab gempa ----------
    QuizQuestion(
      id: 'q2',
      question: 'Kenapa gempa bumi bisa terjadi?',
      options: [
        'Karena batuan besar di dalam bumi bergeser',
        'Karena matahari terlalu panas',
        'Karena banyak orang melompat bersama',
      ],
      correctOptionIndex: 0,
      explanation:
          'Di dalam bumi ada lempeng, yaitu kepingan batu raksasa. Saat lempeng bergeser atau bertabrakan, tanah di atasnya bergetar.',
      hint:
          'Bayangkan bumi seperti kepingan puzzle raksasa yang bisa bergeser.',
    ),
    QuizQuestion(
      id: 'q3',
      question:
          'Gempa yang terjadi karena gunung berapi aktif disebut gempa...',
      options: [
        'Vulkanik',
        'Tektonik',
        'Buatan',
      ],
      correctOptionIndex: 0,
      explanation:
          'Gempa vulkanik terjadi karena kegiatan gunung berapi, misalnya ketika magma bergerak di dalam gunung.',
      hint: 'Kata "vulkanik" berhubungan dengan gunung api.',
    ),
    QuizQuestion(
      id: 'q4',
      question:
          'Gempa yang paling sering terjadi karena lempeng bumi bergeser disebut gempa...',
      options: [
        'Tektonik',
        'Vulkanik',
        'Runtuhan',
      ],
      correctOptionIndex: 0,
      explanation:
          'Gempa tektonik paling sering terjadi. Penyebabnya, lempeng bumi bergeser dan saling menekan.',
      hint: 'Jenis gempa ini paling sering diberitakan di televisi.',
    ),

    // ---------- Dampak gempa ----------
    QuizQuestion(
      id: 'q5',
      question: 'Apa dampak yang bisa terjadi saat gempa bumi?',
      options: [
        'Bangunan bisa retak atau roboh',
        'Bunga tumbuh lebih cepat',
        'Air hujan berubah menjadi manis',
      ],
      correctOptionIndex: 0,
      explanation:
          'Gempa kuat bisa merusak bangunan, jalan, dan jembatan. Di dekat pantai, gempa juga bisa memicu tsunami.',
      hint: 'Ingat benda-benda yang bisa rusak saat tanah bergoyang.',
    ),

    // ---------- Langkah sebelum gempa ----------
    QuizQuestion(
      id: 'q6',
      question: 'Apa yang sebaiknya kita siapkan sebelum gempa?',
      options: [
        'Tas siaga berisi air, makanan, dan senter',
        'Layang-layang untuk bermain',
        'Banyak mainan di lantai',
      ],
      correctOptionIndex: 0,
      explanation:
          'Tas siaga membantu kita saat darurat. Isinya air, makanan, senter, obat-obatan, dan peluit.',
      hint: 'Siapkan tas berisi barang penting untuk keadaan darurat.',
    ),

    // ---------- Langkah saat gempa ----------
    QuizQuestion(
      id: 'q7',
      question: 'Saat gempa, DROP artinya kita harus...',
      options: [
        'Berdiri tegak',
        'Merunduk ke lantai',
        'Berlari cepat',
      ],
      correctOptionIndex: 1,
      explanation:
          'DROP berarti merunduk. Badan kita jadi rendah, sehingga tidak mudah jatuh saat tanah bergoyang.',
      hint: 'DROP dalam bahasa Inggris berarti menjatuhkan badan.',
    ),
    QuizQuestion(
      id: 'q8',
      question: 'Setelah merunduk, COVER artinya kita harus...',
      options: [
        'Berlindung di bawah meja yang kuat',
        'Berdiri dekat jendela kaca',
        'Naik ke atas kursi',
      ],
      correctOptionIndex: 0,
      explanation:
          'COVER berarti berlindung. Masuklah ke bawah meja yang kuat agar kepala dan badan terlindungi.',
      hint: 'COVER artinya menutupi atau melindungi diri.',
    ),
    QuizQuestion(
      id: 'q9',
      question: 'Langkah terakhir, HOLD ON, artinya kita harus...',
      options: [
        'Melepas pegangan lalu berdiri',
        'Bermain gawai sambil menunggu',
        'Berpegangan pada kaki meja sampai gempa berhenti',
      ],
      correctOptionIndex: 2,
      explanation:
          'HOLD ON berarti berpegangan erat. Pegang kaki meja dan tunggu sampai getaran benar-benar berhenti.',
      hint: 'HOLD ON artinya bertahan dan berpegangan erat.',
    ),
    QuizQuestion(
      id: 'q10',
      question: 'Apa urutan yang benar saat gempa?',
      options: [
        'Cover, Hold On, Drop',
        'Drop, Cover, Hold On',
        'Hold On, Drop, Cover',
      ],
      correctOptionIndex: 1,
      explanation:
          'Urutannya: DROP dulu (merunduk), lalu COVER (berlindung), lalu HOLD ON (berpegangan).',
      hint: 'Merunduk dulu, baru mencari tempat berlindung.',
    ),
    QuizQuestion(
      id: 'q11',
      question:
          'Gempa terjadi saat kamu belajar di kelas. Apa yang kamu lakukan?',
      options: [
        'Berlari berebutan ke pintu',
        'Merunduk di bawah meja dan berpegangan',
        'Berdiri di dekat jendela',
      ],
      correctOptionIndex: 1,
      explanation:
          'Di kelas, segera merunduk, berlindung di bawah meja, lalu berpegangan sampai getaran berhenti.',
      hint: 'Gunakan tiga langkah: Drop, Cover, Hold On.',
    ),

    // ---------- Langkah setelah gempa ----------
    QuizQuestion(
      id: 'q12',
      question: 'Setelah gempa berhenti, apa yang sebaiknya kamu lakukan?',
      options: [
        'Tetap tenang, lalu keluar dengan tertib mengikuti guru',
        'Berebutan keluar kelas',
        'Kembali bermain di dalam kelas',
      ],
      correctOptionIndex: 0,
      explanation:
          'Tetap tenang dan keluar dengan tertib mengikuti guru. Bisa saja ada gempa susulan.',
      hint: 'Jangan panik dan jangan berebutan. Ikuti arahan orang dewasa.',
    ),
  ];

  static const List<QuizBadge> badges = [
    QuizBadge(
      title: 'Pahlawan Siaga Gempa',
      description:
          'Hebat! Kamu sudah paham cara menyelamatkan diri saat gempa.',
      iconEmoji: '',
      minScore: 80,
    ),
    QuizBadge(
      title: 'Ksatria Tanggap Bencana',
      description: 'Bagus! Sedikit lagi kamu jadi pahlawan siaga gempa.',
      iconEmoji: '',
      minScore: 60,
    ),
    QuizBadge(
      title: 'Pemula Siap Belajar',
      description:
          'Ayo baca modul lagi, lalu coba kuis sekali lagi. Kamu pasti bisa!',
      iconEmoji: '',
      minScore: 0,
    ),
  ];
}
