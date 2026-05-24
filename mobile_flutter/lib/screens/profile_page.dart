import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/auth_controller.dart';
import 'package:mobile_flutter/screens/login_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profil Saya', 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            color: AppColors.slate900,
            letterSpacing: -0.5,
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(32),
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
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Icon(LucideIcons.user, size: 50, color: AppColors.primary),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(LucideIcons.check, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Administrator',
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.w900,
                      color: AppColors.slate900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'admin@flavorakitchen.com',
                    style: TextStyle(
                      fontSize: 14, 
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'VERIFIED ADMIN',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Options Group: Management
            _buildSectionHeader('MANAJEMEN'),
            const SizedBox(height: 12),
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
            
            const SizedBox(height: 32),
            
            // Options Group: System
            _buildSectionHeader('SISTEM'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDesign.radiusM),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info, color: AppColors.primary, size: 20),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Versi Aplikasi',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Text(
                    '1.2.0',
                    style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  await authController.logout();
                  Get.offAll(() => const LoginScreen());
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDesign.radiusM),
                  ),
                ),
                icon: Icon(LucideIcons.power, size: 20),
                label: const Text(
                  'KELUAR AKUN',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(height: 40),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radiusM),
        border: Border.all(color: AppColors.slate200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: AppColors.slate700, size: 22),
        title: Text(
          title, 
          style: TextStyle(
            fontSize: 15, 
            fontWeight: FontWeight.w700,
            color: AppColors.slate900,
          )
        ),
        trailing: Icon(LucideIcons.chevronRight, size: 18, color: AppColors.slate300),
        onTap: onTap,
      ),
    );
  }
}
