import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obsecure = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = AuthService();
      final res = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (res['token'] != null) {
        await auth.saveSession(res['token'], res['user']['role'], res['user']['nama'], res['user']['id']);
        if (!mounted) return;
        final role = res['user']['role'];
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/dashboard-admin');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard-karyawan');
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Login failed'), backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error connect: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Decor
          Positioned(top: -100, right: -100, child: CircleAvatar(radius: 150, backgroundColor: const Color(0xFFF97316).withOpacity(0.05))),
          Positioned(bottom: -50, left: -50, child: CircleAvatar(radius: 100, backgroundColor: const Color(0xFFF97316).withOpacity(0.05))),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(32)),
                        child: const Icon(Icons.checkroom_rounded, size: 64, color: Color(0xFFF97316)),
                      ),
                      const SizedBox(height: 24),
                      Text('RIMA KONVEKSI', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1, color: const Color(0xFF1E293B))),
                      const SizedBox(height: 8),
                      const Text('Sistem Manajemen Produksi & Inventaris', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
                      
                      const SizedBox(height: 48),
                      
                      // Email Field
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                        validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                      ),
                      const SizedBox(height: 20),
                      
                      // Password Field
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obsecure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_person_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_obsecure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                            onPressed: () => setState(() => _obsecure = !_obsecure),
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Password wajib diisi' : null,
                      ),
                      
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: () {}, child: const Text('Lupa Password?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading 
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                            : const Text('MASUK KE SISTEM', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Karyawan baru?', style: TextStyle(color: Color(0xFF64748B))),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/register'),
                            child: const Text('Daftar Akun', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      const Text('Ver 2.0.1 • Crafted for Excellence', style: TextStyle(fontSize: 10, color: Color(0xFFCBD5E1), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
