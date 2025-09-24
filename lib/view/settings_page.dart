import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/local_storage_service.dart';
import '../utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _storage = Get.find<LocalStorageService>();
  
  // Controllers untuk form editing
  final _nameController = TextEditingController();
  final _universityController = TextEditingController();
  final _majorController = TextEditingController();
  
  // State variables
  String _selectedClass = '7';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    try {
      final userData = await _storage.getUserData();
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _selectedClass = userData['class'] ?? '7';
        _universityController.text = userData['university'] ?? '';
        _majorController.text = userData['major'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Gagal memuat data pengguna');
    }
  }
  
  Future<void> _saveUserData() async {
    try {
      await _storage.setUserName(_nameController.text);
      await _storage.setUserClass(_selectedClass);
      await _storage.setUserUniversity(_universityController.text);
      await _storage.setUserMajor(_majorController.text);
      
      _showSuccessSnackbar('Data berhasil disimpan');
    } catch (e) {
      _showErrorSnackbar('Gagal menyimpan data');
    }
  }
  
  Future<void> _exportData() async {
    try {
      // Show loading dialog
      _showLoadingDialog('Mengekspor data...');
      
      // Simulate export process
      await Future.delayed(const Duration(seconds: 2));
      
      // Close loading dialog
      Get.back();
      
      // Show success dialog with export info
      _showExportDialog();
    } catch (e) {
      Get.back(); // Close loading dialog
      _showErrorSnackbar('Gagal mengekspor data');
    }
  }
  
  Future<void> _resetAllData() async {
    // Show confirmation dialog first
    final confirm = await _showResetConfirmationDialog();
    if (!confirm) return;
    
    try {
      _showLoadingDialog('Mereset aplikasi...');
      
      // Clear all data
      await _storage.clearAllData();
      
      // Reset form
      setState(() {
        _nameController.clear();
        _selectedClass = '7';
        _universityController.clear();
        _majorController.clear();
      });
      
      Get.back(); // Close loading dialog
      _showSuccessSnackbar('Aplikasi berhasil direset');
      
      // Optionally navigate back to onboarding
      // Get.offAllNamed(RoutesName.onboardingFlow);
      
    } catch (e) {
      Get.back(); // Close loading dialog
      _showErrorSnackbar('Gagal mereset aplikasi');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: neutral900),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Pengaturan',
          style: desktopH2.copyWith(color: neutral900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: neutral900),
            onPressed: _saveUserData,
            tooltip: 'Simpan Perubahan',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('UMUM'),
                  const SizedBox(height: 12),
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildClassSelector(),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('PREFERENSI'),
                  const SizedBox(height: 12),
                  _buildUniversityField(),
                  const SizedBox(height: 16),
                  _buildMajorField(),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('DATA'),
                  const SizedBox(height: 12),
                  _buildExportButton(),
                  const SizedBox(height: 16),
                  _buildResetButton(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: bodyText16.copyWith(
        color: neutral600,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
  
  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppConstants.defaultBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Nama',
          hintText: 'Masukkan nama lengkap',
          prefixIcon: const Icon(Icons.person, color: neutral400),
          border: OutlineInputBorder(
            borderRadius: AppConstants.defaultBorderRadius,
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
  
  Widget _buildClassSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppConstants.defaultBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: neutral400),
                const SizedBox(width: 12),
                Text(
                  'Kelas',
                  style: bodyText16.copyWith(color: neutral700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: ['7', '8', '9'].map((kelas) {
                final isSelected = _selectedClass == kelas;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: kelas != '9' ? 8 : 0,
                    ),
                    child: InkWell(
                      onTap: () => setState(() => _selectedClass = kelas),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? brand700 : neutral100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Kelas $kelas',
                          textAlign: TextAlign.center,
                          style: bodyText14.copyWith(
                            color: isSelected ? Colors.white : neutral700,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUniversityField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppConstants.defaultBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _universityController,
        decoration: InputDecoration(
          labelText: 'Universitas Impian',
          hintText: 'Masukkan universitas yang ingin dituju',
          prefixIcon: const Icon(Icons.apartment, color: neutral400),
          border: OutlineInputBorder(
            borderRadius: AppConstants.defaultBorderRadius,
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
  
  Widget _buildMajorField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppConstants.defaultBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _majorController,
        decoration: InputDecoration(
          labelText: 'Jurusan Impian',
          hintText: 'Masukkan jurusan yang diinginkan',
          prefixIcon: const Icon(Icons.menu_book, color: neutral400),
          border: OutlineInputBorder(
            borderRadius: AppConstants.defaultBorderRadius,
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
  
  Widget _buildExportButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppConstants.defaultBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: _exportData,
        borderRadius: AppConstants.defaultBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.download, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Data Stats',
                      style: bodyText16.copyWith(
                        color: neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ekspor semua data statistik Anda',
                      style: bodyText14.copyWith(color: neutral600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: neutral400, size: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildResetButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppConstants.defaultBorderRadius,
        border: Border.all(color: Colors.red.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: _resetAllData,
        borderRadius: AppConstants.defaultBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_forever, color: Colors.red),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset Aplikasi',
                      style: bodyText16.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hapus semua data dan kembalikan ke pengaturan awal',
                      style: bodyText14.copyWith(color: neutral600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper methods untuk dialog dan snackbar
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
  
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
  
  void _showLoadingDialog(String message) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(message),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  
  Future<bool> _showResetConfirmationDialog() async {
    return await Get.dialog<bool>(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Reset Aplikasi?',
                style: mobileH3.copyWith(color: neutral900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Tindakan ini akan menghapus semua data termasuk:\n\n• Data profil pengguna\n• Statistik belajar\n• Progress dan pencapaian\n• Pengaturan aplikasi\n\nTindakan ini tidak dapat dibatalkan.',
                style: bodyText14.copyWith(color: neutral600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: neutral300),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ?? false;
  }
  
  void _showExportDialog() {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Data Berhasil Diekspor',
                style: mobileH3.copyWith(color: neutral900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Data statistik Anda telah berhasil diekspor dan disimpan di:\n\n/storage/emulated/0/Download/NeuroKit_Stats_${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}.json',
                style: bodyText14.copyWith(color: neutral600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand700,
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}