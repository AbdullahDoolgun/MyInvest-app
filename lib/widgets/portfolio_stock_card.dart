import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PortfolioStockCard extends StatelessWidget {
  final String symbol;
  final String name; // Or details
  final String price;
  final String change;
  final bool isUp;
  final String weekly; // AL, SAT, NÖTR
  final String monthly;
  final String threeMonthly;

  const PortfolioStockCard({
    super.key,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.isUp,
    required this.weekly,
    required this.monthly,
    required this.threeMonthly,
  });

  Color _getColorForRec(String rec) {
    if (rec == "AL" || rec == "GÜÇLÜ AL") return AppColors.up;
    if (rec == "SAT") return AppColors.down;
    return AppColors.textSecondary; // Nötr
  }

  Color _getBgColorForRec(String rec) {
    if (rec == "AL" || rec == "GÜÇLÜ AL") return AppColors.upLight;
    if (rec == "SAT") return AppColors.downLight;
    return AppColors.neutralLight;
  }

  Widget _buildRecTag(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _getBgColorForRec(value),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getColorForRec(value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  symbol.substring(0, symbol.length > 4 ? 4 : symbol.length),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    change,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isUp ? AppColors.up : AppColors.down,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRecTag("HAFTALIK", weekly),
              _buildRecTag("AYLIK", monthly),
              _buildRecTag("3 AYLIK", threeMonthly),
            ],
          ),
        ],
      ),
    );
  }
}
