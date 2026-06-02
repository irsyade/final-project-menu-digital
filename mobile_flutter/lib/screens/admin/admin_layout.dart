import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/auth_controller.dart';
import 'package:mobile_flutter/screens/admin/admin_dashboard.dart';
import 'package:mobile_flutter/screens/admin/admin_orders_page.dart';
import 'package:mobile_flutter/screens/admin/admin_product_management.dart';
import 'package:mobile_flutter/screens/admin/admin_promo_page.dart';
import 'package:mobile_flutter/screens/admin/admin_table_management.dart';
import 'package:mobile_flutter/screens/admin/admin_report_page.dart';
import 'package:mobile_flutter/screens/admin/admin_settings_page.dart';
import 'package:mobile_flutter/controllers/settings_controller.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final AuthController _authController = Get.find<AuthController>();
  final SettingsController _settingsController = Get.put(SettingsController());
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboard(),
    AdminOrdersPage(),
    AdminProductManagementPage(),
    const AdminPromoPage(),
    AdminTableManagementPage(),
    const AdminReportPage(),
    const AdminSettingsPage(),
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': LucideIcons.layoutGrid, 'label': 'Dashboard'},
    {'icon': LucideIcons.package, 'label': 'Pesanan Masuk'},
    {'icon': LucideIcons.utensils, 'label': 'Kelola Menu'},
    {'icon': LucideIcons.megaphone, 'label': 'Promo & Jadwal'},
    {'icon': LucideIcons.armchair, 'label': 'Meja & QR Code'},
    {'icon': LucideIcons.barChart3, 'label': 'Laporan Penjualan'},
    {'icon': LucideIcons.settings, 'label': 'Pengaturan'},
  ];

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      drawer: isTablet ? null : _buildSidebar(),
      body: Row(
        children: [
          if (isTablet) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                // Top Header inside content area
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                  child: Row(
                    children: [
                      if (!isTablet)
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(LucideIcons.menu, color: Colors.black),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _authController.user['name'] ?? 'Admin',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text(
                                    'Pemilik Resto',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(LucideIcons.user, color: Colors.grey, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFF1E1E2E),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.utensilsCrossed, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(
                        text: 'Ku',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 16, 12, 16),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                bool isActive = _selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      if (MediaQuery.of(context).size.width <= 900) {
                        Navigator.pop(context);
                      }
                    },
                    leading: Icon(
                      _menuItems[index]['icon'],
                      color: isActive ? Colors.white : Colors.grey[400],
                      size: 20,
                    ),
                    title: Text(
                      _menuItems[index]['label'],
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[400],
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isActive ? AppColors.primary : Colors.transparent,
                  ),
                );
              },
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.all(24),
            child: ListTile(
              onTap: () async {
                await _authController.logout();
                Get.offAllNamed('/login');
              },
              leading: const Icon(LucideIcons.logOut, color: Colors.redAccent, size: 20),
              title: const Text(
                'Keluar',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
