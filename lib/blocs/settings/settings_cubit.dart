import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

enum AppCurrency { turkishLira, usd, eur, gold }

extension AppCurrencyExtension on AppCurrency {
  String get label {
    switch (this) {
      case AppCurrency.turkishLira:
        return 'Türk Lirası (₺)';
      case AppCurrency.usd:
        return 'Amerikan Doları (\$)';
      case AppCurrency.eur:
        return 'Euro (€)';
      case AppCurrency.gold:
        return 'Gram Altın (gr)';
    }
  }

  String get symbol {
    switch (this) {
      case AppCurrency.turkishLira:
        return '₺';
      case AppCurrency.usd:
        return '\$';
      case AppCurrency.eur:
        return '€';
      case AppCurrency.gold:
        return 'gr';
    }
  }

  // Mock exchange rates
  double get rateToTry {
    switch (this) {
      case AppCurrency.turkishLira:
        return 1.0;
      case AppCurrency.usd:
        return 35.05; // Mock rate
      case AppCurrency.eur:
        return 36.50; // Mock rate
      case AppCurrency.gold:
        return 2450.0; // Mock rate
    }
  }

  String format(double value) {
    // Manual formatting for Turkish locale (dots for thousands, comma for decimal)
    String valueStr = value.toStringAsFixed(2);
    List<String> parts = valueStr.split('.');
    String wholePart = parts[0];
    String decimalPart = parts[1];

    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    
    wholePart = wholePart.replaceAllMapped(reg, (Match match) => '${match[1]}.');
    
    String formattedValue = '$wholePart,$decimalPart';

    if (this == AppCurrency.gold) {
      return '$formattedValue gr';
    }
    return '$symbol$formattedValue';
  }
}

class SettingsState extends Equatable {
  final AppCurrency currency;

  const SettingsState({this.currency = AppCurrency.turkishLira});

  SettingsState copyWith({AppCurrency? currency}) {
    return SettingsState(
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object> get props => [currency];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void setCurrency(AppCurrency currency) {
    emit(state.copyWith(currency: currency));
  }
}
