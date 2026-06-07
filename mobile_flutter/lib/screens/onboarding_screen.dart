import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Selamat Datang di MenuKu Admin',
      'description': 'Platform digital untuk pemilik restoran yang ingin mengelola bisnis dengan lebih efisien.',
      'icon': 'utensils',
    },
    {
      'title': 'Menu Digital dengan QR Code',
      'description': 'Buat menu digitalmu sendiri dengan mudah dan biarkan pelangganmu memesan hanya dengan scan QR Code.',
      'icon': 'qr_code',
    },
    {
      'title': 'Pantau Semua Secara Real-Time',
      'description': 'Lihat laporan penjualan, kelola pesanan masuk, dan pantau stok produkmu secara langsung.',
      'icon': 'bar_chart',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Orange Header
          LayoutBuilder(
            builder: (context, constraints) {
              bool isTablet = MediaQuery.of(context).size.width > 600;
              return Container(
                height: MediaQuery.of(context).size.height * (isTablet ? 0.45 : 0.6),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(100),
                  ),
                ),
              );
            }
          ),
          
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              
              // Bottom Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => _buildDot(index),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            Get.offAll(() => const LoginScreen());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'Mulai Sekarang' : 'Selanjutnya',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPage(Map<String, String> page) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = screenWidth > 600;
    bool isShort = screenHeight < 700;
    IconData iconData;
    switch (page['icon']) {
      case 'qr_code':
        iconData = LucideIcons.qrCode;
        break;
      case 'bar_chart':
        iconData = LucideIcons.barChart3;
        break;
      default:
        iconData = LucideIcons.utensilsCrossed;
    }

    return Padding(
      padding: EdgeInsets.all(isShort ? 20 : 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: isTablet ? 0 : (isShort ? 16 : 40)),
          Container(
            padding: EdgeInsets.all(isTablet ? 30 : (isShort ? 28 : 40)),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Icon(
              iconData,
              size: isTablet ? 60 : (isShort ? 50 : 80),
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: isTablet ? 40 : (isShort ? 32 : 80)),
          Text(
            page['title']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: isShort ? 20 : 24,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page['description']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: isShort ? 13 : 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}