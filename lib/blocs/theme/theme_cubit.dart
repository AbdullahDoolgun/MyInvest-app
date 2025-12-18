import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final double textScaleFactor;

  const ThemeState({required this.themeMode, this.textScaleFactor = 1.0});

  ThemeState copyWith({ThemeMode? themeMode, double? textScaleFactor}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }

  @override
  List<Object> get props => [themeMode, textScaleFactor];
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.light));

  void toggleTheme() {
    emit(
      state.copyWith(
        themeMode: state.themeMode == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.light,
      ),
    );
  }

  void setTextScale(double scale) {
    emit(state.copyWith(textScaleFactor: scale));
  }
}
