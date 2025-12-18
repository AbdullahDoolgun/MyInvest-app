import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/main_screen.dart';
import 'constants/colors.dart';
import 'data/stock_repository.dart';
import 'blocs/stock/stock_bloc.dart';

import 'blocs/theme/theme_cubit.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primary,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final stockRepository = StockRepository();

  runApp(MainApp(stockRepository: stockRepository));
}

class MainApp extends StatelessWidget {
  final StockRepository stockRepository;

  const MainApp({super.key, required this.stockRepository});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: stockRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                StockBloc(repository: stockRepository)..add(LoadStocks()),
          ),
          BlocProvider(create: (context) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Borsa App',
              themeMode: state.themeMode,
              theme: ThemeData(
                fontFamily: 'Roboto',
                colorScheme: AppColors.lightScheme,
                scaffoldBackgroundColor: AppColors.background,
                useMaterial3: true,
                cardColor: AppColors.surface,
              ),
              darkTheme: ThemeData(
                fontFamily: 'Roboto',
                colorScheme: AppColors.darkScheme,
                scaffoldBackgroundColor: AppColors.primary,
                useMaterial3: true,
                cardColor: AppColors.primary,
              ),
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(state.textScaleFactor),
                  ),
                  child: child!,
                );
              },
              home: const MainScreen(),
            );
          },
        ),
      ),
    );
  }
}
