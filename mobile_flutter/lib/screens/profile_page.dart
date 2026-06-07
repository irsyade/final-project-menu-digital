import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/auth_controller.dart';
import 'package:mobile_flutter/screens/login_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPad = screenWidth < 400 ? 16.0 : 24.0;
    final avatarRadius = isSmallScreen ? 36.0 : 44.0;
    final headerPad = screenWidth < 400 ? 20.0 : 28.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profil Saya', 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            color: AppColors.slate900,
            letterSpacing: -0.5,
            fontSize: 18,
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(headerPad),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDesign.radiusXL),
                boxShadow: [AppDesign.shadow],
                border: Border.all(color: AppColors.slate200.withOpacity(0.6)),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Icon(LucideIcons.user, size: avatarRadius * 0.9, color: AppColors.primary),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(LucideIcons.check, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final name = authController.user['name']?.toString() ?? 'Administrator';
                    return Text(
                      name,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 22, 
                        fontWeight: FontWeight.w900,
                        color: AppColors.slate900,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                  const SizedBox(height: 4),
                  Obx(() {
                    final email = authController.user['email']?.toString() ?? '';
                    return Text(
                      email,
                      style: TextStyle(
                        fontSize: 13, 
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                  const SizedBox(height: 16),
                  Obx(() {
                    final badgeLabel = authController.isAdmin ? 'VERIFIED ADMIN' : 'KASIR AKTIF';
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Options Group: Management
            _buildSectionHeader('MANAJEMEN'),
            const SizedBox(height: 10),
            _buildProfileOption(
              icon: LucideIcons.history,
              title: 'Riwayat Pesanan',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: LucideIcons.mapPin,
              title: 'Lokasi Outlet',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: LucideIcons.settings,
              title: 'Pengaturan Akun',
              onTap: () {},
            ),
            
            const SizedBox(height: 24),
            
            // Options Group: System
            _buildSectionHeader('SISTEM'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDesign.radiusM),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info, color: AppColors.primary, size: 20),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Versi Aplikasi',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  Text(
                    '1.2.0',
                    style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  await authController.logout();
                  Get.offAll(() => const LoginScreen());
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDesign.radiusM),
                  ),
                ),
                icon: Icon(LucideIcons.power, size: 18),
                label: const Text(
                  'KELUAR AKUN',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.slate400,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radiusM),
        border: Border.all(color: AppColors.slate200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(icon, color: AppColors.slate700, size: 20),
        title: Text(
          title, 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w700,
            color: AppColors.slate900,
          )
        ),
        trailing: Icon(LucideIcons.chevronRight, size: 16, color: AppColors.slate300),
        onTap: onTap,
      ),
    );
  }
}