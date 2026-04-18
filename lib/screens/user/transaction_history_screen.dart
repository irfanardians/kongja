// Flutter translation of cocoa/src/app/pages/TransactionHistory.tsx
//
// Semua aksi dan input harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - GET /transactions
//
// Komponen reusable dibuat di folder components terpisah.

import 'package:flutter/material.dart';

import 'user_ui_shared.dart';

class _TransactionItem {
  const _TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.dateLabel,
    required this.time,
    required this.description,
    this.talentName,
    this.talentImage,
    this.duration,
    this.paymentMethod,
  });

  final int id;
  final String type;
  final int amount;
  final String dateLabel;
  final String time;
  final String description;
  final String? talentName;
  final String? talentImage;
  final int? duration;
  final String? paymentMethod;
}

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String filter = 'all';

  final transactions = const [
    _TransactionItem(id: 1, type: 'topup', amount: 5000, dateLabel: 'Today', time: '14:30', description: 'Top Up - 5000 Coins Package', paymentMethod: 'Credit Card'),
    _TransactionItem(id: 2, type: 'chat', amount: -480, dateLabel: 'Today', time: '15:45', description: 'Chat with Clara Lee', talentName: 'Clara Lee', talentImage: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200', duration: 120),
    _TransactionItem(id: 3, type: 'video', amount: -960, dateLabel: 'Yesterday', time: '20:15', description: 'Video Call with Sophie Chen', talentName: 'Sophie Chen', talentImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200', duration: 60),
    _TransactionItem(id: 4, type: 'topup', amount: 2000, dateLabel: 'Apr 13, 2024', time: '10:20', description: 'Top Up - 2000 Coins Package', paymentMethod: 'PayPal'),
    _TransactionItem(id: 5, type: 'meet', amount: -1500, dateLabel: 'Apr 12, 2024', time: '18:00', description: 'Offline Meeting with Clara Lee', talentName: 'Clara Lee', talentImage: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200', duration: 180),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = transactions.where((item) {
      if (filter == 'all') return true;
      if (filter == 'topup') return item.type == 'topup';
      return item.type != 'topup';
    }).toList();
    final totalTopUp = transactions.where((item) => item.type == 'topup').fold<int>(0, (sum, item) => sum + item.amount);
    final totalSpent = transactions.where((item) => item.type != 'topup').fold<int>(0, (sum, item) => sum + item.amount.abs());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF8F5A38), Color(0xFFB57440)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 4),
                      const Text('Transaction History', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), shape: BoxShape.circle),
                          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Current Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              SizedBox(height: 4),
                              Text('🪙 1,250', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pushNamed(context, '/topup'),
                          style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: userAmberDark, shape: const StadiumBorder()),
                          child: const Text('Top Up'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _summaryCard(Icons.arrow_upward_rounded, 'Total Top Up', totalTopUp)),
                      const SizedBox(width: 12),
                      Expanded(child: _summaryCard(Icons.arrow_downward_rounded, 'Total Spent', totalSpent)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
              child: Row(
                children: [
                  _filterChip('all', 'All'),
                  const SizedBox(width: 8),
                  _filterChip('topup', 'Top Up'),
                  const SizedBox(width: 8),
                  _filterChip('spending', 'Spending'),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF0ECE8)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: _badgeColor(item.type), shape: BoxShape.circle),
                          child: Icon(_transactionIcon(item.type), color: _iconColor(item.type), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: Text(item.description, style: const TextStyle(fontWeight: FontWeight.w700))),
                                  Text(
                                    '${item.amount > 0 ? '+' : '-'}🪙 ${item.amount.abs()}',
                                    style: TextStyle(fontWeight: FontWeight.w700, color: item.amount > 0 ? const Color(0xFF2FA655) : const Color(0xFFD34C4C)),
                                  ),
                                ],
                              ),
                              if (item.talentName != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    CircleAvatar(radius: 10, backgroundImage: NetworkImage(item.talentImage!)),
                                    const SizedBox(width: 6),
                                    Text(item.talentName!, style: const TextStyle(fontSize: 13, color: Color(0xFF7E7770))),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                runSpacing: 6,
                                children: [
                                  _detailTag(Icons.calendar_today_outlined, item.dateLabel),
                                  _detailTag(Icons.schedule_rounded, item.time),
                                  if (item.duration != null) _detailTag(Icons.timer_outlined, '${item.duration} min'),
                                ],
                              ),
                              if (item.paymentMethod != null) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: const Color(0xFFEAF8EF), borderRadius: BorderRadius.circular(999)),
                                  child: Text('💳 ${item.paymentMethod}', style: const TextStyle(fontSize: 12, color: Color(0xFF2FA655), fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(IconData icon, String label, int value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 16, color: Colors.white), const SizedBox(width: 6), Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)))]),
          const SizedBox(height: 6),
          Text('🪙 $value', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final active = filter == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => filter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? userAmberDark : const Color(0xFFF1EEEA),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: active ? Colors.white : const Color(0xFF6E6964), fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _detailTag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFFAAA39C)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8D8781))),
      ],
    );
  }

  Color _badgeColor(String type) {
    switch (type) {
      case 'topup':
        return const Color(0xFFEAF8EF);
      case 'chat':
        return const Color(0xFFEAF1FF);
      case 'voice':
        return const Color(0xFFE8FAF2);
      case 'video':
        return const Color(0xFFF2EAFE);
      default:
        return const Color(0xFFFFF0E2);
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'topup':
        return const Color(0xFF2FA655);
      case 'chat':
        return const Color(0xFF3B82F6);
      case 'voice':
        return const Color(0xFF1FA971);
      case 'video':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFFDA7F29);
    }
  }

  IconData _transactionIcon(String type) {
    switch (type) {
      case 'topup':
        return Icons.arrow_upward_rounded;
      case 'chat':
        return Icons.message_rounded;
      case 'voice':
        return Icons.call_rounded;
      case 'video':
        return Icons.videocam_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }
}
