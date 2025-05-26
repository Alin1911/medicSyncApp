class PrescriptionList {
  final List<Prescription> prescriptions;

  PrescriptionList({required this.prescriptions});

  factory PrescriptionList.fromJson(Map<String, dynamic> json) {
    var list = json['prescriptions'] as List;
    List<Prescription> prescriptionsList = list.map((i) => Prescription.fromJson(i)).toList();
    return PrescriptionList(prescriptions: prescriptionsList);
  }
}

class Prescription {
  final int id;
  final int patientId;
  final int medicId;
  final String details;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Medication> medications;
  final QrCodeData qrCode;

  Prescription({
    required this.id,
    required this.patientId,
    required this.medicId,
    required this.details,
    required this.issuedAt,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    required this.medications,
    required this.qrCode,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      patientId: json['patient_id'],
      medicId: json['medic_id'],
      details: json['details'],
      issuedAt: DateTime.parse(json['issued_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      medications: (json['medications'] as List)
          .map((medJson) => Medication.fromJson(medJson))
          .toList(),
      qrCode: QrCodeData.fromJson(json['qr_code']),
    );
  }
}

class Medication {
  final int id;
  final String nume;
  final String doza;
  final String descriere;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Pivot pivot;

  Medication({
    required this.id,
    required this.nume,
    required this.doza,
    required this.descriere,
    required this.createdAt,
    required this.updatedAt,
    required this.pivot,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      nume: json['nume'],
      doza: json['doza'],
      descriere: json['descriere'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      pivot: Pivot.fromJson(json['pivot']),
    );
  }
}

class Pivot {
  final int prescriptionId;
  final int medicationId;
  final int frecventa;
  final int intervalOre;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pivot({
    required this.prescriptionId,
    required this.medicationId,
    required this.frecventa,
    required this.intervalOre,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) {
    return Pivot(
      prescriptionId: json['prescription_id'],
      medicationId: json['medication_id'],
      frecventa: json['frecventa'],
      intervalOre: json['interval_ore'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class QrCodeData {
  final int id;
  final int retetaId;
  final String cod;
  final int valid; // 1 for true, 0 for false
  final DateTime createdAt;
  final DateTime updatedAt;

  QrCodeData({
    required this.id,
    required this.retetaId,
    required this.cod,
    required this.valid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QrCodeData.fromJson(Map<String, dynamic> json) {
    return QrCodeData(
      id: json['id'],
      retetaId: json['reteta_id'],
      cod: json['cod'],
      valid: json['valid'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}