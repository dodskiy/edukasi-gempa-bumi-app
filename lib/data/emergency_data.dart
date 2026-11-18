import 'package:flutter/material.dart';
import '../models/emergency_model.dart';

class EmergencyData {
  static const List<EmergencyContact> contacts = [
    EmergencyContact(
      name: 'BPBD Provinsi Maluku Utara',
      region: 'Sofifi / Ternate (Provinsi)',
      phoneNumber: '0921-3121113',
      description:
          'Badan Penanggulangan Bencana Daerah Prov. Malut untuk koordinasi logistik dan posko darurat.',
      icon: Icons.shield_outlined,
    ),
    EmergencyContact(
      name: 'BASARNAS / Kantor Pencarian & Pertolongan Ternate',
      region: 'Kota Ternate & Sekitarnya',
      phoneNumber: '0921-3127814',
      description:
          'Layanan evakuasi korban reruntuhan, pertolongan laut Malut, dan SAR darurat.',
      icon: Icons.emergency,
    ),
    EmergencyContact(
      name: 'Call Center Darurat Indonesia',
      region: 'Nasional & Malut',
      phoneNumber: '112',
      description:
          'Panggilan darurat terpadu bebas pulsa untuk medis, kepolisian, dan kebakaran.',
      icon: Icons.phone_in_talk,
    ),
    EmergencyContact(
      name: 'PMI (Palang Merah Indonesia) Ternate',
      region: 'Kota Ternate',
      phoneNumber: '0921-3121516',
      description:
          'Bantuan pertolongan pertama, ambulans darurat, dan stok kantung darah.',
      icon: Icons.medical_services_outlined,
    ),
    EmergencyContact(
      name: 'Polda Maluku Utara',
      region: 'Maluku Utara',
      phoneNumber: '110',
      description:
          'Bantuan pengamanan jalur evakuasi, pencarian orang hilang, dan ketertiban.',
      icon: Icons.local_police_outlined,
    ),
    EmergencyContact(
      name: 'Stasiun Geofisika BMKG Ternate',
      region: 'Ternate & Halmahera',
      phoneNumber: '0921-3121303',
      description:
          'Informasi parameter gempa bumi real-time dan peringatan dini tsunami wilayah Maluku Utara.',
      icon: Icons.sensors,
    ),
  ];
}
