import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/settings_controller.dart';
import 'package:mobile_flutter/controllers/auth_controller.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SettingsController _settingsController = Get.put(SettingsController());
  final AuthController _authController = Get.find<AuthController>();

  // Profil Toko State
  final _nameController = TextEditingController(text: "Warung Makan Pak Budi");
  final _ownerController = TextEditingController(text: "Wahyu Nusantara");
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController(text: "admin@warungnusantara.com");
  final _whatsappController = TextEditingController(text: "0812-3456-7890");
  File? _logoImage;

  // Jam Operasional State
  final List<Map<String, dynamic>> _operationalHours = [
    {'day': 'Sen', 'active': true, 'open': '09:00', 'close': '22:00'},
    {'day': 'Sel', 'active': true, 'open': '09:00', 'close': '22:00'},
    {'day': 'Rab', 'active': true, 'open': '09:00', 'close': '22:00'},
    {'day': 'Kam', 'active': true, 'open': '09:00', 'close': '22:00'},
    {'day': 'Jum', 'active': true, 'open': '09:00', 'close': '22:00'},
    {'day': 'Sab', 'active': true, 'open': '10:00', 'close': '23:00'},
    {'day': 'Min', 'active': false, 'open': '', 'close': ''},
  ];

  // Metode Transaksi State
  final Map<String, bool> _paymentMethods = {
    'qris': true,
    'bri_va': true,
    'transfer': false,
    'cash': true,
    'ovo': false,
  };

  // Tema & Warna State
  String _selectedColor = '#F97316';
  String _selectedTheme = 'Warmth Bistro';

  final List<String> _colors = ['#EF4444', '#F97316', '#F59E0B', '#10B981', '#3B82F6', '#8B5CF6', '#EC4899', '#0F172A'];
  final List<Map<String, dynamic>> _themes = [
    {'name': 'Warmth Bistro', 'desc': 'Hangat & modern', 'color': const Color(0xFFF97316), 'icon': LucideIcons.coffee},
    {'name': 'Fresh Garden', 'desc': 'Segar & natural', 'color': const Color(0xFF10B981), 'icon': LucideIcons.leaf},
    {'name': 'Ocean Blue', 'desc': 'Bersih & elegan', 'color': const Color(0xFF3B82F6), 'icon': LucideIcons.droplet},
    {'name': 'Berry Night', 'desc': 'Gelap & premium', 'color': const Color(0xFF8B5CF6), 'icon': LucideIcons.moon},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _ownerController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // App Bar like header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                if (MediaQuery.of(context).size.width <= 900)
                  IconButton(
                    icon: const Icon(LucideIcons.menu, color: AppColors.primary),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Pengaturan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.slate900),
                    ),
                  ),
                ),
                if (MediaQuery.of(context).size.width <= 900) const SizedBox(width: 48), // Balancing space
              ],
            ),
          ),
          
          // TabBar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.slate400,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'Profil Toko'),
              Tab(text: 'Jam Operasional'),
              Tab(text: 'Metode Transaksi'),
              Tab(text: 'Tema & Warna'),
            ],
          ),
          
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfilTokoTab(),
                _buildJamOperasionalTab(),
                _buildMetodeTransaksiTab(),
                _buildTemaWarnaTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === PROFIL TOKO TAB ===
  Widget _buildProfilTokoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo Section
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.slate200, width: 2, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_logoImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.file(_logoImage!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    )
                  else
                    Obx(() {
                      final logo = _settingsController.settings['site_logo'];
                      if (logo != null && logo.toString().isNotEmpty) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.network(
                            '${ApiConstants.baseUrl}/storage/$logo',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        );
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(LucideIcons.uploadCloud, color: AppColors.primary, size: 28),
                          SizedBox(height: 4),
                          Text('Upload Logo', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                          Text('max 2MB', style: TextStyle(fontSize: 8, color: AppColors.slate400)),
                        ],
                      );
                    }),
                  Positioned(
                    bottom: -8, right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.camera, color: Colors.white, size: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(_nameController.text.isNotEmpty ? _nameController.text : 'Nama Restoran', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const Text('warung-nusantara.menuku.id', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
          
          const SizedBox(height: 32),
          
          // Form Section
          _buildSectionTitle('INFO RESTORAN'),
          _buildTextField('Nama Restoran', _nameController),
          _buildTextField('Nama Pemilik', _ownerController),
          _buildTextField('Alamat Lengkap', _addressController, maxLines: 3),
          _buildTextField('Deskripsi Singkat', _descriptionController, maxLines: 2),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('KONTAK & AKSES'),
          _buildTextField('Email Akun', _emailController),
          _buildTextField('No. WhatsApp', _whatsappController),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _settingsController.saveSettings({
                  'name': _nameController.text,
                  'owner': _ownerController.text,
                  'address': _addressController.text,
                  'description': _descriptionController.text,
                  'email': _emailController.text,
                  'whatsapp': _whatsappController.text,
                }, logoPath: _logoImage?.path);
                Get.snackbar("Sukses", "Profil toko berhasil disimpan!", backgroundColor: AppColors.success, colorText: Colors.white);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await _authController.logout();
                Get.offAllNamed('/login');
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                side: BorderSide(color: Colors.red[100]!),
                backgroundColor: const Color(0xFFFEF2F2),
              ),
              icon: const Icon(LucideIcons.logOut, color: Colors.red, size: 16),
              label: const Text('Keluar Akun', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // === JAM OPERASIONAL TAB ===
  Widget _buildJamOperasionalTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jam Operasional', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.slate900)),
                const SizedBox(height: 4),
                const Text('Atur jam buka tutup setiap hari', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
                const SizedBox(height: 32),
                
                ..._operationalHours.map((day) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    children: [
                      SizedBox(width: 40, child: Text(day['day'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate700))),
                      Switch(
                        value: day['active'],
                        onChanged: (val) {
                          setState(() {
                            day['active'] = val;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.success,
                      ),
                      const SizedBox(width: 16),
                      if (day['active']) ...[
                        Expanded(child: _buildTimeField(day['open'], (val) => day['open'] = val)),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('-', style: TextStyle(color: AppColors.slate400))),
                        Expanded(child: _buildTimeField(day['close'], (val) => day['close'] = val)),
                      ] else ...[
                        const Expanded(child: Center(child: Text('Tutup', style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.bold)))),
                      ],
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ),
        
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: const [
                    Icon(LucideIcons.info, size: 16, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(child: Text('Jam operasional akan ditampilkan di halaman menu digital pelanggan kamu.', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _settingsController.saveSettings({'operational_hours': _operationalHours});
                    Get.snackbar("Sukses", "Jam operasional berhasil disimpan!", backgroundColor: AppColors.success, colorText: Colors.white);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: const Text('Simpan Jam Operasional', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // === METODE TRANSAKSI TAB ===
  Widget _buildMetodeTransaksiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Metode Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.slate900)),
          const SizedBox(height: 4),
          const Text('Aktifkan metode yang tersedia di restoran kamu', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
          const SizedBox(height: 24),
          
          _buildPaymentMethodTile('QRIS', 'GoPay, OVO, Dana, ShopeePay', LucideIcons.qrCode, const Color(0xFFF97316), 'qris'),
          _buildPaymentMethodTile('BRI Virtual Account', 'Transfer via BRI', LucideIcons.creditCard, const Color(0xFFEF4444), 'bri_va'),
          _buildPaymentMethodTile('Transfer Bank', 'BCA, Mandiri, BNI', LucideIcons.landmark, const Color(0xFF3B82F6), 'transfer'),
          _buildPaymentMethodTile('Tunai / Cash', 'Pembayaran langsung di kasir', LucideIcons.banknote, const Color(0xFF10B981), 'cash'),
          _buildPaymentMethodTile('OVO', 'Dompet digital OVO', LucideIcons.wallet, const Color(0xFF8B5CF6), 'ovo'),
          
          const SizedBox(height: 32),
          
          const Text('Biaya Transaksi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.slate900)),
          const SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(border: Border.all(color: AppColors.slate100), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Expanded(flex: 2, child: Text('Metode', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate500))),
                      Expanded(child: Text('Biaya', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate500))),
                      SizedBox(width: 16),
                      SizedBox(width: 50, child: Text('Status', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate500))),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.slate100),
                _buildFeeRow('QRIS', '0.7%'),
                _buildFeeRow('BRI Virtual Account', '4.000'),
                _buildFeeRow('Transfer Bank', '5.000'),
                _buildFeeRow('Tunai / Cash', 'Gratis'),
                _buildFeeRow('OVO', '1.5%'),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _settingsController.saveSettings({'payment_methods': _paymentMethods});
                Get.snackbar("Sukses", "Metode transaksi berhasil disimpan!", backgroundColor: AppColors.success, colorText: Colors.white);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: const Text('Simpan Metode Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  // === TEMA & WARNA TAB ===
  Widget _buildTemaWarnaTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tema & Warna', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.slate900)),
                const SizedBox(height: 4),
                const Text('Sesuaikan tampilan menu digital kamu', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
                const SizedBox(height: 32),
                
                const Text('Skema Warna', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.slate900)),
                const SizedBox(height: 4),
                const Text('Warna utama brand restoran kamu', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 12, runSpacing: 12,
                  children: _colors.map((colorHex) {
                    bool isSelected = _selectedColor == colorHex;
                    Color color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = colorHex),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        child: isSelected ? const Icon(LucideIcons.check, color: Colors.white, size: 20) : null,
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                const Text('Preview Warna Terpilih', style: TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity, height: 40,
                  decoration: BoxDecoration(color: Color(int.parse(_selectedColor.replaceAll('#', '0xFF'))), borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text(_selectedColor, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
                
                const SizedBox(height: 32),
                const Text('Pilihan Tampilan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.slate900)),
                const SizedBox(height: 16),
                
                ..._themes.map((theme) {
                  bool isSelected = _selectedTheme == theme['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTheme = theme['name']),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? theme['color'].withOpacity(0.05) : Colors.white,
                        border: Border.all(color: isSelected ? theme['color'] : AppColors.slate200, width: isSelected ? 2 : 1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: theme['color'], borderRadius: BorderRadius.circular(12)),
                            child: Icon(theme['icon'], color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(theme['name'], style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.slate900)),
                                Text(theme['desc'], style: const TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: theme['color'], shape: BoxShape.circle),
                              child: const Icon(LucideIcons.check, color: Colors.white, size: 12),
                            )
                          else
                            Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.slate300))),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _settingsController.saveSettings({
                  'color': _selectedColor,
                  'theme': _selectedTheme,
                });
                Get.snackbar("Sukses", "Tema & Warna berhasil diterapkan!", backgroundColor: AppColors.success, colorText: Colors.white);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: const Text('Terapkan Tema', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }

  // === HELPERS ===
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 12, color: AppColors.slate400, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate700)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.slate50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField(String initialValue, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(12)),
      child: Text(initialValue, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPaymentMethodTile(String title, String subtitle, IconData icon, Color iconBg, String key) {
    bool isActive = _paymentMethods[key] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: AppColors.slate200), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconBg, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.slate900)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (val) {
              setState(() {
                _paymentMethods[key] = val;
              });
            },
            activeColor: Colors.white,
            activeTrackColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String method, String fee) {
    // Map to key
    String key = '';
    if (method.contains('QRIS')) key = 'qris';
    else if (method.contains('BRI')) key = 'bri_va';
    else if (method.contains('Transfer')) key = 'transfer';
    else if (method.contains('Tunai')) key = 'cash';
    else if (method.contains('OVO')) key = 'ovo';
    
    bool isActive = _paymentMethods[key] ?? false;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(method, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate700))),
          Expanded(child: Text(fee, textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fee == 'Gratis' ? AppColors.success : const Color(0xFFF97316)))),
          const SizedBox(width: 16),
          SizedBox(
            width: 50,
            child: Text(
              isActive ? 'Aktif' : 'Off', 
              textAlign: TextAlign.right, 
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isActive ? AppColors.success : AppColors.slate400),
            ),
          ),
        ],
      ),
    );
  }
}
