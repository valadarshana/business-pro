import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/business_models.dart';
import '../../models/monthly_profit_loss.dart';
import '../../providers/expense_providers.dart';
import '../../providers/monthly_profit_loss_providers.dart';
import '../../providers/order_providers.dart';
import '../../theme/app_theme.dart';

class MonthlyProfitLossScreen extends ConsumerWidget {
  const MonthlyProfitLossScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyReports = ref.watch(monthlyProfitLossProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Profit & Loss')),
      body: monthlyReports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ReportError(
          error: error,
          onRetry: () {
            ref.invalidate(ordersProvider);
            ref.invalidate(expensesProvider);
          },
        ),
        data: (reports) => reports.isEmpty
            ? const Center(child: Text('No monthly records found.'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppTheme.pagePadding),
                itemCount: reports.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, index) =>
                    _MonthlyReportCard(report: reports[index]),
              ),
      ),
    );
  }
}

class _MonthlyReportCard extends StatelessWidget {
  const _MonthlyReportCard({required this.report});

  final MonthlyProfitLoss report;

  @override
  Widget build(BuildContext context) {
    final isLoss = report.net < 0;
    final resultColor = isLoss ? AppColors.danger : AppColors.success;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(report.label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          _ReportAmount(label: 'Income', amount: report.income),
          const SizedBox(height: 8),
          _ReportAmount(label: 'Expenses', amount: report.expenses),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isLoss
                    ? 'Loss'
                    : report.net == 0
                    ? 'Break-even'
                    : 'Profit',
                style: TextStyle(
                  color: resultColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _formatNet(report.net),
                style: TextStyle(
                  color: resultColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportAmount extends StatelessWidget {
  const _ReportAmount({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: AppColors.muted)),
      Text(formatCurrency(amount)),
    ],
  );
}

class _ReportError extends StatelessWidget {
  const _ReportError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 40,
            color: AppColors.danger,
          ),
          const SizedBox(height: 12),
          const Text('Could not load monthly profit and loss'),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    ),
  );
}

String _formatNet(double amount) {
  final absAmount = formatCurrency(amount.abs());
  if (amount < 0) return '-$absAmount';
  return absAmount;
}
