import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'my_prescriptions_screen.dart';
import 'nearby_pharmacies_screen.dart';
import 'profile_screen.dart'; // Import corect!

import '../services/prescription_service.dart'; // Importă PrescriptionService!
import '../models/prescription_models.dart';


class WelcomeDashboardContent extends StatefulWidget {
  const WelcomeDashboardContent({super.key});

  @override
  State<WelcomeDashboardContent> createState() => _WelcomeDashboardContentState();
}

class _WelcomeDashboardContentState extends State<WelcomeDashboardContent> {
  final _service = PrescriptionService();
  late Future<List<Prescription>> _prescriptionsFuture;

  @override
  void initState() {
    super.initState();
    _prescriptionsFuture = _service.getPrescriptions();
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Prescription>>(
      future: _prescriptionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: CircularProgressIndicator(color: Color(0xff30cfd0)),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error, color: Colors.redAccent, size: 48),
                  SizedBox(height: 12),
                  Text('Eroare la încărcarea datelor!',
                      style: TextStyle(
                          color: Colors.red[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 17)),
                  SizedBox(height: 6),
                  Text('${snapshot.error}', style: TextStyle(color: Colors.red[400])),
                ],
              ),
            ),
          );
        } else {
          final prescriptions = snapshot.data ?? [];
          final hasPrescriptions = prescriptions.isNotEmpty;
          final latest = hasPrescriptions ? prescriptions.first : null;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Banner de bun venit
                  _WelcomeCard(),
                  SizedBox(height: 22),

                  // CARDURI SCROLLABILE, SEPARATE
                  Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: 20,
                    spacing: 18,
                    children: [
                      DashboardGlassCard(
                        icon: Icons.medical_services_rounded,
                        iconColor: Color(0xff30cfd0),
                        label: "Rețete active",
                        value: prescriptions.length.toString(),
                        description: prescriptions.isEmpty
                            ? "Nicio rețetă emisă încă."
                            : "Total rețete active asociate profilului tău.",
                      ),
                      if (hasPrescriptions && latest != null) ...[
                        DashboardGlassCard(
                          icon: Icons.receipt_long_rounded,
                          iconColor: Color(0xff330867),
                          label: "Ultima rețetă",
                          value: latest.details.length > 32
                              ? latest.details.substring(0, 31) + "…"
                              : latest.details,
                          description: "Emisă la ${_formatDate(latest.issuedAt)}. Expiră la ${_formatDate(latest.expiresAt)}.",
                        ),
                        DashboardGlassCard(
                          icon: Icons.access_time_filled_rounded,
                          iconColor: Colors.teal,
                          label: "Data emiterii",
                          value: _formatDate(latest.issuedAt),
                          description: "Verifică valabilitatea rețetei tale.",
                        ),
                        DashboardGlassCard(
                          icon: Icons.hourglass_bottom_rounded,
                          iconColor: Colors.pinkAccent,
                          label: "Expiră la",
                          value: _formatDate(latest.expiresAt),
                          description: latest.expiresAt.isBefore(DateTime.now())
                              ? "Atenție: rețeta e expirată!"
                              : "Folosește rețeta înainte de această dată.",
                        ),
                      ] else ...[
                        DashboardGlassCard(
                          icon: Icons.sentiment_dissatisfied_rounded,
                          iconColor: Colors.orange,
                          label: "Nu există rețete",
                          value: "—",
                          description: "Nicio rețetă activă momentan.",
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [Color(0xff30cfd0), Color(0xff330867)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_emotions_rounded, color: Colors.white, size: 50),
          SizedBox(height: 18),
          Text(
            'Bine ai venit în MedicSync!',
            style: TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Ai grijă de sănătatea ta. Noi ne ocupăm de restul! 👩‍⚕️',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DashboardGlassCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? description;

  const DashboardGlassCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 162,
      constraints: BoxConstraints(minHeight: 138, maxWidth: 185),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.15),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
        border: Border.all(color: iconColor.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 34),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (description != null) ...[
            SizedBox(height: 7),
            Text(
              description!,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12.7,
                height: 1.32,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    WelcomeDashboardContent(),
    MyPrescriptionsScreen(),
    NearbyPharmaciesScreen(),
    ProfileScreen(), // Import separat
  ];

  static const List<String> _appBarTitles = <String>[
    'Dashboard',
    'Rețetele Mele',
    'Farmacii din apropiere',
    'Profil',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout(BuildContext context) {
    AuthService.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        centerTitle: true,
        title: Text(
          _appBarTitles[_selectedIndex],
          style: TextStyle(
            color: Color(0xff330867),
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      // IndexedStack pentru menținerea stării între taburi
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 14,
              offset: Offset(0, -2),
            ),
          ],
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Acasă',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined),
              activeIcon: Icon(Icons.medical_services),
              label: 'Rețete',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_pharmacy_outlined),
              activeIcon: Icon(Icons.local_pharmacy),
              label: 'Farmacii',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xff30cfd0),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
