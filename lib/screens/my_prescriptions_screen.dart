import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/prescription_service.dart';
import '../models/prescription_models.dart';

class MyPrescriptionsScreen extends StatefulWidget {
  const MyPrescriptionsScreen({super.key});

  @override
  State<MyPrescriptionsScreen> createState() => _MyPrescriptionsScreenState();
}

class _MyPrescriptionsScreenState extends State<MyPrescriptionsScreen> {
  late Future<List<Prescription>> _prescriptionsFuture;
  final PrescriptionService _prescriptionService = PrescriptionService();

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  void _fetchPrescriptions() {
    setState(() {
      _prescriptionsFuture = _prescriptionService.getPrescriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER FIX ȘI MODERN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff30cfd0), Color(0xff330867)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.medical_services_rounded, color: Colors.white, size: 44),
                  const SizedBox(height: 10),
                  Text(
                    "Rețetele Mele",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Toate rețetele eliberate și statusul lor.",
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // LISTA DE REȚETE (fancy)
            Expanded(
              child: FutureBuilder<List<Prescription>>(
                future: _prescriptionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_rounded, size: 44, color: Colors.redAccent),
                          const SizedBox(height: 10),
                          Text('Eroare la încărcarea rețetelor: ${snapshot.error}'),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reîncearcă'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff30cfd0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _fetchPrescriptions,
                          )
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_nature, size: 56, color: Colors.blueGrey[100]),
                          const SizedBox(height: 16),
                          Text(
                            'Nu aveți nicio rețetă activă.',
                            style: TextStyle(fontSize: 18, color: Colors.blueGrey[700]),
                          ),
                        ],
                      ),
                    );
                  } else {
                    final prescriptions = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
                      itemCount: prescriptions.length,
                      itemBuilder: (context, index) {
                        final prescription = prescriptions[index];
                        return PrescriptionCard(prescription: prescription);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrescriptionCard extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionCard({super.key, required this.prescription});

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  void _showQrCodeDialog(BuildContext context, String qrData, bool isValid) {
    showDialog(
      context: context,
      barrierColor: Colors.black38, // fundal blurat ușor
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cardul principal
              Container(
                margin: EdgeInsets.only(top: 24),
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [Color(0xffe0f7fa), Color(0xffe9eafc)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isValid
                          ? Colors.teal.withOpacity(0.09)
                          : Colors.redAccent.withOpacity(0.09),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: isValid ? Color(0xff30cfd0) : Colors.redAccent,
                    width: 1.4,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon și titlu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          color: isValid ? Color(0xff30cfd0) : Colors.redAccent,
                          size: 34,
                        ),
                        SizedBox(width: 10),
                        Text(
                          isValid ? 'Cod QR Rețetă' : 'Cod QR Invalid',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isValid ? Color(0xff30cfd0) : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (isValid)
                      Text(
                        "Scanați acest cod la farmacie pentru validare.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xff330867),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      Text(
                        "Acest cod QR nu este valid.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.red[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    SizedBox(height: 22),

                    // Card QR cu border
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isValid ? Color(0xff30cfd0) : Colors.redAccent,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(16),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                        gapless: false,
                        errorStateBuilder: (cxt, err) {
                          return const Center(
                            child: Text(
                              "Eroare la generarea codului QR",
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 18),

                    // Status valid/invalid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isValid ? Icons.verified_rounded : Icons.cancel,
                          color: isValid ? Colors.green : Colors.red,
                          size: 22,
                        ),
                        SizedBox(width: 7),
                        Text(
                          isValid ? "Cod valid" : "Cod invalid",
                          style: TextStyle(
                            color: isValid ? Colors.green[700] : Colors.red[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Buton închidere
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.close),
                        label: Text("Închide"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isValid ? Color(0xff30cfd0) : Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
              // Element de decor “floating”
              Positioned(
                top: 0,
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: isValid ? Color(0xff30cfd0) : Colors.redAccent,
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isQrValid = prescription.qrCode.valid == 1;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: isQrValid
              ? [Color(0xffe6fffb), Color(0xfff5fdff)]
              : [Color(0xffffeaea), Color(0xfffff8f7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isQrValid
                ? Colors.tealAccent.withOpacity(0.07)
                : Colors.redAccent.withOpacity(0.06),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          splashColor: Color(0xff30cfd0).withOpacity(0.13),
          onTap: isQrValid
              ? () => _showQrCodeDialog(context, prescription.qrCode.cod, isQrValid)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isQrValid ? Icons.verified_rounded : Icons.error_outline_rounded,
                      color: isQrValid ? Color(0xff30cfd0) : Colors.redAccent,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      isQrValid ? "Rețetă validă" : "Rețetă invalidă",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: isQrValid ? Color(0xff30cfd0) : Colors.redAccent,
                      ),
                    ),
                    Spacer(),
                    Chip(
                      label: Text(isQrValid ? "Valid" : "Invalid"),
                      backgroundColor: isQrValid ? Colors.green.shade50 : Colors.red.shade50,
                      labelStyle: TextStyle(
                        color: isQrValid ? Colors.green.shade900 : Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                      avatar: Icon(
                        isQrValid ? Icons.check_circle : Icons.cancel,
                        size: 18,
                        color: isQrValid ? Colors.green : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'ID rețetă: ${prescription.id}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 18, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text('Emisă: ${_formatDate(prescription.issuedAt)}',
                        style: TextStyle(color: Colors.grey[800], fontSize: 14)),
                    SizedBox(width: 16),
                    Icon(Icons.timelapse, size: 18, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text('Expiră: ${_formatDate(prescription.expiresAt)}',
                        style: TextStyle(color: Colors.grey[800], fontSize: 14)),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Medicamente prescrise:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xff330867),
                  ),
                ),
                const SizedBox(height: 6),
                ...prescription.medications.map((med) => MedicationItem(medication: med)).toList(),
                SizedBox(height: 14),
                if (prescription.details.isNotEmpty) ...[
                  Divider(height: 28, thickness: 1, color: Colors.grey[200]),
                  Text(
                    'Detalii suplimentare:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[900]),
                  ),
                  Text(
                    prescription.details,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
                SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.qr_code_scanner,
                      color: isQrValid ? null : Colors.grey,
                    ),
                    label: Text(
                      isQrValid ? 'Vezi Cod QR' : 'QR Invalid',
                      style: TextStyle(color: isQrValid ? null : Colors.grey),
                    ),
                    onPressed: isQrValid
                        ? () => _showQrCodeDialog(context, prescription.qrCode.cod, isQrValid)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isQrValid
                          ? Color(0xff30cfd0)
                          : Colors.grey.shade200,
                      foregroundColor: isQrValid
                          ? Colors.white
                          : Colors.grey.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MedicationItem extends StatelessWidget {
  final Medication medication;

  const MedicationItem({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, left: 8.0, bottom: 2.0),
      child: Row(
        children: [
          Icon(Icons.medication_rounded, size: 18, color: Color(0xff30cfd0)),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              '${medication.nume} (${medication.doza})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          SizedBox(width: 4),
          Text(
            'x${medication.pivot.frecventa} / ${medication.pivot.intervalOre}h',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
