import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/colors.dart';
import '../blocs/theme/theme_cubit.dart';
import '../blocs/settings/settings_cubit.dart';
import '../blocs/auth/auth_cubit.dart'; // Add this line

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
    bool disabled = false,
  }) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: ListTile(
          onTap: disabled ? null : onTap,
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    "Gizlilik Politikası",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Son Güncelleme: 28 Aralık 2025\n\n"
                    "Bu uygulama (MyInvestApp), kullanıcılarının gizliliğine önem verir. "
                    "Bu politika, uygulamamızı kullandığınızda verilerinizin nasıl toplandığını, "
                    "kullanıldığını ve korunduğunu açıklar.\n\n"
                    "1. Toplanan Bilgiler\n"
                    "Kayıt sırasında sağladığınız ad, soyad ve e-posta adresi gibi temel bilgileri topluyoruz. "
                    "Ayrıca portföy verileriniz uygulama işlevselliği için saklanmaktadır.\n\n"
                    "2. Bilgilerin Kullanımı\n"
                    "Toplanan bilgiler, size kişiselleştirilmiş bir deneyim sunmak, "
                    "yatırım takibini sağlamak ve hesabınızı güvenli bir şekilde yönetmek için kullanılır.\n\n"
                    "3. Veri Güvenliği\n"
                    "Verileriniz güvenli sunucularda saklanır ve yetkisiz erişime karşı korunur. "
                    "Kişisel verileriniz üçüncü şahıslarla paylaşılmaz.\n\n"
                    "4. İletişim\n"
                    "Sorularınız için bizimle iletişime geçebilirsiniz.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTermsOfUse(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    "Kullanım Koşulları",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Son Güncelleme: 28 Aralık 2025\n\n"
                    "Lütfen uygulamamızı kullanmadan önce aşağıdaki koşulları dikkatlice okuyunuz.\n\n"
                    "1. Kabul Edilme\n"
                    "Bu uygulamayı kullanarak, bu koşulları kabul etmiş sayılırsınız.\n\n"
                    "2. Sorumluluk Reddi\n"
                    "Bu uygulama sadece bilgilendirme ve takip amaçlıdır. "
                    "Burada yer alan veriler yatırım tavsiyesi niteliği taşımaz. "
                    "Yatırım kararlarınızdan doğacak arak zararlardan uygulamamız sorumlu tutulamaz.\n\n"
                    "3. Hesap Güvenliği\n"
                    "Hesap şifrenizin güvenliğinden kullanıcı sorumludur. "
                    "Şüpheli bir durum fark ettiğinizde lütfen bildirin.\n\n"
                    "4. Değişiklikler\n"
                    "Bu koşullar önceden haber verilmeksizin güncellenebilir.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
    if (scale < 0.9) {
      return "Küçük";
    }
    if (scale > 1.1) {
      return "Büyük";
    }
    return "Orta";
  }

  void _showCurrencyBottomSheet(BuildContext context) {
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
                "Para Birimi Seçin",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              ...AppCurrency.values.map(
                (currency) => _buildCurrencyOption(context, currency),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyOption(BuildContext context, AppCurrency currency) {
    final currentCurrency = context.watch<SettingsCubit>().state.currency;
    final isSelected = currentCurrency == currency;

    return ListTile(
      title: Text(
        currency.label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.accent)
          : null,
      onTap: () {
        context.read<SettingsCubit>().setCurrency(currency);
        Navigator.pop(context);
      },
    );
  }

  void _showEditProfileBottomSheet(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      return;
    }

    final user = authState.user;
    final metadata = user.userMetadata ?? {};

    final firstNameController = TextEditingController(
      text: metadata['first_name'] as String? ?? '',
    );
    final lastNameController = TextEditingController(
      text: metadata['last_name'] as String? ?? '',
    );
    final ageController = TextEditingController(
      text: (metadata['age'] as int?)?.toString() ?? '',
    );
    final cityController = TextEditingController(
      text: metadata['city'] as String? ?? '',
    );
    final countryController = TextEditingController(
      text: metadata['country'] as String? ?? 'Türkiye',
    );
    String selectedGender = metadata['gender'] as String? ?? 'Erkek';
    final genders = ['Erkek', 'Kadın', 'Diğer'];

    // Ensure selectedGender is valid
    if (!genders.contains(selectedGender)) {
      selectedGender = 'Erkek';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Profili Düzenle",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: firstNameController,
                          decoration: const InputDecoration(labelText: 'Ad'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: lastNameController,
                          decoration: const InputDecoration(labelText: 'Soyad'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedGender,
                          decoration: const InputDecoration(
                            labelText: 'Cinsiyet',
                          ),
                          items: genders
                              .map(
                                (g) =>
                                    DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedGender = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: ageController,
                          decoration: const InputDecoration(labelText: 'Yaş'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: countryController,
                          decoration: const InputDecoration(labelText: 'Ülke'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: cityController,
                          decoration: const InputDecoration(labelText: 'Şehir'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthCubit>().updateProfile(
                        firstName: firstNameController.text.trim(),
                        lastName: lastNameController.text.trim(),
                        gender: selectedGender,
                        age: int.tryParse(ageController.text),
                        city: cityController.text.trim(),
                        country: countryController.text.trim(),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil güncellendi')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Kaydet'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordBottomSheet(BuildContext context) {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Şifre Değiştir",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Yeni Şifre'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Yeni Şifre (Tekrar)',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final password = passwordController.text.trim();
                  if (password.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Şifre en az 6 karakter olmalı.'),
                      ),
                    );
                    return;
                  }
                  if (password != confirmPasswordController.text.trim()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Şifreler eşleşmiyor.')),
                    );
                    return;
                  }

                  context.read<AuthCubit>().updatePassword(password);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Şifre güncellendi.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Şifreyi Güncelle'),
              ),
            ],
          ),
        );
      },
    );
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
            onTap: () => _showEditProfileBottomSheet(context),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.lock_clock, // Using lock_clock or similar
            title: "Şifre Değiştir",
            onTap: () => _showChangePasswordBottomSheet(context),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.logout,
            title: "Çıkış Yap",
            iconColor: Colors.red,
            onTap: () {
              context.read<AuthCubit>().signOut();
            },
          ),

          const SizedBox(height: 16),
          _buildSectionHeader(context, "Bildirimler"),
          _buildSettingsTile(
            context,
            icon: Icons.notifications,
            title: "Anlık Fiyat Bildirimleri",
            disabled: true,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("Yakında", style: TextStyle(fontSize: 10)),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.newspaper,
            title: "Haber ve Analizler",
            disabled: true,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("Yakında", style: TextStyle(fontSize: 10)),
            ),
          ),

          const SizedBox(height: 16),
          const SizedBox(height: 16),
          _buildSectionHeader(context, "Arayüz Özelleştirme"),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return _buildSettingsTile(
                context,
                icon: Icons.currency_exchange,
                title: "Ana Sayfa Değeri",
                trailing: Text(
                  state.currency.label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () => _showCurrencyBottomSheet(context),
              );
            },
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
                      activeThumbColor: AppColors.accent,
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
              "0.6.9",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip,
            title: "Gizlilik Politikası",
            onTap: () => _showPrivacyPolicy(context),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.gavel,
            title: "Kullanım Koşulları",
            onTap: () => _showTermsOfUse(context),
          ),
          // Bottom spacer for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
