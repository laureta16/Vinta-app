import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinta/core/providers/order_provider.dart';
import 'package:vinta/core/providers/notification_provider.dart';
import 'package:vinta/core/models/clothing_item.dart';
import '../../../../theme/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  final ClothingItem item;
  const CheckoutScreen({super.key, required this.item});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  String _selectedPayment = 'card';

  void _confirmOrder() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);

    orderProvider.addOrder(
      sellerId: widget.item.sellerId,
      itemId: widget.item.id,
      itemTitle: widget.item.title,
      imageUrl: widget.item.imageUrls.isNotEmpty ? widget.item.imageUrls.first : '',
      totalPrice: widget.item.price + 200 + (widget.item.price * 0.05),
    );

    notifProvider.notifyOrderPlaced(widget.item.title);

    setState(() => _currentStep++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHECKOUT',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16)),
      ),
      body: Column(
        children: [
          // Stepper header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _buildStepDot(0, 'Review'),
                Expanded(child: Container(height: 2, color: _currentStep >= 1 ? AppColors.accentColor : AppColors.lightGray)),
                _buildStepDot(1, 'Payment'),
                Expanded(child: Container(height: 2, color: _currentStep >= 2 ? AppColors.accentColor : AppColors.lightGray)),
                _buildStepDot(2, 'Done'),
              ],
            ),
          ),

          Expanded(
            child: _currentStep == 0
                ? _buildReviewStep()
                : _currentStep == 1
                    ? _buildPaymentStep()
                    : _buildConfirmationStep(),
          ),

          // Bottom bar
          if (_currentStep < 2)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentStep == 1) {
                      _confirmOrder();
                    } else {
                      setState(() => _currentStep++);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _currentStep == 0 ? 'PROCEED TO PAYMENT' : 'CONFIRM ORDER',
                    style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive ? AppColors.accentColor : AppColors.lightGray,
          child: isActive
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text('${step + 1}', style: const TextStyle(fontSize: 11)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildReviewStep() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Item summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(widget.item.imageUrls.first,
                    width: 80, height: 80, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.title,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${widget.item.brand} · ${widget.item.size}',
                        style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('${widget.item.price.toInt()} Lek',
                        style: const TextStyle(fontWeight: FontWeight.w900,
                            color: AppColors.accentColor, fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildOrderRow('Subtotal', '${widget.item.price.toInt()} Lek'),
        _buildOrderRow('Shipping', '200 Lek'),
        _buildOrderRow('Service Fee', '${(widget.item.price * 0.05).toInt()} Lek'),
        const Divider(height: 32),
        _buildOrderRow('Total',
            '${(widget.item.price + 200 + widget.item.price * 0.05).toInt()} Lek',
            bold: true),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('PAYMENT METHOD',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        _buildPaymentOption('card', Icons.credit_card_rounded, 'Credit / Debit Card'),
        _buildPaymentOption('cash', Icons.payments_rounded, 'Cash on Delivery'),
        _buildPaymentOption('bank', Icons.account_balance_rounded, 'Bank Transfer'),
        const SizedBox(height: 32),
        if (_selectedPayment == 'card') ...[
          TextFormField(
            decoration: const InputDecoration(labelText: 'Card Number', hintText: '4242 4242 4242 4242'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Expiry', hintText: 'MM/YY'))),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'CVC', hintText: '123'))),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green),
            ),
            const SizedBox(height: 32),
            const Text('Order Confirmed! 🎉',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text('Your order for ${widget.item.title} has been placed.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 32),
            Text('Order #${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.accentColor)),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('BACK TO HOME', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
              color: bold ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w500)),
          Text(value, style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              fontSize: bold ? 18 : 14)),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: _selectedPayment == value ? AppColors.accentColor : AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedPayment,
        onChanged: (v) => setState(() => _selectedPayment = v!),
        title: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        controlAffinity: ListTileControlAffinity.trailing,
        activeColor: AppColors.accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
