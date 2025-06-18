import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/1_auth/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Animasi untuk logo
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;

  // Animasi untuk teks judul
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation; // Offset untuk slide

  // Animasi untuk teks sub-judul
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation; // Offset untuk slide

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // Total durasi animasi (2.5 detik)
    );

    // Animasi Logo (Fade & Scale) - Mulai lebih awal
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn), // Animasi logo 0% - 60% dari total durasi
      ),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate( // Mulai sedikit lebih kecil
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut), // Efek elastis pada skala
      ),
    );

    // Animasi Teks Judul (Fade & Slide Up) - Mulai sedikit terlambat dari logo
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeIn), // Animasi teks 40% - 90% dari total durasi
      ),
    );
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5), // Mulai dari bawah sedikit
      end: Offset.zero, // Berakhir di posisi aslinya
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic), // Kurva yang lebih dramatis
      ),
    );

    // Animasi Teks Sub-Judul (Fade & Slide Up) - Mulai terlambat dari judul
    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn), // Animasi sub-judul 60% - 100% dari total durasi
      ),
    );
    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8), // Mulai dari bawah lebih jauh
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward(); // Memulai semua animasi

    // Navigasi setelah animasi selesai
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Tunda navigasi sedikit lagi setelah animasi selesai sepenuhnya,
        // agar pengguna bisa menikmati momen akhir animasi
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateToNextScreen();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_welcome_page.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo dengan Fade dan Scale
              FadeTransition(
                opacity: _logoFadeAnimation,
                child: ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: Image.asset(
                    'assets/food_delivery.png',
                    height: 90,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Teks Judul dengan Fade dan Slide
              SlideTransition(
                position: _titleSlideAnimation,
                child: FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: Text(
                    'Food Delivery App',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28, // Sedikit lebih besar
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      shadows: [ // Tambahkan sedikit shadow untuk efek elegan
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Teks Sub-judul dengan Fade dan Slide
              SlideTransition(
                position: _subtitleSlideAnimation,
                child: FadeTransition(
                  opacity: _subtitleFadeAnimation,
                  child: Text(
                    'Pesan makanan favoritmu\nkapan saja, di mana saja',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18, // Sedikit lebih besar
                      color: Colors.grey, // Kembali ke white70
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(1.5, 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}