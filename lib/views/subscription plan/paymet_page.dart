import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/common%20plan%20badge/common_plan_badge.dart';
import 'package:smartbecho/controllers/subscription%20controller/payment_controller.dart';
import 'package:smartbecho/controllers/subscription%20controller/user_subscription_controller.dart';
import 'package:smartbecho/models/subscription%20models/subscription_models/subscription_plan_model.dart';
import 'package:smartbecho/utils/common/app%20borders/app_dotted_line.dart';
import 'package:smartbecho/utils/helper/toast_helper.dart';

class PaymentPage extends StatefulWidget {
  final SubscriptionPlanWithUpgrade planWithUpgrade;

  const PaymentPage({super.key, required this.planWithUpgrade});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late PaymentController _paymentController;
  final promoCodeController = TextEditingController();
  final RxBool _paymentProcessed = false.obs;
  final SubscriptionController _subscriptionController = Get.put(
    SubscriptionController(),
  );

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // 🔥 DEFER initialization to after build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePayment();
    });
  }

  void _initializeControllers() {
    try {
      _paymentController =
          Get.isRegistered<PaymentController>()
              ? Get.find<PaymentController>()
              : Get.put(PaymentController());
    } catch (e) {
      debugPrint('Controller initialization error: $e');
    }
  }

  void _initializePayment() {
    try {
      // 🔥 Check if same plan
      if (widget.planWithUpgrade.isSamePlan == true) {
        ToastHelper.warning(
          message: 'Already Subscribed',
          description: 'You are already on this plan',
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Get.back();
        });
        return;
      }

      // 🔥 Set payment context with upgrade price directly from API
      _paymentController.setPaymentContext(
        planCode: widget.planWithUpgrade.planCode ?? '',
        period: widget.planWithUpgrade.period ?? '',
        amount: widget.planWithUpgrade.upgradePrice ?? 0.0,
        planName: widget.planWithUpgrade.planName ?? '',
      );
    } catch (e) {
      debugPrint('Payment initialization error: $e');
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          ToastHelper.error(
            message: 'Initialization Error',
            description: e.toString(),
          );
        }
      });
    }
  }

  Future<void> _proceedToPayment() async {
    try {
      if (_paymentProcessed.value) return;
      _paymentProcessed.value = true;

      await _paymentController.openRazorpayCheckout(
        planName: widget.planWithUpgrade.planName ?? 'Premium Plan',
        promoCode:
            promoCodeController.text.isNotEmpty
                ? promoCodeController.text.trim()
                : null,
      );

      Future.delayed(const Duration(seconds: 2), () {
        _paymentProcessed.value = false;
      });
    } catch (e) {
      debugPrint('Payment error: $e');
      _paymentProcessed.value = false;
      ToastHelper.error(message: 'Payment Failed', description: e.toString());
    }
  }

  void _applyPromoCode() {
    try {
      if (promoCodeController.text.isEmpty) {
        ToastHelper.warning(
          message: 'Invalid Code',
          description: 'Please enter a promo code',
        );
        return;
      }

      // 🔥 Use upgrade price as base for promo code calculation
      _paymentController.validatePromoCode(
        code: promoCodeController.text.trim(),
        planCode: widget.planWithUpgrade.planCode ?? '',
        basePrice: widget.planWithUpgrade.upgradePrice ?? 0.0,
        isUpgrade: widget.planWithUpgrade.isUpgrade ?? false,
      );
    } catch (e) {
      debugPrint('Promo code error: $e');
      ToastHelper.error(message: 'Promo Code Error', description: e.toString());
    }
  }

  void _removePromoCode() {
    promoCodeController.clear();
    _paymentController.removePromoCode(
      widget.planWithUpgrade.upgradePrice ?? 0.0,
    );
    ToastHelper.info(message: 'Promo code removed');
  }

  @override
  void dispose() {
    promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          (widget.planWithUpgrade.isUpgrade ?? false)
              ? 'Upgrade Plan'
              : 'Complete Payment',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCompactPlanDetails(),
                const SizedBox(height: 12),
                if (widget.planWithUpgrade.isUpgrade ?? false) ...[
                  _buildCompactUpgradeInfo(),
                  const SizedBox(height: 12),
                ],
                _buildCompactPromoCode(),
                const SizedBox(height: 12),
                _buildCompactPaymentSummary(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildPayNowButton(),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final displayAmount = _paymentController.finalAmount.value;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryLight,
              AppColors.primaryLight.withOpacity(0.8),
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: Column(
          children: [
            CommonPlanBadge(
              planName: widget.planWithUpgrade.planName ?? 'Premium Plan',
              size: 36,
            ),
            const SizedBox(height: 10),
            Text(
              widget.planWithUpgrade.planName ?? 'Premium Plan',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              widget.planWithUpgrade.period == 'MONTHLY'
                  ? 'Monthly Subscription'
                  : 'Yearly Subscription',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            if (widget.planWithUpgrade.isUpgrade ?? false) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange[300],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  '📈 Upgrade',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                '₹${displayAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCompactPlanDetails() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.description,
                  color: AppColors.primaryLight,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Plan Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCompactDetailRow(
            'Duration',
            widget.planWithUpgrade.period == 'MONTHLY' ? '1 Month' : '1 Year',
          ),
          if (widget.planWithUpgrade.maxShopsAllowed != null) ...[
            const SizedBox(height: 8),
            _buildCompactDetailRow(
              'Max Shops',
              '${widget.planWithUpgrade.maxShopsAllowed}',
            ),
          ],
          if (widget.planWithUpgrade.trialDays != null &&
              widget.planWithUpgrade.trialDays! > 0) ...[
            const SizedBox(height: 8),
            _buildCompactDetailRow(
              'Trial',
              '${widget.planWithUpgrade.trialDays} Days',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactUpgradeInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.info,
                  color: AppColors.primaryLight,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Upgrade Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your Plan',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${widget.planWithUpgrade.currentPlanPrice?.toStringAsFixed(0) ?? '0'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.trending_up, color: Colors.green, size: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'New',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.planWithUpgrade.planName ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${widget.planWithUpgrade.basePrice?.toStringAsFixed(0) ?? '0'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.planWithUpgrade.message != null &&
              widget.planWithUpgrade.message!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.planWithUpgrade.message!,
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactPromoCode() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.local_offer,
                  color: AppColors.primaryLight,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Promo Code',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final hasPromo = _paymentController.appliedPromoCode.value != null;
            final isLoading = _paymentController.promoLoading.value;

            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: promoCodeController,
                    enabled: !hasPromo,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      filled: true,
                      fillColor: hasPromo ? Colors.grey[200] : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      isDense: true,
                      hintStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (!hasPromo)
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _applyPromoCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'Apply',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                    ),
                  )
                else
                  SizedBox(
                    height: 44,
                    child: IconButton(
                      onPressed: _removePromoCode,
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.red,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                      ),
                    ),
                  ),
              ],
            );
          }),
          Obx(() {
            final hasPromo = _paymentController.appliedPromoCode.value != null;
            if (!hasPromo) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Promo code applied successfully!',
                        style: TextStyle(
                          color: Colors.green[900],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompactPaymentSummary() {
    return Obx(() {
      final baseAmount = _paymentController.baseAmount.value;
      final discountAmount = _paymentController.discountAmount.value;
      final afterDiscount = baseAmount - discountAmount;
      final gstAmount = (afterDiscount * 18) / 100;
      final finalAmount = afterDiscount + gstAmount;

      bool isFreeUpgrade = (widget.planWithUpgrade.upgradePrice ?? 0) <= 0;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: AppColors.primaryLight,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Bill Summary',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCompactDetailRow('Base', '₹${baseAmount.toStringAsFixed(2)}'),
            if (discountAmount > 0) ...[
              const SizedBox(height: 8),
              _buildCompactDetailRow(
                'Discount',
                '- ₹${discountAmount.toStringAsFixed(2)}',
              ),
            ],
            const SizedBox(height: 8),
            _buildCompactDetailRow(
              'Subtotal',
              '₹${afterDiscount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildCompactDetailRow(
              'GST (18%)',
              '₹${gstAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 10),
            // Dotted Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: CustomPaint(
                size: const Size(double.infinity, 1),
                painter: AppDottedLine(),
              ),
            ),

            const SizedBox(height: 10),
            _buildCompactDetailRow(
              'Total',
              '₹${finalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
            if (isFreeUpgrade) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.celebration, color: Colors.green[700], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Upgrade is free with your current credit!',
                        style: TextStyle(
                          color: Colors.green[900],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildCompactDetailRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.primaryLight : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPayNowButton() {
    return Obx(() {
      final isProcessed = _paymentProcessed.value;
      final isOrderLoading = _paymentController.orderLoading.value;
      final isSubscribing = _paymentController.subscribeLoading.value; // 🔥 NEW

      bool isDisabled = false;
      String disabledReason = '';

      // 🔥 Show loading during subscription creation
      if (isSubscribing) {
        isDisabled = true;
        disabledReason = 'Creating subscription...';
      } else if (isOrderLoading || isProcessed) {
        isDisabled = true;
        disabledReason = 'Processing...';
      } else if ((widget.planWithUpgrade.upgradePrice ?? 0) <= 0) {
        isDisabled = true;
        disabledReason = 'Free Upgrade';
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isDisabled ? null : _proceedToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child:
                (isOrderLoading || isSubscribing) // 🔥 Show loading for both
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payment, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          isDisabled && disabledReason != 'Processing...'
                              ? disabledReason
                              : 'Pay ₹${_paymentController.finalAmount.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      );
    });
  }
}
