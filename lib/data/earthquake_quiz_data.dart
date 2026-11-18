import '../models/quiz_model.dart';

/// Bank soal Pre-Test dan Post-Test untuk game simulasi gempa.
///
/// Soal pre-test dan post-test dibuat paralel: konsepnya sama, tetapi
/// kalimat dan susunan pilihannya berbeda. Dengan begitu, kenaikan skor
/// benar-benar menunjukkan pemahaman, bukan hafalan urutan jawaban.
///
/// Enam materi yang diuji:
/// 1. Pengertian gempa
/// 2. Penyebab gempa
/// 3. Dampak gempa
/// 4. Langkah sebelum gempa
/// 5. Langkah saat gempa (Drop, Cover, Hold On)
/// 6. Langkah setelah gempa
///
/// Setiap soal hanya punya tiga pilihan singkat agar mudah dibaca
/// siswa sekolah dasar.
class EarthquakeQuizData {
  const EarthquakeQuizData._();

  static const List<QuizQuestion> preTest = [
    // ---------- Pengertian gempa ----------
    QuizQuestion(
      id: 'pre_1',
      question: 'Gempa bumi adalah...',
      options: [
        'Getaran yang terasa di permukaan bumi',
        'Hujan yang turun sangat deras',
        'Angin yang berputar kencang',
      ],
      correctOptionIndex: 0,
      explanation:
          'Gempa bumi membuat tanah dan benda di sekitar kita bergetar atau bergoyang.',
      hint: 'Ciri gempa: tanah terasa bergoyang.',
    ),

    // ---------- Penyebab gempa ----------
    QuizQuestion(
      id: 'pre_2',
      question: 'Penyebab gempa bumi yang paling sering adalah...',
      options: [
        'Lempeng bumi bergeser',
        'Pohon tumbang',
        'Matahari terbenam',
      ],
      correctOptionIndex: 0,
      explanation:
          'Lempeng bumi adalah kepingan batu raksasa. Saat bergeser, tanah di atasnya ikut bergetar.',
      hint: 'Bayangkan kepingan puzzle raksasa di dalam bumi.',
    ),

    // ---------- Dampak gempa ----------
    QuizQuestion(
      id: 'pre_3',
      question: 'Apa dampak gempa bumi yang kuat?',
      options: [
        'Bangunan bisa retak atau roboh',
        'Bunga tumbuh lebih cepat',
        'Air hujan berubah menjadi manis',
      ],
      correctOptionIndex: 0,
      explanation:
          'Gempa kuat bisa merusak bangunan dan jalan. Di dekat pantai, gempa juga bisa memicu tsunami.',
      hint: 'Ingat benda-benda yang bisa rusak saat tanah bergoyang.',
    ),

    // ---------- Langkah sebelum gempa ----------
    QuizQuestion(
      id: 'pre_4',
      question: 'Apa yang perlu kita siapkan sebelum gempa?',
      options: [
        'Tas siaga berisi air dan senter',
        'Layang-layang besar',
        'Banyak mainan di lantai',
      ],
      correctOptionIndex: 0,
      explanation:
          'Tas siaga berisi air, makanan, senter, dan obat-obatan untuk keadaan darurat.',
      hint: 'Siapkan tas berisi barang penting.',
    ),

    // ---------- Langkah saat gempa ----------
    QuizQuestion(
      id: 'pre_5',
      question: 'Saat gempa, DROP artinya kita...',
      options: [
        'Merunduk ke lantai',
        'Berdiri tegak',
        'Berlari cepat',
      ],
      correctOptionIndex: 0,
      explanation:
          'DROP berarti merunduk. Badan yang rendah tidak mudah jatuh saat tanah bergoyang.',
      hint: 'DROP artinya menjatuhkan badan ke bawah.',
    ),

    // ---------- Langkah setelah gempa ----------
    QuizQuestion(
      id: 'pre_6',
      question: 'Setelah gempa berhenti, kita sebaiknya...',
      options: [
        'Keluar dengan tertib mengikuti guru',
        'Berebutan ke pintu',
        'Kembali bermain di kelas',
      ],
      correctOptionIndex: 0,
      explanation:
          'Tetap tenang dan keluar dengan tertib. Bisa saja ada gempa susulan.',
      hint: 'Jangan panik dan jangan berebutan.',
    ),
  ];

  static const List<QuizQuestion> postTest = [
    // ---------- Pengertian gempa ----------
    QuizQuestion(
      id: 'post_1',
      question: 'Tanah terasa bergoyang. Itu tanda...',
      options: [
        'Sedang terjadi gempa bumi',
        'Hujan akan segera turun',
        'Matahari sedang terbit',
      ],
      correctOptionIndex: 0,
      explanation:
          'Gempa bumi adalah getaran di permukaan bumi. Tanah dan benda di sekitar ikut bergoyang.',
      hint: 'Getaran tanah adalah ciri gempa bumi.',
    ),

    // ---------- Penyebab gempa ----------
    QuizQuestion(
      id: 'post_2',
      question: 'Gempa bumi paling sering terjadi karena...',
      options: [
        'Banyak orang melompat bersama',
        'Lempeng bumi bergeser',
        'Angin kencang bertiup',
      ],
      correctOptionIndex: 1,
      explanation:
          'Lempeng bumi bergeser dan saling menekan. Getarannya terasa sampai ke permukaan.',
      hint: 'Penyebabnya ada di dalam bumi, bukan di udara.',
    ),

    // ---------- Dampak gempa ----------
    QuizQuestion(
      id: 'post_3',
      question: 'Saat gempa kuat, benda yang bisa rusak adalah...',
      options: [
        'Buku di dalam tas',
        'Baju di dalam lemari',
        'Bangunan dan jalan',
      ],
      correctOptionIndex: 2,
      explanation:
          'Gempa kuat bisa membuat bangunan retak atau roboh. Jalan dan jembatan juga bisa rusak.',
      hint: 'Pilih benda besar yang berdiri di atas tanah.',
    ),

    // ---------- Langkah sebelum gempa ----------
    QuizQuestion(
      id: 'post_4',
      question: 'Barang penting yang dimasukkan ke tas siaga adalah...',
      options: [
        'Layang-layang',
        'Air minum dan senter',
        'Mainan besar',
      ],
      correctOptionIndex: 1,
      explanation:
          'Tas siaga berisi air minum, makanan, senter, obat-obatan, dan peluit.',
      hint: 'Barangnya berguna saat lampu mati atau kita haus.',
    ),

    // ---------- Langkah saat gempa ----------
    QuizQuestion(
      id: 'post_5',
      question: 'Urutan langkah aman saat gempa adalah...',
      options: [
        'Cover, Hold On, Drop',
        'Hold On, Drop, Cover',
        'Drop, Cover, Hold On',
      ],
      correctOptionIndex: 2,
      explanation:
          'Mulai dari DROP (merunduk), lalu COVER (berlindung), lalu HOLD ON (berpegangan).',
      hint: 'Merunduk dulu, baru berlindung, lalu berpegangan.',
    ),

    // ---------- Langkah setelah gempa ----------
    QuizQuestion(
      id: 'post_6',
      question: 'Setelah getaran berhenti, kita keluar kelas dengan...',
      options: [
        'Berebutan dan berlari',
        'Tertib mengikuti guru',
        'Mendorong teman',
      ],
      correctOptionIndex: 1,
      explanation:
          'Keluar dengan tertib dan ikuti arahan guru. Jangan berlari atau berebutan.',
      hint: 'Tenang dan ikuti orang dewasa.',
    ),
  ];
}
