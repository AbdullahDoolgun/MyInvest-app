import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/main_screen.dart';
import 'constants/colors.dart';
import 'data/stock_repository.dart';
import 'blocs/stock/stock_bloc.dart';

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
      child: BlocProvider(
        create: (context) =>
            StockBloc(repository: stockRepository)..add(LoadStocks()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Borsa App',
          theme: ThemeData(
            fontFamily: 'Roboto',
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.background,
            useMaterial3: true,
          ),
          home: const MainScreen(),
        ),
      ),
    );
  }
}
