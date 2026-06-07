import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/table_controller.dart';
import 'package:mobile_flutter/models/table.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TableManagementPage extends StatefulWidget {
  const TableManagementPage({super.key});

  @override
  State<TableManagementPage> createState() => _TableManagementPageState();
}

class _TableManagementPageState extends State<TableManagementPage> {
  final TableController controller = Get.find<TableController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Refresh data in case it was skipped during unauthenticated startup
    controller.fetchTables();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1, color: AppColors.slate200),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  _buildSearchRow(),
                  const SizedBox(height: 16),
                  _buildTableData(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          if (isMobile) {
            // Mobile: stack title + buttons vertically
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meja & QR code',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.slate900),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Kelola meja dan QR code untuk pemesanan pelanggan',
                  style: TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadAllQrPdf(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(color: AppColors.slate300),
                        ),
                        icon: const Icon(LucideIcons.download, size: 14, color: AppColors.slate700),
                        label: const Text('Download QR', style: TextStyle(color: AppColors.slate700, fontWeight: FontWeight.w900, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddTableDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        icon: const Icon(LucideIcons.plus, color: Colors.white, size: 14),
                        label: const Text('Tambah Meja', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
          // Desktop/tablet: original side-by-side layout
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meja & QR code',
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.slate900),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kelola meja dan QR code untuk pemesanan pelanggan',
                    style: TextStyle(fontSize: 13, color: AppColors.slate500, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _downloadAllQrPdf(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: AppColors.slate300),
                    ),
                    icon: const Icon(LucideIcons.download, size: 16, color: AppColors.slate700),
                    label: const Text('Download Semua QR', style: TextStyle(color: AppColors.slate700, fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showAddTableDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(LucideIcons.plus, color: Colors.white, size: 16),
                    label: const Text('Tambah Meja', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      int total = controller.tables.length;
      int aktif = controller.tables.where((t) => t.isActive).length;
      int nonaktif = total - aktif;

      return LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 500;
          if (isMobile) {
            // 2x2 grid on mobile
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Total Meja', total.toString(), LucideIcons.layoutGrid, Colors.blue)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Meja Aktif', aktif.toString(), LucideIcons.checkCircle, Colors.green)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Nonaktif', nonaktif.toString(), LucideIcons.xCircle, AppColors.slate400)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Total QR', total.toString(), LucideIcons.qrCode, Colors.orange)),
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              _buildStatCard('Total Meja', total.toString(), LucideIcons.layoutGrid, Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard('Meja Aktif', aktif.toString(), LucideIcons.checkCircle, Colors.green),
              const SizedBox(width: 16),
              _buildStatCard('Meja Nonaktif', nonaktif.toString(), LucideIcons.xCircle, AppColors.slate400),
              const SizedBox(width: 16),
              _buildStatCard('Total QR Code', total.toString(), LucideIcons.qrCode, Colors.orange),
            ],
          );
        },
      );
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 10, color: AppColors.slate500, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.slate900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari meja...',
              hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 13, fontWeight: FontWeight.bold),
              prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.slate400),
              filled: true,
              fillColor: AppColors.slate50,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Obx(() => Text('${controller.tables.length} meja', style: const TextStyle(color: AppColors.slate500, fontWeight: FontWeight.bold, fontSize: 13))),
      ],
    );
  }

  Widget _buildTableData() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
      }

      var filtered = controller.tables.where((t) {
        return t.number.contains(_searchController.text) ||
               (t.name?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
      }).toList();

      if (filtered.isEmpty) {
        return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Tidak ada data meja', style: TextStyle(fontWeight: FontWeight.bold))));
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            // Card-based list for mobile — no horizontal overflow
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _buildTableCard(filtered[index]),
            );
          }

          // Desktop/tablet — original Table widget
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.slate200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.5),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1.5),
                  4: FlexColumnWidth(1.2),
                  5: FlexColumnWidth(0.8),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: AppColors.slate50),
                    children: [
                      _th('MEJA'), _th('QR CODE'), _th('TIPE & KAPASITAS'), _th('STATUS'), _th('DIBUAT'), _th('AKSI', align: TextAlign.center),
                    ],
                  ),
                  ...filtered.map((t) => _buildTableRow(t)).toList(),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  /// Mobile card view for a single table row
  Widget _buildTableCard(TableModel table) {
    final created = table.createdAt;
    final dateStr = created != null ? DateFormat('d MMM yyyy', 'id').format(created) : '-';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: avatar + name + status toggle
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: const BoxDecoration(color: AppColors.slate900, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    table.number,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meja ${table.number}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate900, fontSize: 14)),
                    Text(table.name ?? 'Meja #${table.number}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate400, fontSize: 12)),
                  ],
                ),
              ),
              // Status switch
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    table.isActive ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: table.isActive ? const Color(0xFF10B981) : AppColors.slate400,
                    ),
                  ),
                  Switch(
                    value: table.isActive,
                    onChanged: (val) => controller.toggleTableActive(table.id, val),
                    activeColor: const Color(0xFF10B981),
                    inactiveTrackColor: AppColors.slate200,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.slate100),
          const SizedBox(height: 10),

          // Row 2: type/capacity + date
          Row(
            children: [
              const Icon(LucideIcons.layoutGrid, color: AppColors.slate400, size: 14),
              const SizedBox(width: 6),
              Text(table.type, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate700, fontSize: 12)),
              const SizedBox(width: 4),
              Text('• ${table.capacity} orang', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate500, fontSize: 12)),
              const Spacer(),
              const Icon(LucideIcons.calendar, color: AppColors.slate400, size: 13),
              const SizedBox(width: 4),
              Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate500, fontSize: 11)),
            ],
          ),

          const SizedBox(height: 10),

          // Row 3: QR actions + edit/delete
          Row(
            children: [
              // QR icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(8)),
                child: const Icon(LucideIcons.qrCode, color: AppColors.slate700, size: 16),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showQRModal(table),
                child: const Text('Lihat QR', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFF97316), fontSize: 12)),
              ),
              const Text(' • ', style: TextStyle(color: AppColors.slate300)),
              GestureDetector(
                onTap: () => _downloadQrPdf(table),
                child: const Text('Download', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981), fontSize: 12)),
              ),
              const Spacer(),
              // Edit
              GestureDetector(
                onTap: () => _showAddTableDialog(table: table),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(LucideIcons.edit2, color: Colors.blue, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              // Delete
              GestureDetector(
                onTap: () => _confirmDelete(table),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(LucideIcons.trash2, color: Colors.red, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _th(String label, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Text(
        label,
        textAlign: align,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.slate500, letterSpacing: 1.0),
      ),
    );
  }

  TableRow _buildTableRow(TableModel table) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.slate200)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: AppColors.slate900, shape: BoxShape.circle),
                child: Center(child: Text(table.number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meja ${table.number}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate900, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(table.name ?? 'Meja #${table.number}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate400, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(8)),
                child: const Icon(LucideIcons.qrCode, color: AppColors.slate700, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Scan menu', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate500, fontSize: 11)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showQRModal(table),
                        child: const Text('Lihat QR', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFF97316), fontSize: 12)),
                      ),
                      const Text(' • ', style: TextStyle(color: AppColors.slate300, fontSize: 12)),
                      GestureDetector(
                        onTap: () => _downloadQrPdf(table),
                        child: const Text('Download', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981), fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(LucideIcons.layoutGrid, color: AppColors.slate400, size: 16),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(table.type, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate700, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('${table.capacity} orang', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate500, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Switch(
                value: table.isActive,
                onChanged: (val) => controller.toggleTableActive(table.id, val),
                activeColor: const Color(0xFF10B981),
                inactiveTrackColor: AppColors.slate200,
              ),
              const SizedBox(width: 8),
              Text(
                table.isActive ? 'Aktif' : 'Nonaktif',
                style: TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 12,
                  color: table.isActive ? const Color(0xFF10B981) : AppColors.slate400,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Builder(builder: (context) {
            final created = table.createdAt;
            final day = created != null ? DateFormat('d MMM', 'id').format(created) : '-';
            final year = created != null ? DateFormat('yyyy').format(created) : '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate500, fontSize: 12)),
                if (year.isNotEmpty)
                  Text(year, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate400, fontSize: 11)),
              ],
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Edit button with background
              GestureDetector(
                onTap: () => _showAddTableDialog(table: table),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.15)),
                  ),
                  child: const Icon(LucideIcons.edit2, color: Colors.blue, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              // Delete button with background
              GestureDetector(
                onTap: () => _confirmDelete(table),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.15)),
                  ),
                  child: const Icon(LucideIcons.trash2, color: Colors.red, size: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(String label, bool isActive, VoidCallback onTap, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? color : AppColors.slate200, width: 1.5),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isActive ? color : AppColors.slate400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTableDialog({TableModel? table}) {
    final numberController = TextEditingController(text: table?.number ?? "");
    final capacityController = TextEditingController(text: table?.capacity.toString() ?? "4");
    final nameController = TextEditingController(text: table?.name ?? "");
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

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(table == null ? 'Tambah Meja Baru' : 'Edit Meja', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                      const SizedBox(height: 4),
                      const Text('QR code akan dibuat otomatis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate400)),
                    ],
                  ),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(LucideIcons.x, color: AppColors.slate400)),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nomor Meja', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate700)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: numberController,
                          decoration: InputDecoration(
                            hintText: 'ex: 5',
                            filled: true, fillColor: AppColors.slate50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kapasitas (orang)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate700)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: capacityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '4',
                            filled: true, fillColor: AppColors.slate50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Nama Meja (opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate700)),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'VIP, Meja 5, VIP Room 1, Outdoor 1',
                  filled: true, fillColor: AppColors.slate50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Nama Pemesan (opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate700)),
              const SizedBox(height: 8),
              TextField(
                controller: customerNameController,
                decoration: InputDecoration(
                  hintText: 'Nama orang yang booking meja',
                  filled: true, fillColor: AppColors.slate50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Status Meja', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate700)),
              const SizedBox(height: 10),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(LucideIcons.info, color: Color(0xFF10B981), size: 18),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('SIMPANAN: QR code untuk meja ini dapat diakses pada halaman kelola setelah meja disimpan.', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold, height: 1.5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: AppColors.slate200),
                    ),
                    child: const Text('Batal', style: TextStyle(color: AppColors.slate700, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (numberController.text.isEmpty) {
                        Get.snackbar("Error", "Nomor meja wajib diisi", backgroundColor: Colors.red, colorText: Colors.white);
                        return;
                      }
                      
                      final data = {
                        "number": numberController.text,
                        "name": nameController.text.isNotEmpty ? nameController.text : "Meja ${numberController.text}",
                        "type": "Regular", 
                        "capacity": int.tryParse(capacityController.text) ?? 4,
                        "status": selectedStatus.value == 'Booking' ? 'reserved' : (selectedStatus.value == 'Nonaktif' ? 'Nonaktif' : 'available'),
                        "customer_name": customerNameController.text,
                        "is_active": selectedStatus.value == 'Aktif',
                      };

                      final result = table == null ? await controller.createTable(data) : await controller.updateTable(table.id, data);

                      if (result['success']) {
                        Get.back();
                        Get.snackbar("Sukses", "Data meja berhasil disimpan", backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
                      } else {
                        Get.snackbar("Gagal", result['message'], backgroundColor: Colors.red, colorText: Colors.white);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(table == null ? 'Tambah Meja' : 'Simpan', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// URL yang di-encode di QR — mengarahkan customer ke halaman menu dengan nomor meja
  String _qrUrl(TableModel table) =>
      'https://menuku.icaadrm.my.id/menu?table=${table.number}';

  /// Generate PDF berisi QR code + info meja, lalu buka print/download dialog
  Future<void> _downloadQrPdf(TableModel table) async {
    final qrUrl = _qrUrl(table);

    // Render QR sebagai image bytes
    final qrImage = await QrPainter(
      data: qrUrl,
      version: QrVersions.auto,
      gapless: true,
      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0F172A)),
      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0F172A)),
    ).toImageData(600);
    final Uint8List qrBytes = qrImage!.buffer.asUint8List();

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) => pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('MenuKu', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('F97316'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'Meja ${table.number}${table.name != null && table.name!.isNotEmpty ? ' • ${table.name}' : ''}',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('E2E8F0'), width: 2),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Image(pw.MemoryImage(qrBytes), width: 180, height: 180),
            ),
            pw.SizedBox(height: 14),
            pw.Text('Scan untuk memesan', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(qrUrl, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            pw.SizedBox(height: 10),
            pw.Text(
              '${table.type}  •  ${table.capacity} orang',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  void _showQRModal(TableModel table) {
    final qrUrl = _qrUrl(table);
    final created = table.createdAt;
    final dateStr = created != null ? DateFormat('d MMM yyyy', 'id').format(created) : '-';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meja ${table.number}${table.name != null && table.name!.isNotEmpty ? ' • ${table.name}' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.slate900),
                        ),
                        const Text('Scan untuk memesan', style: TextStyle(fontSize: 12, color: AppColors.slate400, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(LucideIcons.x, size: 20, color: AppColors.slate400),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // QR Code — dibuat langsung oleh qr_flutter, mengarah ke URL menu
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.slate200, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: qrUrl,
                        version: QrVersions.auto,
                        size: 200,
                        gapless: true,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0F172A)),
                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Meja ${table.number}',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // URL label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.link, size: 13, color: AppColors.slate400),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          qrUrl,
                          style: const TextStyle(fontSize: 10, color: AppColors.slate500, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Detail
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    children: [
                      _buildDetailRow('Tipe Meja', table.type),
                      _buildDetailRow('Kapasitas', '${table.capacity} orang'),
                      _buildDetailRow('Status', table.isActive ? 'Aktif' : 'Nonaktif',
                          color: table.isActive ? const Color(0xFF10B981) : AppColors.slate400),
                      _buildDetailRow('Dibuat', dateStr),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () { Get.back(); _downloadQrPdf(table); },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: const Icon(LucideIcons.download, size: 16, color: Colors.white),
                        label: const Text('Download QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(qrUrl);
                          if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: AppColors.slate200),
                        ),
                        icon: const Icon(LucideIcons.externalLink, size: 16, color: AppColors.slate700),
                        label: const Text('Buka Menu', style: TextStyle(color: AppColors.slate700, fontWeight: FontWeight.w900, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── QR URL & PDF helpers ─────────────────────────────────────────────────

  /// Generate + print/download PDF semua meja aktif
  Future<void> _downloadAllQrPdf() async {
    final activeTables = controller.tables.where((t) => t.isActive).toList();
    if (activeTables.isEmpty) {
      Get.snackbar('Tidak ada meja', 'Belum ada meja aktif untuk didownload QR-nya.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    Get.snackbar('Membuat PDF...', 'Mohon tunggu sebentar.',
        backgroundColor: AppColors.primary, colorText: Colors.white, duration: const Duration(seconds: 2));

    final doc = pw.Document();

    for (final table in activeTables) {
      final qrUrl = _qrUrl(table);
      final qrImage = await QrPainter(
        data: qrUrl,
        version: QrVersions.auto,
        gapless: true,
        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0F172A)),
        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0F172A)),
      ).toImageData(600);
      final Uint8List qrBytes = qrImage!.buffer.asUint8List();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a6,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context ctx) => pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('MenuKu', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('F97316'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  'Meja ${table.number}${table.name != null && table.name!.isNotEmpty ? ' • ${table.name}' : ''}',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex('E2E8F0'), width: 2),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Image(pw.MemoryImage(qrBytes), width: 180, height: 180),
              ),
              pw.SizedBox(height: 14),
              pw.Text('Scan untuk memesan', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text(qrUrl, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
      name: 'semua-qr-meja.pdf',
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color ?? AppColors.slate900)),
        ],
      ),
    );
  }

  void _confirmDelete(TableModel table) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(LucideIcons.trash2, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 24),
              const Text('Hapus Meja?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              const SizedBox(height: 12),
              Text('Meja ${table.number} akan dihapus permanen. QR code yang sebelumnya dicetak tidak dapat dipakai kembali.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.slate500, fontSize: 13, height: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: AppColors.slate200)),
                      child: const Text('Batal', style: TextStyle(color: AppColors.slate700, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        bool success = await controller.deleteTable(table.id);
                        if (success) {
                          Get.back();
                          Get.snackbar("Sukses", "Meja berhasil dihapus", backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                      child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
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