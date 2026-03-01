import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manzoma/core/localization/app_localizations.dart';
import 'package:manzoma/core/localization/app_localizations_extra.dart';
import '../../../landing/presentation/widgets/landing_theme.dart';
import '../cubit/payment_cubit.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import 'manual_payment_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final PlanEntity selectedPlan;
  const PaymentMethodScreen({super.key, required this.selectedPlan});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentCubit>().loadPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.off(context);

    return Scaffold(
      backgroundColor: LandingColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          tr.translate('payment_methods'),
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
            // Handle navigation based on method type
            final method = state.transaction.paymentMethodId; // Simplified check
            // If manual, stay or navigate to success? 
            // Better to handle logic in the screen that calls startPayment
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator(color: LandingColors.primary));
          }

          if (state is PaymentMethodsLoaded) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SummaryCard(plan: widget.selectedPlan),
                  const SizedBox(height: 30),
                  Text(
                    tr.translate('payment_methods'),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...state.methods.map((method) => _MethodItem(
                        method: method,
                        onTap: () {
                          if (method.type == 'manual') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<PaymentCubit>(),
                                  child: ManualPaymentScreen(
                                    selectedPlan: widget.selectedPlan,
                                    selectedMethod: method,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Paymob Pay Logic
                            context.read<PaymentCubit>().startPayment(
                              plan: widget.selectedPlan,
                              method: method,
                            );
                          }
                        },
                      )),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final PlanEntity plan;
  const _SummaryCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LandingColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.name,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${plan.durationDays} Days Subscription',
                style: TextStyle(color: LandingColors.textMuted, fontSize: 14),
              ),
            ],
          ),
          Text(
            '${plan.price} ${plan.currency}',
            style: const TextStyle(color: LandingColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _MethodItem extends StatelessWidget {
  final PaymentMethodEntity method;
  final VoidCallback onTap;
  const _MethodItem({required this.method, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Icon(
                method.type == 'paymob' ? Icons.credit_card : Icons.account_balance_wallet,
                color: LandingColors.primary,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (method.type == 'manual')
                      Text(
                         'InstaPay / Bank Transfer',
                        style: TextStyle(color: LandingColors.textMuted, fontSize: 12),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
