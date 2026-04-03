import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await Future.delayed(const Duration(seconds: 3));
    final auth = AuthService();
    final loggedIn = await auth.isLoggedIn();
    if (!mounted) return;
    if (loggedIn) {
      final role = await auth.getRole();
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/dashboard-admin');
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard-karyawan');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Gradient Element
          Positioned(bottom: -150, child: Container(width: 500, height: 500, decoration: BoxDecoration(color: const Color(0xFFF97316).withOpacity(0.05), shape: BoxShape.circle))),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Anim - Checkroom icon as brand icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFFF97316).withOpacity(0.1), borderRadius: BorderRadius.circular(36)),
                  child: const Icon(Icons.checkroom_rounded, size: 80, color: Color(0xFFF97316)),
                ),
                const SizedBox(height: 32),
                Text(
                  'RIMA KONVEKSI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'CRAFTED WITH PRECISION',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 64),
                const SizedBox(
                  width: 40,
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFFF1F5F9),
                    color: Color(0xFFF97316),
                    minHeight: 2,
                  ),
                ),
              ],
            ),
          ),
          
          // Footer
          const Positioned(
            bottom: 40,
            child: Text(
              'QUALITY CLOTHING MANAGEMENT',
              style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }
}
