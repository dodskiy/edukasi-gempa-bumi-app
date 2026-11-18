import 'package:flutter/material.dart';

/// Layar materi edukasi gempa bumi untuk anak SD.
/// Berisi 3 bagian materi dalam bentuk kartu-kartu yang bisa di-scroll
/// (seperti slide): Apa itu Gempa Bumi, Kesiapsiagaan Gempa, dan
/// Drop, Cover, Hold On.
///
/// Layar ini murni penambahan baru — tidak mengubah GameHubScreen atau
/// QuizScreen yang sudah ada. Cukup panggil dengan:
///
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => const EarthquakeMaterialScreen(),
/// ));
class EarthquakeMaterialScreen extends StatefulWidget {
  const EarthquakeMaterialScreen({super.key});

  @override
  State<EarthquakeMaterialScreen> createState() =>
      _EarthquakeMaterialScreenState();
}

class _EarthquakeMaterialScreenState extends State<EarthquakeMaterialScreen> {
  // ---------------- Palet Warna - Selaras dengan Arena Game & Kuis ----------------
  static const Color cream = Color(0xFFFFF8EC);
  static const Color navy = Color(0xFF2B3A55);
  static const Color inkSoft = Color(0xFF6B7A99);

  static const Color coral = Color(0xFFFF7A6B);
  static const Color coralDeep = Color(0xFFFF5A48);
  static const Color sky = Color(0xFF4FC3F7);
  static const Color skyDeep = Color(0xFF29B6F6);
  static const Color gold = Color(0xFFFFC845);
  static const Color goldDeep = Color(0xFFFFA726);
  static const Color green = Color(0xFF66BB6A);
  static const Color greenDeep = Color(0xFF43A047);
  static const Color purple = Color(0xFF9B7BD8);
  static const Color purpleDeep = Color(0xFF7048C4);

  static const Color cardLine = Color(0xFFF1EEE4);

  int _currentSection = 0;

