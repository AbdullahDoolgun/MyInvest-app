import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color iconColor = AppColors.accent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing:
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Hesap"),
          _buildSettingsTile(icon: Icons.person, title: "Profil Bilgileri"),
          _buildSettingsTile(
            icon: Icons.lock_clock, // Using lock_clock or similar
            title: "Şifre Değiştir",
          ),
          _buildSettingsTile(
            icon: Icons.logout,
            title: "Çıkış Yap",
            iconColor: Colors.red,
          ),

          const SizedBox(height: 16),
          _buildSectionHeader("Bildirimler"),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: "Anlık Fiyat Bildirimleri",
            trailing: Switch(
              value: true,
              onChanged: (v) {},
              activeThumbColor: AppColors.accent,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.newspaper,
            title: "Haber ve Analizler",
            trailing: Switch(
              value: false,
              onChanged: (v) {},
              activeThumbColor: AppColors.accent,
            ),
          ),

          const SizedBox(height: 16),
          _buildSectionHeader("Görünüm"),
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            title: "Tema",
            trailing: const Text(
              "Açık",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.text_fields,
            title: "Metin Boyutu",
            trailing: const Text(
              "Orta",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),

          const SizedBox(height: 16),
          _buildSectionHeader("Hakkında"),
          _buildSettingsTile(
            icon: Icons.info,
            title: "Uygulama Sürümü",
            trailing: const Text(
              "1.2.3",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: "Gizlilik Politikası",
          ),
          _buildSettingsTile(icon: Icons.gavel, title: "Kullanım Koşulları"),
          // Bottom spacer for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
