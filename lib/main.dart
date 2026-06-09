import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
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
import 'screens/laporan/laporan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF97316),
          primary: const Color(0xFFF97316),
          onPrimary: Colors.white,
          secondary: const Color(0xFF1E293B),
          surface: Colors.white,
          background: const Color(0xFFF8FAFC),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF97316),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
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
        '/laporan': (ctx) => const LaporanScreen(),
      },
    );
  }
}