  final List<_MaterialSection> _sections = const [
    _MaterialSection(
      emoji: '🌍',
      label: 'Apa itu Gempa?',
      color: sky,
      colorDeep: skyDeep,
    ),
    _MaterialSection(
      emoji: '🎒',
      label: 'Siaga Gempa',
      color: green,
      colorDeep: greenDeep,
    ),
    _MaterialSection(
      emoji: '🛡️',
      label: 'Drop, Cover, Hold On',
      color: coral,
      colorDeep: coralDeep,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purple.withOpacity(0.15),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: cream,
            child: Column(
              children: [
                _buildHeader(),
                _buildTabSelector(),
                Expanded(
                  child: IndexedStack(
                    index: _currentSection,
                    children: [
                      _buildApaItuGempaSection(),
                      _buildSiagaGempaSection(),
                      _buildDropCoverHoldSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [purple, purpleDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
              color: Color(0x337048C4), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withOpacity(0.5), width: 2.5),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '📚 Buku Saku Siaga Gempa',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2))],
              ),
            ),
          ),
          const Text('🦸', style: TextStyle(fontSize: 30)),
        ],
      ),
    );
  }

  // ================= TAB SELECTOR =================
  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: List.generate(_sections.length, (i) {
          final section = _sections[i];
          final isActive = _currentSection == i;
          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: i == _sections.length - 1 ? 0 : 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _currentSection = i),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                    decoration: BoxDecoration(
                      color: isActive ? section.color : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isActive ? section.colorDeep : cardLine,
                        width: 2.5,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                  color: section.colorDeep,
                                  offset: const Offset(0, 4))
                            ]
                          : [
                              const BoxShadow(
                                  color: cardLine, offset: Offset(0, 3))
                            ],
                    ),
                    child: Column(
                      children: [
                        Text(section.emoji,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(
                          section.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isActive ? Colors.white : navy,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ================= SECTION 1: APA ITU GEMPA =================
  Widget _buildApaItuGempaSection() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
      children: [
        _buildSlideCard(
          color: sky,
          colorDeep: skyDeep,
          bigEmoji: '🌍',
          title: 'Bumi Kita Punya Lapisan!',
          body: 'Bumi tempat kita tinggal itu berlapis-lapis, seperti bakpau! '
              'Lapisan paling luar disebut kerak bumi. Kerak bumi ini tersusun '
              'dari lempeng-lempeng besar yang selalu bergerak sangat pelan, '
              'seperti puzzle raksasa yang mengambang.',
          fact: 'Lempeng bumi bergerak hanya beberapa sentimeter per tahun — '
              'kira-kira sama dengan kecepatan kuku kita tumbuh!',
        ),
        _buildSlideCard(
          color: skyDeep,
          colorDeep: const Color(0xFF1C7FB8),
          bigEmoji: '💥',
          title: 'Kenapa Gempa Bisa Terjadi?',
          body:
              'Kadang, lempeng-lempeng itu saling bertabrakan, bergesekan, atau '
              'terkunci lalu tiba-tiba lepas. Nah, saat itulah energi besar '
              'dilepaskan ke segala arah dan membuat tanah bergetar. Itulah '
              'yang kita sebut gempa bumi!',
          fact: 'Indonesia sering mengalami gempa karena berada di pertemuan '
              'banyak lempeng bumi, yang disebut Cincin Api Pasifik.',
        ),
        _buildSlideCard(
          color: purple,
          colorDeep: purpleDeep,
          bigEmoji: '📏',
          title: 'Mengukur Kekuatan Gempa',
          body: 'Kekuatan gempa diukur dengan alat bernama seismograf, dan '
              'hasilnya ditulis dalam skala Magnitudo (SR). Semakin besar '
              'angkanya, semakin kuat getarannya. Gempa kecil sering terjadi '
              'dan biasanya tidak terasa.',
          fact: 'Gempa dengan magnitudo di atas 5 SR biasanya sudah bisa '
              'dirasakan dan berpotensi merusak bangunan.',
        ),
        _buildSlideCard(
          color: green,
          colorDeep: greenDeep,
          bigEmoji: '🌊',
          title: 'Gempa Bisa Memicu Tsunami',
          body:
              'Jika gempa besar terjadi di dasar laut, gempa itu bisa mendorong '
              'air laut dan menciptakan gelombang raksasa yang disebut tsunami. '
              'Karena itu, jika kita di pantai merasakan gempa kuat, segera '
              'menjauh ke tempat yang lebih tinggi!',
          fact: 'Tanda alami tsunami: air laut tiba-tiba surut jauh sebelum '
              'gelombang besar datang. Jangan mendekat untuk melihatnya!',
        ),
      ],
    );
  }

  // ================= SECTION 2: SIAGA GEMPA =================
  Widget _buildSiagaGempaSection() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
      children: [
        _buildSlideCard(
          color: green,
          colorDeep: greenDeep,
          bigEmoji: '🎒',
          title: 'Siapkan Tas Siaga Bencana',
          body: 'Setiap keluarga sebaiknya punya tas siaga yang berisi barang '
              'penting: air minum, makanan ringan tahan lama, senter, obat-obatan, '
              'peluit, dan salinan dokumen penting. Simpan tas ini di tempat yang '
              'mudah dijangkau!',
          fact: 'Peluit sangat penting — jika kamu terjebak, meniup peluit '
              'lebih hemat tenaga daripada berteriak minta tolong.',
        ),
        _buildSlideCard(
          color: gold,
          colorDeep: goldDeep,
          bigEmoji: '🗺️',
          title: 'Kenali Rumah dan Sekolahmu',
          body: 'Cari tahu di mana titik kumpul aman di rumah dan sekolahmu. '
              'Perhatikan juga jalur evakuasi — jalan mana yang harus dilewati '
              'untuk keluar dengan cepat dan aman saat terjadi gempa.',
          fact: 'Latihan evakuasi (simulasi) secara rutin membuat tubuh kita '
              'otomatis tahu harus berbuat apa saat gempa sungguhan terjadi.',
        ),
        _buildSlideCard(
          color: coral,
          colorDeep: coralDeep,
          bigEmoji: '👨‍👩‍👧‍👦',
          title: 'Buat Rencana Bersama Keluarga',
          body: 'Diskusikan dengan orang tua dan keluargamu: ke mana harus '
              'berkumpul jika terpisah saat bencana, dan siapa yang dihubungi '
              'lebih dulu. Simpan nomor telepon penting di tempat yang mudah '
              'diingat.',
          fact: 'Pilih satu kerabat di luar kota sebagai "kontak darurat" — '
              'kadang telepon lokal susah tersambung, tapi ke luar kota lebih mudah.',
        ),
        _buildSlideCard(
          color: skyDeep,
          colorDeep: const Color(0xFF1C7FB8),
          bigEmoji: '🏠',
          title: 'Amankan Barang di Rumah',
          body: 'Minta bantuan orang dewasa untuk mengikat lemari besar ke '
              'dinding, dan jangan meletakkan barang berat di rak paling atas. '
              'Ini mencegah barang jatuh dan melukai saat gempa terjadi.',
          fact: 'Sebagian besar cedera saat gempa terjadi bukan karena '
              'bangunan runtuh, tapi karena tertimpa barang yang jatuh.',
        ),
      ],
    );
  }

  // ================= SECTION 3: DROP COVER HOLD ON =================
  Widget _buildDropCoverHoldSection() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [coral, gold],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: coralDeep.withOpacity(0.3),
                  offset: const Offset(0, 6)),
            ],
          ),
          child: const Row(
            children: [
              Text('🦸‍♂️', style: TextStyle(fontSize: 40)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ini gerakan paling penting saat gempa terjadi. Yuk hafalkan 3 langkahnya!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildStepCard(
          stepNumber: '1',
          color: sky,
          colorDeep: skyDeep,
          emoji: '🙇',
          title: 'DROP (Merunduk)',
          body: 'Segera jatuhkan badanmu ke posisi merunduk dengan kedua lutut '
              'dan tangan menyentuh lantai. Jangan mencoba berlari — gerakan '
              'ini mencegahmu terjatuh atau terhuyung saat lantai bergetar.',
        ),
        _buildStepCard(
          stepNumber: '2',
          color: gold,
          colorDeep: goldDeep,
          emoji: '🛡️',
          title: 'COVER (Berlindung)',
          body: 'Lindungi kepala dan leher dengan masuk ke bawah meja atau '
              'benda kokoh terdekat. Jika tidak ada meja, tutupi kepala dan '
              'leher dengan kedua lengan dan menunduklah di sudut ruangan yang '
              'jauh dari jendela.',
        ),
        _buildStepCard(
          stepNumber: '3',
          color: green,
          colorDeep: greenDeep,
          emoji: '✊',
          title: 'HOLD ON (Berpegangan)',
          body: 'Berpeganganlah pada kaki meja atau benda pelindungmu dengan '
              'satu tangan. Bersiaplah untuk bergerak mengikuti benda '
              'pelindung itu jika ia bergeser, dan tetap di posisi ini sampai '
              'getaran benar-benar berhenti.',
        ),
        _buildSlideCard(
          color: purple,
          colorDeep: purpleDeep,
          bigEmoji: '⚠️',
          title: 'Setelah Gempa Berhenti',
          body: 'Jangan langsung berlari keluar! Tunggu getaran benar-benar '
              'berhenti, lalu berjalan tenang menuju titik kumpul melalui '
              'jalur evakuasi. Waspadai gempa susulan yang mungkin terjadi '
              'setelahnya.',
          fact: 'Gunakan tangga, bukan lift, saat keluar gedung setelah '
              'gempa — listrik bisa mati kapan saja.',
        ),
      ],
    );
  }

  // ================= REUSABLE: SLIDE CARD (TEORI) =================
  Widget _buildSlideCard({
    required Color color,
    required Color colorDeep,
    required String bigEmoji,
    required String title,
    required String body,
    String? fact,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: cardLine, width: 3),
        boxShadow: [
          BoxShadow(color: navy.withOpacity(0.08), offset: const Offset(0, 6)),
          BoxShadow(
              color: navy.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header emoji besar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, colorDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
              ),
            ),
            alignment: Alignment.center,
            child: Text(bigEmoji, style: const TextStyle(fontSize: 56)),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: navy,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: inkSoft,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (fact != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: color.withOpacity(0.3), width: 2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fact,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorDeep,
                              height: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= REUSABLE: STEP CARD (DROP COVER HOLD) =================
  Widget _buildStepCard({
    required String stepNumber,
    required Color color,
    required Color colorDeep,
    required String emoji,
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colorDeep, width: 3),
        boxShadow: [
          BoxShadow(
              color: colorDeep.withOpacity(0.25), offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, colorDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                    color: colorDeep.withOpacity(0.4),
                    offset: const Offset(0, 4)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'LANGKAH $stepNumber',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: colorDeep,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: inkSoft,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialSection {
  final String emoji;
  final String label;
  final Color color;
  final Color colorDeep;

  const _MaterialSection({
    required this.emoji,
    required this.label,
    required this.color,
    required this.colorDeep,
  });
}
