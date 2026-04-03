import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'karyawan';
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = AuthService();
      final res = await auth.register(_namaCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text, _role);
      if (res['token'] != null) {
        await auth.saveSession(res['token'], res['user']['role'], res['user']['nama'], res['user']['id']);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi berhasil! Silakan masuk.'), backgroundColor: Colors.green));
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal daftar'), backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Daftar Akun Baru', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mari Bergabung', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFFF97316))),
              const SizedBox(height: 8),
              const Text('Lengkapi data berikut untuk bergabung dengan tim produksi Rima Konveksi.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              
              const SizedBox(height: 40),
              
              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_pin_rounded)),
                validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Alamat Email', prefixIcon: Icon(Icons.email_rounded)),
                validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Kata Sandi', prefixIcon: Icon(Icons.lock_rounded)),
                validator: (v) => v!.length < 6 ? 'Minimal 6 karakter' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Posisi / Role Dalam Tim', prefixIcon: Icon(Icons.work_rounded)),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Administrator (Owner)')),
                  DropdownMenuItem(value: 'karyawan', child: Text('Karyawan Produksi')),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('DAFTAR SEKARANG', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun?', style: TextStyle(color: Color(0xFF64748B))),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Login Di Sini', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
