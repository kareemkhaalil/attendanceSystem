import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manzoma/core/localization/app_localizations.dart';
import 'package:manzoma/core/localization/app_localizations_extra.dart';
import '../../../landing/presentation/widgets/landing_theme.dart';
import '../cubit/payment_cubit.dart';
import '../../domain/entities/transaction_entity.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentCubit>().fetchAllTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.off(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          tr.translate('admin_transactions'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<PaymentCubit, PaymentState>(
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator(color: LandingColors.primary));
          }

          if (state is AllTransactionsLoaded) {
            if (state.transactions.isEmpty) {
              return Center(
                child: Text(
                  tr.translate('admin_no_transactions'),
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final trx = state.transactions[index];
                return _TransactionCard(transaction: trx);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.off(context);
    final bool isPending = transaction.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPending ? LandingColors.primary.withValues(alpha: 0.2) : Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount: ${transaction.amount} ${transaction.currency}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _StatusBadge(status: transaction.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tenant ID: ${transaction.tenantId}',
            style: TextStyle(color: LandingColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Date: ${transaction.createdAt}',
            style: TextStyle(color: LandingColors.textMuted, fontSize: 12),
          ),
          if (transaction.screenshotUrl != null) ...[
            const SizedBox(height: 12),
             Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  const Text('Screenshot attached', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Logic to view image
                    },
                    child: const Text('View', style: TextStyle(color: LandingColors.primary, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<PaymentCubit>().approvePayment(transaction.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LandingColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(tr.translate('admin_approve')),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    // Reject logic
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(tr.translate('admin_reject')),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'success':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'failed':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
