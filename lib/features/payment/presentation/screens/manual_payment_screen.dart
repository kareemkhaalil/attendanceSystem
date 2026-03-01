import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manzoma/core/localization/app_localizations.dart';
import 'package:manzoma/core/localization/app_localizations_extra.dart';
import '../../../landing/presentation/widgets/landing_theme.dart';
import '../cubit/payment_cubit.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/payment_method_entity.dart';

class ManualPaymentScreen extends StatefulWidget {
  final PlanEntity selectedPlan;
  final PaymentMethodEntity selectedMethod;
  const ManualPaymentScreen({
    super.key,
    required this.selectedPlan,
    required this.selectedMethod,
  });

  @override
  State<ManualPaymentScreen> createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends State<ManualPaymentScreen> {
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.off(context);
    final instruction = widget.selectedMethod.details['instruction'] ?? 'Please transfer to the provided number.';

    return Scaffold(
      backgroundColor: LandingColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.selectedMethod.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is TransactionCreated) {
            _showSuccessDialog();
          }
           if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: LandingColors.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: LandingColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline, color: LandingColors.primary, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        tr.translate('payment_manual_instruction'),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        instruction,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  '1. Pay via the app/account above.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  '2. Take a screenshot of the transaction.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  '3. Click "I Have Paid" and upload it to our WhatsApp or here.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    // In a real app, use image_picker here.
                    // For now, we simulate the text-based workflow.
                    context.read<PaymentCubit>().startPayment(
                      plan: widget.selectedPlan,
                      method: widget.selectedMethod,
                      screenshotUrl: 'pending_image_upload',
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(tr.translate('payment_confirm')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LandingColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                if (state is PaymentLoading)
                  const Center(child: CircularProgressIndicator(color: LandingColors.primary)),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: LandingColors.cardBg,
        title: const Text('Success!', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your transaction has been submitted and is pending admin approval. Your subscription will be active shortly.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to methods
              Navigator.pop(context); // Back to plans
            },
            child: const Text('Done', style: TextStyle(color: LandingColors.primary)),
          ),
        ],
      ),
    );
  }
}
