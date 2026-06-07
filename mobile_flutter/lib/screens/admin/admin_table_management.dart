import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/table_controller.dart';
import 'package:mobile_flutter/models/table.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminTableManagementPage extends StatefulWidget {
  const AdminTableManagementPage({super.key});

  @override
  State<AdminTableManagementPage> createState() => _AdminTableManagementPageState();
}

class _AdminTableManagementPageState extends State<AdminTableManagementPage> {
  final TableController controller = Get.find<TableController>();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    controller.fetchTables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await controller.fetchTables();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildSummaryCards(),
                  _buildSearchAndFilters(),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    var filteredTables = controller.tables.where((t) {
                      bool matchesSearch = t.number.contains(_searchController.text) || 
                                           (t.customerName?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false) ||
                                           (t.name?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
                      
                      bool matchesFilter = true;
                      if (_selectedFilter == 'Aktif') {
                        matchesFilter = t.isActive;
                      } else if (_selectedFilter == 'Nonaktif') {
                        matchesFilter = !t.isActive;
                      } else if (_selectedFilter == 'Booking') {
                        matchesFilter = t.status == 'reserved';
                      }
                      
                      return matchesSearch && matchesFilter;
                    }).toList();

                    if (filteredTables.isEmpty) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: Text('Tidak ada meja.', style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.bold))),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 160),
                      itemCount: filteredTables.length,
                      itemBuilder: (context, index) => _buildTableCard(filteredTables[index]),
                    );
                  }),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white.withOpacity(0.9),
              padding: const EdgeInsets.only(top: 8),
              child: _buildBottomActions(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Text('Meja & QR Code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.slate900)),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      int total = controller.tables.length;
      int aktif = controller.tables.where((t) => t.isActive).length;
      int nonaktif = total - aktif;

      return LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = MediaQuery.of(context).size.width > 600;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildSummaryCard('Total Meja', total.toString(), LucideIcons.layoutGrid, Colors.blue, isTablet),
                const SizedBox(width: 8),
                _buildSummaryCard('Meja Aktif', aktif.toString(), LucideIcons.checkCircle2, Colors.green, isTablet),
                const SizedBox(width: 8),
                _buildSummaryCard('Meja Nonaktif', nonaktif.toString(), LucideIcons.info, Colors.grey, isTablet),
                const SizedBox(width: 8),
                _buildSummaryCard('Total QR Code', total.toString(), LucideIcons.qrCode, Colors.orange, isTablet),
              ],
            ),
          );
        }
      );
    });
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color, bool isTablet) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, size: isTablet ? 14 : 16, color: color),
            const SizedBox(height: 8),
            Text(
              value, 
              style: TextStyle(fontSize: isTablet ? 14 : 16, fontWeight: FontWeight.w900, color: AppColors.slate900),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label, 
              style: TextStyle(fontSize: isTablet ? 7 : 8, color: AppColors.slate400, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari nomor pesanan atau meja...',
              hintStyle: const TextStyle(color: AppColors.slate300, fontSize: 13, fontWeight: FontWeight.bold),
              prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.slate300),
              filled: true,
              fillColor: AppColors.slate50,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: ['Semua', 'Aktif', 'Nonaktif', 'Booking'].map((f) {
              bool isActive = _selectedFilter == f;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isActive ? AppColors.primary : AppColors.slate200),
                  ),
                  child: Text(f, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isActive ? Colors.white : AppColors.slate400)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTableCard(TableModel table) {
    Color statusBgColor = const Color(0xFFECFDF5);
    Color statusTextColor = const Color(0xFF047857);
    String statusLabel = 'Tersedia';

    if (table.status == 'occupied') {
      statusBgColor = const Color(0xFFFFFBEB);
      statusTextColor = const Color(0xFFB45309);
      statusLabel = 'Terisi';
    } else if (table.status == 'reserved') {
      statusBgColor = const Color(0xFFEFF6FF);
      statusTextColor = const Color(0xFF1D4ED8);
      statusLabel = 'Dipesan';
    }

    return Opacity(
      opacity: table.isActive ? 1.0 : 0.75,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)), // slate200
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header (Gray background)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC), // slate50/50
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            table.type.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF64748B), // slate500
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Meja ${table.number}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Color(0xFF0F172A), // slate900
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          table.name != null && table.name!.isNotEmpty ? table.name! : 'Tanpa Label Khusus',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8), // slate400
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Header Actions (Row of 4 buttons)
                  Row(
                    children: [
                      _buildHeaderAction(
                        icon: LucideIcons.qrCode,
                        onTap: () => _showQRModal(table),
                        tooltip: 'Lihat QR',
                      ),
                      const SizedBox(width: 6),
                      _buildHeaderAction(
                        icon: LucideIcons.download,
                        onTap: () => _downloadQrPdf(table),
                        tooltip: 'Download PDF',
                      ),
                      const SizedBox(width: 6),
                      _buildHeaderAction(
                        icon: LucideIcons.pencil,
                        onTap: () => _showAddTableDialog(table: table),
                        tooltip: 'Edit Meja',
                        hoverColor: Colors.blue,
                      ),
                      const SizedBox(width: 6),
                      _buildHeaderAction(
                        icon: LucideIcons.trash2,
                        onTap: () => _confirmDelete(table),
                        tooltip: 'Hapus Meja',
                        hoverColor: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Card Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Capacity & Status Info
                  Row(
                    children: [
                      // Capacity Info
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: const Icon(LucideIcons.users, size: 16, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'KAPASITAS',
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.8),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${table.capacity} Orang',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Status Info
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: const Icon(LucideIcons.info, size: 16, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'STATUS',
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.8),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusBgColor,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: statusTextColor.withOpacity(0.1)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: statusTextColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        statusLabel.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9, 
                                          fontWeight: FontWeight.w900, 
                                          color: statusTextColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 16),
                  
                  // Quick Action Status
                  const Text(
                    'UBAH STATUS CEPAT',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickStatusButton(
                          label: 'BUKA',
                          isActive: table.status == 'available',
                          onTap: () => controller.updateTableStatus(table.id, 'available'),
                          activeColor: const Color(0xFF10B981), // emerald-500
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickStatusButton(
                          label: 'ISI',
                          isActive: table.status == 'occupied',
                          onTap: () => controller.updateTableStatus(table.id, 'occupied'),
                          activeColor: const Color(0xFFF59E0B), // amber-500
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickStatusButton(
                          label: 'PESAN',
                          isActive: table.status == 'reserved',
                          onTap: () => controller.updateTableStatus(table.id, 'reserved'),
                          activeColor: const Color(0xFF3B82F6), // blue-500
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    Color? hoverColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 14, color: hoverColor ?? const Color(0xFF94A3B8)),
        ),
      ),
    );
  }

  Widget _buildQuickStatusButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? activeColor : const Color(0xFFE2E8F0),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isActive ? Colors.white : const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: ElevatedButton.icon(
        onPressed: () => _showAddTableDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        icon: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
        label: const Text('Tambah Meja', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }

  void _showAddTableDialog({TableModel? table}) {
    final numberController = TextEditingController(text: table?.number ?? "");
    final capacityController = TextEditingController(text: table?.capacity?.toString() ?? "");
    final customerNameController = TextEditingController(text: table?.customerName ?? "");
    
    String initialStatus = 'Aktif';
    if (table != null) {
      if (table.status == 'reserved' || table.status == 'Booking') {
        initialStatus = 'Booking';
      } else if (table.status == 'occupied') {
        initialStatus = 'Aktif';
      } else if (!table.isActive || table.status == 'Nonaktif') {
        initialStatus = 'Nonaktif';
      }
    }
    var selectedStatus = initialStatus.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(table == null ? 'Tambah Meja' : 'Edit Meja', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(LucideIcons.x, size: 20)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Nomor Meja *'), _buildTextField(numberController, '1', isNumber: true)])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Kapasitas *'), _buildTextField(capacityController, '4', isNumber: true, suffix: 'orang')])),
                ],
              ),
              const SizedBox(height: 20),
              _buildLabel('Nama Pemesan (opsional)'),
              _buildTextField(customerNameController, 'Nama orang yang booking meja'),
              const SizedBox(height: 24),
              _buildLabel('Status Meja'),
              Obx(() => Row(
                children: [
                  _buildStatusButton('Aktif', selectedStatus.value == 'Aktif', () => selectedStatus.value = 'Aktif', Colors.green),
                  const SizedBox(width: 8),
                  _buildStatusButton('Nonaktif', selectedStatus.value == 'Nonaktif', () => selectedStatus.value = 'Nonaktif', AppColors.slate400),
                  const SizedBox(width: 8),
                  _buildStatusButton('Booking', selectedStatus.value == 'Booking', () => selectedStatus.value = 'Booking', Colors.orange),
                ],
              )),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(LucideIcons.info, size: 14, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Setelah menyimpan, QR Code akan digenerate otomatis', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final data = {
                    "number": numberController.text,
                    "capacity": int.tryParse(capacityController.text) ?? 2,
                    "customer_name": customerNameController.text,
                    "status": selectedStatus.value == 'Booking' ? 'reserved' : (selectedStatus.value == 'Nonaktif' ? 'Nonaktif' : 'available'),
                    "type": "Regular",
                    "is_active": selectedStatus.value != 'Nonaktif',
                  };
                  
                  final result = table == null ? await controller.createTable(data) : await controller.updateTable(table.id, data);
                  if (result['success']) {
                    Get.back();
                    Get.snackbar("Sukses", "Meja berhasil disimpan", backgroundColor: AppColors.success, colorText: Colors.white);
                  } else {
                    Get.snackbar("Gagal", result['message'], backgroundColor: Colors.red, colorText: Colors.white);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                child: const Text('Simpan & Generate QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStatusButton(String label, bool isActive, VoidCallback onTap, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? color : AppColors.slate200),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isActive ? color : AppColors.slate300))),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.slate700)));
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, String? suffix}) {
    return TextField(
      controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: AppColors.slate300, fontSize: 13, fontWeight: FontWeight.bold),
        filled: true, fillColor: AppColors.slate50, contentPadding: const EdgeInsets.all(16),
        suffixText: suffix, suffixStyle: const TextStyle(color: AppColors.slate400, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Future<void> _downloadQrPdf(TableModel table) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Meja ${table.number}',
                  style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  table.name != null && table.name!.isNotEmpty ? table.name! : 'QR Code Pemesanan',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 40),
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300, width: 2),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
                  ),
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: 'https://menuku.icaadrm.my.id/menu?table=${table.number}',
                    width: 200,
                    height: 200,
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  'Scan untuk melihat menu dan memesan',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'QR_Meja_${table.number}.pdf');
  }

  void _showQRModal(TableModel table) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Meja ${table.number}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const Text('QR Code Pemesanan', style: TextStyle(fontSize: 12, color: AppColors.slate400, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.slate200, width: 2),
                ),
                child: QrImageView(
                  data: 'https://menuku.icaadrm.my.id/menu?table=${table.number}',
                  version: QrVersions.auto,
                  size: 180,
                  gapless: true,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0F172A)),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0F172A)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Meja ${table.number}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              const Text('Scan untuk melihat menu', style: TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              _buildDetailRow('Tipe Meja', table.type),
              _buildDetailRow('Kapasitas', '${table.capacity} orang'),
              _buildDetailRow(
                'Status',
                table.status == 'available'
                    ? 'Tersedia'
                    : table.status == 'occupied'
                        ? 'Terisi'
                        : 'Dipesan',
                color: table.status == 'available'
                    ? AppColors.success
                    : table.status == 'occupied'
                        ? Colors.orange
                        : Colors.blue,
              ),
              _buildDetailRow('Dibuat', '12 Jan 2025'),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadQrPdf(table),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: AppColors.primary),
                      ),
                      icon: Icon(LucideIcons.download, size: 16, color: AppColors.primary),
                      label: Text('Download PDF', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slate400, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color ?? AppColors.slate900)),
        ],
      ),
    );
  }

  void _confirmDelete(TableModel table) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Hapus Meja?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 16),
              const Text('QR code meja ini tidak bisa digunakan lagi setelah dihapus. Tindakan ini tidak dapat diturunkan.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.slate500, fontSize: 13, height: 1.5)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: AppColors.slate200)),
                      child: const Text('Batal', style: TextStyle(color: AppColors.slate500, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        bool success = await controller.deleteTable(table.id);
                        if (success) {
                          Get.back();
                          Get.snackbar("Sukses", "Meja berhasil dihapus", backgroundColor: AppColors.primary, colorText: Colors.white);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                      child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}