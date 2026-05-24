import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/kasir_controller.dart';
import 'package:mobile_flutter/screens/kasir/transaksi_baru_page.dart';
import 'package:mobile_flutter/screens/kasir/pembayaran_page.dart';
import 'package:mobile_flutter/screens/kasir/riwayat_pesanan_page.dart';
import 'package:mobile_flutter/screens/kasir/rekap_harian_page.dart';
import 'package:mobile_flutter/screens/kasir/pengaturan_kasir_page.dart';
import 'package:mobile_flutter/screens/kasir/table_management_page.dart';
import 'package:mobile_flutter/screens/menu_page.dart';
import 'package:mobile_flutter/controllers/auth_controller.dart';

class KasirLayout extends StatelessWidget {
  const KasirLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final KasirController controller = Get.find<KasirController>();
    final isMobile = MediaQuery.of(context).size.width <= 900;

    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isMobile ? Drawer(
        child: _buildSidebar(context, controller, isMobile: true),
      ) : null,
      body: Row(
        children: [
          // Sidebar (Fixed 240px on Tablet/Desktop)
          if (!isMobile) _buildSidebar(context, controller),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Inline Header for Mobile/Tablet Content Area
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                  child: Row(
                    children: [
                      if (isMobile)
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(LucideIcons.menu, color: AppColors.slate900),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                      Expanded(
                        child: Obx(() {
                          String name = authController.user['name'] ?? 'Kasir';
                          return Text(
                            isMobile ? "POS Resto" : "Kasir: $name", 
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.slate900, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                      ),
                      const Spacer(),
                      // Simple notification or user icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(LucideIcons.bell, size: 18, color: AppColors.slate400),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    return _buildContent(controller.selectedIndex.value);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, KasirController controller, {bool isMobile = false}) {
    return Container(
      width: isMobile ? double.infinity : 240,
      height: double.infinity,
      color: const Color(0xFF1E1E2E),
      child: Column(
        children: [
          _buildLogo(),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _navItem(controller, 0, "Transaksi Baru", LucideIcons.shoppingCart, isMobile),
                  _navItem(controller, 1, "Riwayat Pesanan", LucideIcons.clock, isMobile),
                  _navItem(controller, 2, "Pembayaran", LucideIcons.creditCard, isMobile),
                  _navItem(controller, 3, "Rekap Harian", LucideIcons.barChart2, isMobile),
                  _navItem(controller, 4, "Kelola Meja", LucideIcons.layoutGrid, isMobile),
                  _navItem(controller, 5, "Kelola Menu", LucideIcons.layoutList, isMobile),
                  _navItem(controller, 6, "Pengaturan", LucideIcons.settings, isMobile),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.shoppingCart, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            "POS Resto",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(KasirController controller, int index, String title, IconData icon, bool isMobile) {
    return Obx(() {
      bool isActive = controller.selectedIndex.value == index;
      return GestureDetector(
        onTap: () {
          controller.changeIndex(index);
          if (isMobile) Get.back(); // Close drawer on mobile
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : const Color(0xFF64748B),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBottomBar() {
    final AuthController authController = Get.find<AuthController>();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Obx(() {
                    String name = authController.user['name']?.toString() ?? 'K';
                    String initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'K';
                    return Text(initial, style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 12));
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      String name = authController.user['name'] ?? 'Kasir';
                      return Text("Kasir: $name", style: GoogleFonts.outfit(color: const Color(0xFFE2E8F0), fontWeight: FontWeight.w900, fontSize: 12), overflow: TextOverflow.ellipsis);
                    }),
                    Text("Kasir Aktif", style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 1.2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: Text("Konfirmasi Logout", style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                  content: Text("Apakah Anda yakin ingin keluar?", style: GoogleFonts.outfit()),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text("Batal", style: GoogleFonts.outfit(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Get.back(result: true),
                      child: Text("Logout", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                authController.logout();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.logOut, color: Color(0xFFFF6B6B), size: 14),
                  const SizedBox(width: 8),
                  Text("LOGOUT", style: GoogleFonts.outfit(color: const Color(0xFFFF6B6B), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0: return TransaksiBaruPage();
      case 1: return RiwayatPesananPage();
      case 2: return PembayaranPage();
      case 3: return RekapHarianPage();
      case 4: return TableManagementPage();
      case 5: return const MenuPage();
      case 6: return PengaturanKasirPage();
      default: return TransaksiBaruPage();
    }
  }
}
