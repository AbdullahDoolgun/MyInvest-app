import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/colors.dart';
import '../blocs/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    Color iconColor = AppColors.accent,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing:
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  void _showTextSizeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Metin Boyutu",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              _buildSizeOption(context, "Küçük", 0.85),
              _buildSizeOption(context, "Orta", 1.0),
              _buildSizeOption(context, "Büyük", 1.15),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSizeOption(BuildContext context, String label, double scale) {
    final currentScale = context.watch<ThemeCubit>().state.textScaleFactor;
    final isSelected = (currentScale - scale).abs() < 0.01;

    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.accent)
          : null,
      onTap: () {
        context.read<ThemeCubit>().setTextScale(scale);
        Navigator.pop(context);
      },
    );
  }

  String _getTextSizeLabel(double scale) {
    if (scale < 0.9) return "Küçük";
    if (scale > 1.1) return "Büyük";
    return "Orta";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, "Hesap"),
          _buildSettingsTile(
            context,
            icon: Icons.person,
            title: "Profil Bilgileri",
          ),
          _buildSettingsTile(
            context,
            icon: Icons.lock_clock, // Using lock_clock or similar
            title: "Şifre Değiştir",
          ),
          _buildSettingsTile(
            context,
            icon: Icons.logout,
            title: "Çıkış Yap",
            iconColor: Colors.red,
          ),

          const SizedBox(height: 16),
          _buildSectionHeader(context, "Bildirimler"),
          _buildSettingsTile(
            context,
            icon: Icons.notifications,
            title: "Anlık Fiyat Bildirimleri",
            trailing: Switch(
              value: true,
              onChanged: (v) {},
              activeColor: AppColors.accent,
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.newspaper,
            title: "Haber ve Analizler",
            trailing: Switch(
              value: false,
              onChanged: (v) {},
              activeColor: AppColors.accent,
            ),
          ),

          const SizedBox(height: 16),
          _buildSectionHeader(context, "Görünüm"),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              final isDark = state.themeMode == ThemeMode.dark;
              return Column(
                children: [
                  _buildSettingsTile(
                    context,
                    icon: isDark ? Icons.light_mode : Icons.dark_mode,
                    title: "Tema",
                    trailing: Switch(
                      value: isDark,
                      onChanged: (value) {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                      activeColor: AppColors.accent,
                    ),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.text_fields,
                    title: "Metin Boyutu",
                    trailing: Text(
                      _getTextSizeLabel(state.textScaleFactor),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    onTap: () => _showTextSizeBottomSheet(context),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),
          _buildSectionHeader(context, "Hakkında"),
          _buildSettingsTile(
            context,
            icon: Icons.info,
            title: "Uygulama Sürümü",
            trailing: const Text(
              "1.2.3",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip,
            title: "Gizlilik Politikası",
          ),
          _buildSettingsTile(
            context,
            icon: Icons.gavel,
            title: "Kullanım Koşulları",
          ),
          // Bottom spacer for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
