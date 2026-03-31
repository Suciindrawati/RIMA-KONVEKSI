import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_admin_screen.dart';
import 'screens/dashboard/dashboard_karyawan_screen.dart';
import 'screens/pelanggan/pelanggan_screen.dart';
import 'screens/pelanggan/pelanggan_form_screen.dart';
import 'screens/pelanggan/pelanggan_detail_screen.dart';
import 'screens/produk/produk_screen.dart';
import 'screens/produk/produk_form_screen.dart';
import 'screens/transaksi/transaksi_screen.dart';
import 'screens/katalog/katalog_screen.dart';

void main() {
  runApp(const RimaKonveksiApp());
}

class RimaKonveksiApp extends StatelessWidget {
  const RimaKonveksiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rima Konveksi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const SplashScreen(),
        '/login': (ctx) => const LoginScreen(),
        '/register': (ctx) => const RegisterScreen(),
        '/dashboard-admin': (ctx) => const DashboardAdminScreen(),
        '/dashboard-karyawan': (ctx) => const DashboardKaryawanScreen(),
        '/pelanggan': (ctx) => const PelangganScreen(),
        '/pelanggan-form': (ctx) => const PelangganFormScreen(),
        '/pelanggan-detail': (ctx) => const PelangganDetailScreen(),
        '/produk': (ctx) => const ProdukScreen(),
        '/produk-form': (ctx) => const ProdukFormScreen(),
        '/transaksi': (ctx) => const TransaksiScreen(),
        '/transaksi-form': (ctx) => const TransaksiFormScreen(),
        '/katalog': (ctx) => const KatalogScreen(),
      },
    );
  }
}
