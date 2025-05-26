import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';
  bool loading = false;

  void _login() async {
    setState(() {
      loading = true;
      error = '';
    });
    final token = await AuthService.login(
      emailController.text,
      passwordController.text,
    );
    setState(() {
      loading = false;
    });
    if (token != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() {
        error = 'Autentificare eșuată.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff30cfd0), Color(0xff330867)], // turquoise to deep blue
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo & App Name
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.medical_services_rounded, color: Color(0xff30cfd0), size: 42),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'MedicSync',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 30),

                    // Login Card
                    Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Autentificare',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff330867),
                              ),
                            ),
                            SizedBox(height: 18),
                            TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email_rounded, color: Color(0xff30cfd0)),
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                            SizedBox(height: 18),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock_rounded, color: Color(0xff30cfd0)),
                                labelText: 'Parola',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                            if (error.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  error,
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                                ),
                              ),
                            SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff30cfd0),
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 3,
                                ),
                                child: loading
                                    ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                                    : Text(
                                  'Autentificare',
                                  style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    // Footer
                    Text(
                      '© ${DateTime.now().year} MedicSync. Toate drepturile rezervate.',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
