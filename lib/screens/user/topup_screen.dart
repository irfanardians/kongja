// Flutter translation of cocoa/src/app/pages/TopUp.tsx
//
// Semua aksi dan input harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - POST /topup
//
// Komponen reusable dibuat di folder components terpisah.

import 'package:flutter/material.dart';

import 'user_ui_shared.dart';

enum _TopUpStep { packages, payment, success }

class _CoinPackage {
  const _CoinPackage({required this.coins, required this.price, required this.bonus, this.popular = false});

  final int coins;
  final String price;
  final String bonus;
  final bool popular;
}

class _PaymentMethod {
  const _PaymentMethod({required this.id, required this.name, required this.icon, required this.description});

  final String id;
  final String name;
  final IconData icon;
  final String description;
}

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({Key? key}) : super(key: key);

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final packages = const [
    _CoinPackage(coins: 100, price: '\$4.99', bonus: ''),
    _CoinPackage(coins: 500, price: '\$19.99', bonus: '+50 bonus'),
    _CoinPackage(coins: 1000, price: '\$34.99', bonus: '+150 bonus', popular: true),
    _CoinPackage(coins: 2500, price: '\$79.99', bonus: '+500 bonus'),
    _CoinPackage(coins: 5000, price: '\$149.99', bonus: '+1200 bonus'),
  ];
  final methods = const [
    _PaymentMethod(id: 'card', name: 'Credit/Debit Card', icon: Icons.credit_card_rounded, description: 'Visa, Mastercard, Amex'),
    _PaymentMethod(id: 'paypal', name: 'PayPal', icon: Icons.account_balance_wallet_rounded, description: 'Pay with PayPal'),
    _PaymentMethod(id: 'googlepay', name: 'Google Pay', icon: Icons.smartphone_rounded, description: 'Fast & secure'),
    _PaymentMethod(id: 'bank', name: 'Bank Transfer', icon: Icons.account_balance_rounded, description: 'Direct transfer'),
  ];

  int selectedPackage = 2;
  String selectedPayment = 'card';
  _TopUpStep step = _TopUpStep.packages;

  void _handleBack() {
    if (step == _TopUpStep.payment) {
      setState(() => step = _TopUpStep.packages);
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final package = packages[selectedPackage];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFA96935), Color(0xFFC67334)]),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _handleBack,
                    icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    step == _TopUpStep.packages ? 'Top Up Coins' : step == _TopUpStep.payment ? 'Payment Method' : 'Success!',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (step == _TopUpStep.packages) ...[
                      const Text('Choose a coin package', style: TextStyle(color: Color(0xFF817A74))),
                      const SizedBox(height: 20),
                      ...List.generate(packages.length, (index) {
                        final item = packages[index];
                        final active = selectedPackage == index;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: InkWell(
                            onTap: () => setState(() => selectedPackage = index),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: active ? const Color(0xFFFFF6EA) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: active ? userAmberDark : const Color(0xFFE8E1D8), width: 2),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  if (item.popular)
                                    Positioned(
                                      top: -28,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(colors: [Color(0xFFA96935), Color(0xFFC67334)]),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Text('Most Popular', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: [
                                                Text('🪙 ${item.coins}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                                                if (item.bonus.isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFEAF8EF),
                                                      borderRadius: BorderRadius.circular(999),
                                                    ),
                                                    child: Text(item.bonus, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2FA655))),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            const Text('Coins', style: TextStyle(color: Color(0xFF8E8881))),
                                          ],
                                        ),
                                      ),
                                      Text(item.price, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: userAmberDark)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                    if (step == _TopUpStep.payment) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFFF6EA), Color(0xFFFFEBD9)]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('You\'re purchasing:', style: TextStyle(color: Color(0xFF817A74))),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(child: Text('🪙 ${package.coins}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700))),
                                Text(package.price, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: userAmberDark)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Select payment method', style: TextStyle(color: Color(0xFF817A74))),
                      const SizedBox(height: 14),
                      ...methods.map((method) {
                        final active = selectedPayment == method.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: InkWell(
                            onTap: () => setState(() => selectedPayment = method.id),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: active ? const Color(0xFFFFF6EA) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: active ? userAmberDark : const Color(0xFFE8E1D8), width: 2),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Color(0xFFFFF3E7), Color(0xFFFFE7CF)]),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(method.icon, color: userAmberDark),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(method.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 2),
                                        Text(method.description, style: const TextStyle(fontSize: 13, color: Color(0xFF8E8881))),
                                      ],
                                    ),
                                  ),
                                  if (active)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(color: userAmberDark, shape: BoxShape.circle),
                                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                    if (step == _TopUpStep.success)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 36),
                            Container(
                              width: 84,
                              height: 84,
                              decoration: const BoxDecoration(color: Color(0xFFEAF8EF), shape: BoxShape.circle),
                              child: const Icon(Icons.check_rounded, size: 48, color: Color(0xFF2FA655)),
                            ),
                            const SizedBox(height: 16),
                            const Text('Payment Successful!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text('🪙 ${package.coins} coins have been added to your account', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF817A74))),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFFFF6EA), Color(0xFFFFEBD9)]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Column(
                                children: [
                                  Text('New Balance', style: TextStyle(color: Color(0xFF817A74))),
                                  SizedBox(height: 4),
                                  Text('🪙 2,250', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: userAmberDark)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (step != _TopUpStep.success)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE8E1D8))),
                ),
                child: step == _TopUpStep.packages
                    ? SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => setState(() => step = _TopUpStep.payment),
                          style: FilledButton.styleFrom(backgroundColor: userAmberDark, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                          child: const Text('Continue to Payment'),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => setState(() => step = _TopUpStep.success),
                              style: FilledButton.styleFrom(backgroundColor: userAmberDark, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                              child: Text('Pay ${package.price}'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => setState(() => step = _TopUpStep.packages),
                              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), side: const BorderSide(color: Color(0xFFE8E1D8))),
                              child: const Text('Back to Packages'),
                            ),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
