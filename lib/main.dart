import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants/colors.dart';
import 'constants/app_secrets.dart';
import 'data/stock_repository.dart';
import 'data/supabase_auth_repository.dart';
import 'data/supabase_portfolio_repository.dart';
import 'blocs/stock/stock_bloc.dart';
import 'blocs/theme/theme_cubit.dart';
import 'blocs/settings/settings_cubit.dart';
import 'blocs/auth/auth_cubit.dart';
import 'widgets/auth_gate.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      try {
        await Supabase.initialize(
          url: AppSecrets.supabaseUrl,
          anonKey: AppSecrets.supabaseAnonKey,
        );
      } catch (e) {
        debugPrint("Supabase Init Error: $e");
        // Continue anyway, repository will handle missing Supabase gracefully
      }

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: AppColors.primary,
          statusBarIconBrightness: Brightness.light,
        ),
      );

      final stockRepository = StockRepository();
      final authRepository = SupabaseAuthRepository();
      final portfolioRepository = SupabasePortfolioRepository();

      runApp(
        MainApp(
          stockRepository: stockRepository,
          authRepository: authRepository,
          portfolioRepository: portfolioRepository,
        ),
      );
    },
    (error, stack) {
      debugPrint("Global Error: $error");
      debugPrint(stack.toString());
    },
  );
}

class MainApp extends StatelessWidget {
  final StockRepository stockRepository;
  final SupabaseAuthRepository authRepository;
  final SupabasePortfolioRepository portfolioRepository;

  const MainApp({
    super.key,
    required this.stockRepository,
    required this.authRepository,
    required this.portfolioRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: stockRepository),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: portfolioRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthCubit(authRepository)),
          BlocProvider(
            create: (context) =>
                StockBloc(repository: stockRepository)..add(LoadStocks()),
          ),
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(create: (context) => SettingsCubit()),
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
              home: const AuthGate(),
            );
          },
        ),
      ),
    );
  }
}
