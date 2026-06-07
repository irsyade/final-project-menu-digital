import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/product_controller.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductController controller = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 360 ? 16 : 24,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Web-Style Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Eksekutif',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.slate900,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Performa dapur secara real-time.',
                          style: TextStyle(
                            color: AppColors.slate500,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.slate200),
                      boxShadow: [AppDesign.shadow],
                    ),
                    child: Icon(LucideIcons.refreshCw, size: 20, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Date Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.calendar, size: 14, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.slate600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Web-Style Stats Grid
              Obx(() {
                final screenWidth = MediaQuery.of(context).size.width;
                final isNarrow = screenWidth < 360;

                if (isNarrow) {
                  return Column(
                    children: [
                      _buildWebStatCard(
                        title: 'TOTAL KATEGORI',
                        value: '8',
                        icon: LucideIcons.layers,
                        color: Colors.indigo,
                        subtitle: 'Basis Sistem',
                        fullWidth: true,
                      ),
                      const SizedBox(height: 16),
                      _buildWebStatCard(
                        title: 'PRODUK AKTIF',
                        value: '${controller.products.length}',
                        icon: LucideIcons.package,
                        color: Colors.amber,
                        subtitle: 'Inventaris',
                        fullWidth: true,
                      ),
                      const SizedBox(height: 16),
                      _buildWebStatCard(
                        title: 'PESANAN BERHASIL',
                        value: '124',
                        icon: LucideIcons.shoppingCart,
                        color: const Color(0xFF10B981),
                        subtitle: 'Pencatatan Pendapatan',
                        fullWidth: true,
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildWebStatCard(
                            title: 'TOTAL KATEGORI',
                            value: '8', // Dummy for now
                            icon: LucideIcons.layers,
                            color: Colors.indigo,
                            subtitle: 'Basis Sistem',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildWebStatCard(
                            title: 'PRODUK AKTIF',
                            value: '${controller.products.length}',
                            icon: LucideIcons.package,
                            color: Colors.amber,
                            subtitle: 'Inventaris',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildWebStatCard(
                      title: 'PESANAN BERHASIL',
                      value: '124', // Dummy for now
                      icon: LucideIcons.shoppingCart,
                      color: const Color(0xFF10B981),
                      subtitle: 'Pencatatan Pendapatan',
                      fullWidth: true,
                    ),
                  ],
                );
              }),

              const SizedBox(height: 32),

              // Tindakan Instan (Dark Card)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.slate900,
                  borderRadius: BorderRadius.circular(AppDesign.radiusXL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.slate900.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tindakan Instan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lompat cepat ke modul manajemen.',
                      style: TextStyle(
                        color: AppColors.slate400,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final useColumn = MediaQuery.of(context).size.width < 360;
                        if (useColumn) {
                          return Column(
                            children: [
                              _buildQuickAction(
                                icon: LucideIcons.plus,
                                label: 'Tambah Produk',
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 12),
                              _buildQuickAction(
                                icon: LucideIcons.qrCode,
                                label: 'Kelola Meja',
                                color: Colors.blue,
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: _buildQuickAction(
                                icon: LucideIcons.plus,
                                label: 'Tambah Produk',
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickAction(
                                icon: LucideIcons.qrCode,
                                label: 'Kelola Meja',
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Service Status
              Text(
                'Status Layanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 16),
              _buildServiceStatusTile(
                icon: LucideIcons.globe,
                title: 'Menu Publik',
                subtitle: 'Akses Global',
                status: 'Aktif',
                color: Color(0xFF10B981),
              ),
              const SizedBox(height: 12),
              _buildServiceStatusTile(
                icon: LucideIcons.smartphone,
                title: 'API Mobile',
                subtitle: 'Jembatan Flutter',
                status: 'Stabil',
                color: Colors.blue,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radiusXL),
        border: Border.all(color: AppColors.slate200.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.slate400,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppColors.slate900,
                  letterSpacing: -1,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Aktif',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({required IconData icon, required String label, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatusTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate900),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppColors.slate400, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              status,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}