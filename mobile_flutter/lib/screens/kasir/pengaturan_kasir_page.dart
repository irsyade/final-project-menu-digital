import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/settings_controller.dart';
import 'package:mobile_flutter/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengaturanKasirPage extends StatefulWidget {
  const PengaturanKasirPage({super.key});

  @override
  State<PengaturanKasirPage> createState() => _PengaturanKasirPageState();
}

class _PengaturanKasirPageState extends State<PengaturanKasirPage> {
  final SettingsController settingsController = Get.put(SettingsController());
  final AuthController authController = Get.find<AuthController>();

  // Form Profil Akun
  late final TextEditingController _namaAkunController;
  late final TextEditingController _emailController;
  late final TextEditingController _shiftController;
  final _pinController = TextEditingController(text: "1234");

  @override
  void initState() {
    super.initState();
    final name = authController.user['name']?.toString() ?? 'Kasir';
    final email = authController.user['email']?.toString() ?? 'kasir@restoran.com';
    final role = authController.role.value.isNotEmpty
        ? authController.role.value[0].toUpperCase() + authController.role.value.substring(1)
        : 'Kasir';

    _namaAkunController = TextEditingController(text: name);
    _emailController = TextEditingController(text: email);
    _shiftController = TextEditingController(text: role);
    
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      // Printer settings
      _selectedPrinter = prefs.getString('printer_name') ?? "POS-58 (USB)";
      _paper80mm = prefs.getBool('printer_paper_80mm') ?? false;
      _autoPrint = prefs.getBool('printer_auto_print') ?? true;
      _showLogoOnReceipt = prefs.getBool('printer_show_logo') ?? true;
      _showCashierName = prefs.getBool('printer_show_cashier') ?? true;

      // Tax settings
      _pajakActive = prefs.getBool('tax_active') ?? true;
      _pajakController.text = prefs.getString('tax_rate') ?? "11";
      _biayaLayananActive = prefs.getBool('service_active') ?? false;
      _biayaLayananController.text = prefs.getString('service_rate') ?? "5";
      _bulatkanTotal = prefs.getBool('tax_round_total') ?? true;

      // Security settings
      _autoLock = prefs.getBool('security_autolock') ?? false;
      _authVoid = prefs.getBool('security_authvoid') ?? true;
      _pinLaporan = prefs.getBool('security_pinreport') ?? true;
      _ringkasanShift = prefs.getBool('security_shiftsummary') ?? true;
    });

    // Payment settings from server settings
    if (settingsController.settings.isEmpty) {
      await settingsController.fetchSettings();
    }
    
    final serverSettings = settingsController.settings;
    if (serverSettings.isNotEmpty) {
      setState(() {
        _payCash = serverSettings['is_cash_active'] == 1 || serverSettings['is_cash_active'] == true || serverSettings['is_cash_active'] == '1';
        _payQris = serverSettings['is_qris_active'] == 1 || serverSettings['is_qris_active'] == true || serverSettings['is_qris_active'] == '1';
        _payTransfer = serverSettings['is_transfer_active'] == 1 || serverSettings['is_transfer_active'] == true || serverSettings['is_transfer_active'] == '1';
      });
    }
  }

  // Form Pajak & Biaya
  bool _pajakActive = true;
  final _pajakController = TextEditingController(text: "11");
  bool _biayaLayananActive = false;
  final _biayaLayananController = TextEditingController(text: "5");
  bool _bulatkanTotal = true;

  // Metode Pembayaran
  bool _payCash = true;
  bool _payQris = true;
  bool _payTransfer = false;

  // Keamanan & Akses
  bool _autoLock = false;
  bool _authVoid = true;
  bool _pinLaporan = true;
  bool _ringkasanShift = true;

  // Printer
  String _selectedPrinter = "POS-58 (USB)";
  bool _paper80mm = false; // false = 58mm, true = 80mm
  bool _autoPrint = true;
  bool _showLogoOnReceipt = true;
  bool _showCashierName = true;

  @override
  void dispose() {
    _namaAkunController.dispose();
    _emailController.dispose();
    _shiftController.dispose();
    _pinController.dispose();
    _pajakController.dispose();
    _biayaLayananController.dispose();
    super.dispose();
  }


  void _showPreviewStruk() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Preview Struk", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                // Kertas Struk
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.slate200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Obx(() {
                    final settingsController = Get.find<SettingsController>();
                    final restaurantName = settingsController.settings['site_name']?.toString() ?? 'POS Restoran';
                    final restaurantAddress = settingsController.settings['address']?.toString() ?? 'Jl. Merdeka No. 123, Jakarta';
                    final restaurantPhone = settingsController.settings['phone']?.toString() ?? '021-1234567';
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_showLogoOnReceipt) ...[
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(LucideIcons.coffee, color: Colors.white, size: 20),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(restaurantAddress, style: const TextStyle(fontSize: 10)),
                        if (restaurantPhone.isNotEmpty)
                          Text("Telp: $restaurantPhone", style: const TextStyle(fontSize: 10)),
                        const SizedBox(height: 12),
                        const Text("--------------------------------", style: TextStyle(fontSize: 10)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("No: INV-001", style: TextStyle(fontSize: 10)),
                            Text("21/05/2026 13:00", style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                        if (_showCashierName)
                          Align(
                            alignment: Alignment.centerLeft, 
                            child: Text("Kasir: ${_namaAkunController.text}", style: const TextStyle(fontSize: 10))
                          ),
                        const SizedBox(height: 8),
                        const Text("--------------------------------", style: TextStyle(fontSize: 10)),
                        const SizedBox(height: 8),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("2x Nasi Goreng", style: TextStyle(fontSize: 10)),
                            Text("Rp 50.000", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("1x Es Teh Manis", style: TextStyle(fontSize: 10)),
                            Text("Rp 5.000", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text("--------------------------------", style: TextStyle(fontSize: 10)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("Subtotal", style: TextStyle(fontSize: 10)),
                            Text("Rp 55.000", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        if (_pajakActive)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("PPN (${_pajakController.text}%)", style: const TextStyle(fontSize: 10)),
                              const Text("Rp 6.050", style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        if (_biayaLayananActive)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Service (${_biayaLayananController.text}%)", style: const TextStyle(fontSize: 10)),
                              const Text("Rp 2.750", style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        const SizedBox(height: 8),
                        const Text("--------------------------------", style: TextStyle(fontSize: 10)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("TOTAL", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text("Rp 63.800", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text("Terima Kasih", style: TextStyle(fontSize: 10)),
                        const Text("Selamat Datang Kembali", style: TextStyle(fontSize: 10)),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text("Tutup Preview", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isWide = screenWidth > 800;
    final hPad = screenWidth < 400 ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pengaturan", style: GoogleFonts.outfit(color: AppColors.slate900, fontWeight: FontWeight.bold, fontSize: 18)),
            Text("Sesuaikan fitur aplikasi kasir", style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 11)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(hPad),
        child: isWide 
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildLeftColumn()),
                const SizedBox(width: 20),
                Expanded(child: _buildRightColumn()),
              ],
            )
          : Column(
              children: [
                _buildLeftColumn(),
                const SizedBox(height: 20),
                _buildRightColumn(),
              ],
            ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        _buildProfilAkunCard(),
        const SizedBox(height: 16),
        _buildPrinterStrukCard(),
        const SizedBox(height: 16),
        _buildPajakBiayaCard(),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      children: [
        _buildShiftJadwalCard(),
        const SizedBox(height: 16),
        _buildMetodePembayaranCard(),
        const SizedBox(height: 16),
        _buildKeamananAksesCard(),
      ],
    );
  }

  // --- CARDS KIRI ---

  Widget _buildProfilAkunCard() {
    return _buildCard(
      title: "Profil Akun",
      child: Column(
        children: [
          // Avatar centered on mobile
          Center(
            child: Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.user, color: AppColors.primary, size: 28),
            ),
          ),
          const SizedBox(height: 16),
          _buildCompactTextField("Nama Akun", _namaAkunController, enabled: false),
          const SizedBox(height: 12),
          _buildCompactTextField("Email", _emailController, enabled: false),
          const SizedBox(height: 12),
          _buildCompactTextField("Shift", _shiftController, enabled: false),
        ],
      ),
    );
  }

  Widget _buildPrinterStrukCard() {
    return _buildCard(
      title: "Printer & Struk",
      icon: LucideIcons.printer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Printer Kasir", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.slate200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPrinter,
                isExpanded: true,
                items: ["POS-58 (USB)", "Bluetooth Printer", "Tidak Ada Printer"].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.outfit(fontSize: 14)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPrinter = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text("Jenis Kertas", style: GoogleFonts.outfit(fontSize: 14, color: AppColors.slate700)),
              const Spacer(),
              const Text("58mm"),
              Switch(
                value: _paper80mm,
                onChanged: (val) => setState(() => _paper80mm = val),
                activeColor: AppColors.primary,
              ),
              const Text("80mm"),
            ],
          ),
          const Divider(height: 32),
          _buildToggleRow("Cetak struk otomatis", _autoPrint, (val) => setState(() => _autoPrint = val)),
          _buildToggleRow("Tampilkan logo struk", _showLogoOnReceipt, (val) => setState(() => _showLogoOnReceipt = val)),
          _buildToggleRow("Tampilkan nama kasir", _showCashierName, (val) => setState(() => _showCashierName = val)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showPreviewStruk,
                  icon: Icon(LucideIcons.fileText, size: 16, color: AppColors.primary),
                  label: Text("Preview", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('printer_name', _selectedPrinter);
                    await prefs.setBool('printer_paper_80mm', _paper80mm);
                    await prefs.setBool('printer_auto_print', _autoPrint);
                    await prefs.setBool('printer_show_logo', _showLogoOnReceipt);
                    await prefs.setBool('printer_show_cashier', _showCashierName);
                    Get.snackbar("Tersimpan", "Pengaturan printer & struk berhasil disimpan.", backgroundColor: AppColors.success, colorText: Colors.white);
                  },
                  icon: const Icon(LucideIcons.save, size: 16, color: Colors.white),
                  label: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPajakBiayaCard() {
    return _buildCard(
      title: "Pajak & Biaya",
      child: Column(
        children: [
          // PPN Row
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text("Pajak PPN (%)", style: GoogleFonts.outfit(color: AppColors.slate700)),
                  ),
                  SizedBox(
                    width: 56,
                    child: TextField(
                      controller: _pajakController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  Switch(value: _pajakActive, onChanged: (val) => setState(() => _pajakActive = val), activeColor: AppColors.primary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Service Charge Row
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text("Biaya Layanan (%)", style: GoogleFonts.outfit(color: AppColors.slate700)),
                  ),
                  SizedBox(
                    width: 56,
                    child: TextField(
                      controller: _biayaLayananController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  Switch(value: _biayaLayananActive, onChanged: (val) => setState(() => _biayaLayananActive = val), activeColor: AppColors.primary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildToggleRow("Bulatkan total harga", _bulatkanTotal, (val) => setState(() => _bulatkanTotal = val)),
          const SizedBox(height: 20),
          _buildPrimaryButton("Simpan Info Pajak & Biaya", () async {
             final prefs = await SharedPreferences.getInstance();
             await prefs.setBool('tax_active', _pajakActive);
             await prefs.setString('tax_rate', _pajakController.text);
             await prefs.setBool('service_active', _biayaLayananActive);
             await prefs.setString('service_rate', _biayaLayananController.text);
             await prefs.setBool('tax_round_total', _bulatkanTotal);
             Get.snackbar("Tersimpan", "Informasi pajak & biaya berhasil diperbarui.", backgroundColor: AppColors.success, colorText: Colors.white);
          }),
        ],
      ),
    );
  }

  // --- CARDS KANAN ---

  Widget _buildShiftJadwalCard() {
    return _buildCard(
      title: "Shift & Jadwal",
      child: Column(
        children: [
          Row(
            children: [
              const Icon(LucideIcons.clock, color: AppColors.slate400, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text("Status Shift", style: GoogleFonts.outfit(color: AppColors.slate700))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: const Text("Buka", style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Waktu Login", style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 12)),
              Text("08:00 AM", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Transaksi Shift Ini", style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 12)),
              Text("Rp 1.450.000", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.defaultDialog(
                  title: "Tutup Shift",
                  middleText: "Apakah Anda yakin ingin menutup shift ini? Laporan penjualan akan dicetak.",
                  textConfirm: "Ya, Tutup",
                  textCancel: "Batal",
                  confirmTextColor: Colors.white,
                  buttonColor: AppColors.primary,
                  cancelTextColor: AppColors.slate500,
                  onConfirm: () {
                    Get.back();
                    Get.snackbar("Shift Ditutup", "Laporan telah dicetak dan shift ditutup.", backgroundColor: AppColors.success, colorText: Colors.white);
                  }
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: AppColors.slate700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text("Tutup Shift", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetodePembayaranCard() {
    return _buildCard(
      title: "Metode Pembayaran Aktif",
      child: Column(
        children: [
          _buildPaymentToggle("Tunai / Cash", LucideIcons.banknote, const Color(0xFF10B981), _payCash, (val) => setState(() => _payCash = val)),
          _buildPaymentToggle("QRIS", LucideIcons.qrCode, const Color(0xFFF97316), _payQris, (val) => setState(() => _payQris = val)),
          _buildPaymentToggle("Transfer Bank", LucideIcons.creditCard, const Color(0xFF3B82F6), _payTransfer, (val) => setState(() => _payTransfer = val)),
          const SizedBox(height: 16),
          _buildPrimaryButton("Simpan Metode Pembayaran", () async {
            bool success = await settingsController.saveSettings({
              "payment_methods": {
                "cash": _payCash,
                "qris": _payQris,
                "transfer": _payTransfer,
              }
            });
            if (success) {
              Get.snackbar("Tersimpan", "Metode pembayaran berhasil diperbarui.", backgroundColor: AppColors.success, colorText: Colors.white);
            } else {
              Get.snackbar("Gagal", "Gagal menyimpan metode pembayaran ke server.", backgroundColor: Colors.red, colorText: Colors.white);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildKeamananAksesCard() {
    return _buildCard(
      title: "Keamanan & Akses",
      child: Column(
        children: [
          _buildToggleRow("Kunci layar otomatis (5 mnt)", _autoLock, (val) => setState(() => _autoLock = val)),
          _buildToggleRow("Otorisasi void/pembatalan", _authVoid, (val) => setState(() => _authVoid = val)),
          _buildToggleRow("Pin untuk laporan", _pinLaporan, (val) => setState(() => _pinLaporan = val)),
          _buildToggleRow("Tampilkan ringkasan shift", _ringkasanShift, (val) => setState(() => _ringkasanShift = val)),
          const SizedBox(height: 16),
          _buildPrimaryButton("Simpan Keamanan & Akses", () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('security_autolock', _autoLock);
            await prefs.setBool('security_authvoid', _authVoid);
            await prefs.setBool('security_pinreport', _pinLaporan);
            await prefs.setBool('security_shiftsummary', _ringkasanShift);
            Get.snackbar("Tersimpan", "Pengaturan keamanan & akses berhasil disimpan.", backgroundColor: AppColors.success, colorText: Colors.white);
          }),
        ],
      ),
    );
  }

  // --- HELPERS WIDGET ---

  Widget _buildCard({required String title, required Widget child, IconData? icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
              ],
              Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.slate900)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildCompactTextField(String label, TextEditingController controller, {bool isPassword = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          enabled: enabled,
          style: GoogleFonts.outfit(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: !enabled,
            fillColor: !enabled ? const Color(0xFFF1F5F9) : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.slate200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.slate200)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.slate200)),
          ),
        ),
      ],
    );
  }


  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildToggleRow(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: GoogleFonts.outfit(color: AppColors.slate700))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildPaymentToggle(String title, IconData icon, Color color, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.slate200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }
}