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
  final VoidCallback? onDelete;

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
    this.onDelete,
  });

  Color _getColorForRec(String rec) {
    if (rec == "AL" || rec == "GÜÇLÜ AL") return AppColors.up;
    if (rec == "SAT") return AppColors.down;
    return AppColors.textSecondary; // Nötr
  }

  Color _getBgColorForRec(BuildContext context, String rec) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (rec == "AL" || rec == "GÜÇLÜ AL") {
      return isDark ? AppColors.up.withValues(alpha: 0.2) : AppColors.upLight;
    }
    if (rec == "SAT") {
      return isDark
          ? AppColors.down.withValues(alpha: 0.2)
          : AppColors.downLight;
    }
    return isDark
        ? AppColors.neutral.withValues(alpha: 0.2)
        : AppColors.neutralLight;
  }

  Widget _buildRecTag(BuildContext context, String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _getBgColorForRec(context, value),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurface,
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
        color: Theme.of(context).cardColor,
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
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  symbol.substring(0, symbol.length > 4 ? 4 : symbol.length),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSecondary,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.9),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
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
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRecTag(context, "HAFTALIK", weekly),
              _buildRecTag(context, "AYLIK", monthly),
              _buildRecTag(context, "3 AYLIK", threeMonthly),
            ],
          ),
        ],
      ),
    );
  }
}
