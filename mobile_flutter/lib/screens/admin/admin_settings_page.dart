import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
  File? _qrisImage;

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
    
    // Fetch settings and populate fields
    _settingsController.fetchSettings().then((_) {
      _loadSettings();
    });
  }

  void _loadSettings() {
    final s = _settingsController.settings;
    if (s.isNotEmpty) {
      setState(() {
        _nameController.text = s['site_name'] ?? '';
        _ownerController.text = s['owner_name'] ?? s['account_name'] ?? _authController.user['name'] ?? '';
        _addressController.text = s['address'] ?? '';
        _descriptionController.text = s['description'] ?? '';
        _emailController.text = s['email'] ?? _authController.user['email'] ?? '';
        _whatsappController.text = s['phone'] ?? '';
        
        if (s['primary_color'] != null && s['primary_color'].toString().isNotEmpty) {
          _selectedColor = s['primary_color'];
        }
        
        if (s['theme'] != null && s['theme'].toString().isNotEmpty) {
          _selectedTheme = s['theme'];
        }
        
        // Load operational hours from backend structure
        if (s['operational_hours'] != null) {
          var hours = s['operational_hours'];
          if (hours is String) {
            try {
              hours = jsonDecode(hours);
            } catch (e) {
              print('Error decoding operational_hours string: $e');
            }
          }
          if (hours is List) {
            for (var item in hours) {
              final dayName = item['day']?.toString() ?? '';
              String shortDay = '';
              if (dayName.startsWith('Sen')) shortDay = 'Sen';
              else if (dayName.startsWith('Sel')) shortDay = 'Sel';
              else if (dayName.startsWith('Rab')) shortDay = 'Rab';
              else if (dayName.startsWith('Kam')) shortDay = 'Kam';
              else if (dayName.startsWith('Jum')) shortDay = 'Jum';
              else if (dayName.startsWith('Sab')) shortDay = 'Sab';
              else if (dayName.startsWith('Min')) shortDay = 'Min';
              
              if (shortDay.isNotEmpty) {
                final target = _operationalHours.firstWhereOrNull((d) => d['day'] == shortDay);
                if (target != null) {
                  bool isActive = true;
                  if (item.containsKey('active')) {
                    isActive = item['active'] == true || item['active'] == 1;
                  } else if (item.containsKey('is_closed')) {
                    isActive = !(item['is_closed'] == true || item['is_closed'] == 1 || item['is_closed'].toString() == 'true');
                  }
                  target['active'] = isActive;
                  target['open'] = (item['open'] != null && item['open'].toString().isNotEmpty) ? item['open'] : '09:00';
                  target['close'] = (item['close'] != null && item['close'].toString().isNotEmpty) ? item['close'] : '22:00';
                }
              }
            }
          }
        }
        
        // Load payment methods
        _paymentMethods['qris'] = s['is_qris_active'] == true || s['is_qris_active'] == 1 || s['is_qris_active'].toString() == 'true';
        _paymentMethods['transfer'] = s['is_transfer_active'] == true || s['is_transfer_active'] == 1 || s['is_transfer_active'].toString() == 'true';
        _paymentMethods['cash'] = s['is_cash_active'] == true || s['is_cash_active'] == 1 || s['is_cash_active'].toString() == 'true';
      });
    }
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

  Future<void> _pickQrisImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _qrisImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
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
                            '${ApiConstants.baseUrl.replaceAll('/api', '/storage/')}$logo',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        );
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
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
          
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _settingsController.isSaving.value
                  ? null
                  : () async {
                      bool success = await _settingsController.saveSettings({
                        'site_name': _nameController.text,
                        'owner_name': _ownerController.text,
                        'address': _addressController.text,
                        'description': _descriptionController.text,
                        'email': _emailController.text,
                        'phone': _whatsappController.text,
                      }, logoPath: _logoImage?.path);
                      if (success) {
                        setState(() {
                          _logoImage = null; // Reset picked logo image since it's saved
                        });
                        _loadSettings();
                        Get.snackbar("Sukses", "Profil toko berhasil disimpan!", backgroundColor: AppColors.success, colorText: Colors.white);
                      } else {
                        Get.snackbar("Gagal", "Gagal menyimpan profil toko", backgroundColor: Colors.red, colorText: Colors.white);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: _settingsController.isSaving.value
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          )),
          
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
                            if (val) {
                              if (day['open'] == null || day['open'].toString().isEmpty) {
                                day['open'] = '09:00';
                              }
                              if (day['close'] == null || day['close'].toString().isEmpty) {
                                day['close'] = '22:00';
                              }
                            }
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.success,
                      ),
                      const SizedBox(width: 16),
                      if (day['active']) ...[
                        Expanded(
                          child: _buildTimeField(
                            context,
                            day['open'],
                            (val) {
                              setState(() {
                                day['open'] = val;
                              });
                            },
                          ),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('-', style: TextStyle(color: AppColors.slate400))),
                        Expanded(
                          child: _buildTimeField(
                            context,
                            day['close'],
                            (val) {
                              setState(() {
                                day['close'] = val;
                              });
                            },
                          ),
                        ),
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
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(LucideIcons.info, size: 16, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(child: Text('Jam operasional akan ditampilkan di halaman menu digital pelanggan kamu.', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _settingsController.isSaving.value
                      ? null
                      : () async {
                          final List<Map<String, dynamic>> mappedHours = _operationalHours.map((item) {
                            String fullDay = '';
                            switch (item['day']) {
                              case 'Sen': fullDay = 'Senin'; break;
                              case 'Sel': fullDay = 'Selasa'; break;
                              case 'Rab': fullDay = 'Rabu'; break;
                              case 'Kam': fullDay = 'Kamis'; break;
                              case 'Jum': fullDay = 'Jumat'; break;
                              case 'Sab': fullDay = 'Sabtu'; break;
                              case 'Min': fullDay = 'Minggu'; break;
                              default: fullDay = item['day'];
                            }
                            return {
                              'day': fullDay,
                              'open': item['open'] ?? '',
                              'close': item['close'] ?? '',
                              'is_closed': !(item['active'] == true),
                            };
                          }).toList();
                          
                          bool success = await _settingsController.saveSettings({'operational_hours': mappedHours});
                          if (success) {
                            _loadSettings();
                            Get.snackbar("Sukses", "Jam operasional berhasil disimpan!", backgroundColor: AppColors.success, colorText: Colors.white);
                          } else {
                            Get.snackbar("Gagal", "Gagal menyimpan jam operasional", backgroundColor: Colors.red, colorText: Colors.white);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: _settingsController.isSaving.value
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Simpan Jam Operasional', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              )),
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
          
          // QRIS Image Upload Section
          if (_paymentMethods['qris'] == true) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                border: Border.all(color: const Color(0xFFFED7AA)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.qrCode, size: 16, color: const Color(0xFFF97316)),
                      const SizedBox(width: 8),
                      const Text('Upload QRIS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.slate900)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Unggah gambar QRIS merchant Anda untuk pembayaran digital', style: TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickQrisImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.slate200, width: 2, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _qrisImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(_qrisImage!, fit: BoxFit.contain),
                            )
                          : Obx(() {
                              final qris = _settingsController.settings['qris_image'];
                              if (qris != null && qris.toString().isNotEmpty) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    '${ApiConstants.baseUrl.replaceAll('/api', '/storage/')}$qris',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => _buildQrisPlaceholder(),
                                  ),
                                );
                              }
                              return _buildQrisPlaceholder();
                            }),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
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
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _settingsController.isSaving.value
                  ? null
                  : () async {
                      bool success = await _settingsController.saveSettings(
                        {'payment_methods': _paymentMethods},
                        qrisImagePath: _qrisImage?.path,
                      );
                      if (success) {
                        setState(() {
                          _qrisImage = null;
                        });
                        _loadSettings();
                        Get.snackbar("Sukses", "Metode transaksi berhasil disimpan!", backgroundColor: AppColors.success, colorText: Colors.white);
                      } else {
                        Get.snackbar("Gagal", "Gagal menyimpan metode transaksi", backgroundColor: Colors.red, colorText: Colors.white);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: _settingsController.isSaving.value
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Simpan Metode Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          )),
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
        
        Obx(() => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _settingsController.isSaving.value
                  ? null
                  : () async {
                      bool success = await _settingsController.saveSettings({
                        'color': _selectedColor,
                        'theme': _selectedTheme,
                      });
                      if (success) {
                        _loadSettings();
                        Get.snackbar("Sukses", "Tema & Warna berhasil diterapkan!", backgroundColor: AppColors.success, colorText: Colors.white);
                      } else {
                        Get.snackbar("Gagal", "Gagal menyimpan tema & warna", backgroundColor: Colors.red, colorText: Colors.white);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: _settingsController.isSaving.value
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Terapkan Tema', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
        )),
      ],
    );
  }

  // === HELPERS ===
  Widget _buildQrisPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.uploadCloud, color: const Color(0xFFF97316), size: 36),
        const SizedBox(height: 8),
        const Text('Upload QRIS Image', style: TextStyle(fontSize: 12, color: Color(0xFFF97316), fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Tap untuk upload gambar QRIS', style: TextStyle(fontSize: 10, color: AppColors.slate400)),
        const Text('Format: JPG, PNG (max 2MB)', style: TextStyle(fontSize: 9, color: AppColors.slate400)),
      ],
    );
  }

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

  Future<void> _selectTime(BuildContext context, String initialTime, Function(String) onChanged) async {
    final parts = initialTime.split(':');
    int hour = 9;
    int minute = 0;
    if (parts.length == 2) {
      hour = int.tryParse(parts[0]) ?? 9;
      minute = int.tryParse(parts[1]) ?? 0;
    }
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.slate900,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      onChanged('$hourStr:$minuteStr');
    }
  }

  Widget _buildTimeField(BuildContext context, String initialValue, Function(String) onChanged) {
    return GestureDetector(
      onTap: () => _selectTime(context, initialValue, onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.slate200, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.clock, size: 14, color: AppColors.slate400),
            const SizedBox(width: 8),
            Text(
              initialValue.isNotEmpty ? initialValue : '--:--',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate700),
            ),
          ],
        ),
      ),
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