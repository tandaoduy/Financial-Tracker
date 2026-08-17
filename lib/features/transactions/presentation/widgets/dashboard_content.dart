import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/transaction_entity.dart';
import 'transaction_list_item.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  static const _blue = Color(0xFF2563EB);
  static const _navy = Color(0xFF172554);

  final List<TransactionEntity> transactions;
  final ValueChanged<TransactionEntity> onEdit;
  final ValueChanged<TransactionEntity> onDelete;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthlyTransactions = transactions.where((item) {
      return item.transactionDate.year == now.year &&
          item.transactionDate.month == now.month;
    }).toList();
    final income = _totalOf(monthlyTransactions, TransactionType.income);
    final expense = _totalOf(monthlyTransactions, TransactionType.expense);
    final balance = income - expense;
    final recent = transactions.take(5).toList(growable: false);
    final topCategory = _topExpenseCategory(monthlyTransactions);
    final expensesByCategory = _expensesByCategory(monthlyTransactions);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _DashboardReveal(
            beginOffset: const Offset(0, -0.06),
            child: _DashboardHeader(
              monthLabel: 'Tháng ${now.month}, ${now.year}',
              balance: balance,
              income: income,
              expense: expense,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _DashboardReveal(
              delay: const Duration(milliseconds: 120),
              child: _InsightCard(
                transactionCount: monthlyTransactions.length,
                topCategory: topCategory,
                expense: expense,
                income: income,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _DashboardReveal(
              delay: const Duration(milliseconds: 180),
              child: _ExpensePieChart(categoryTotals: expensesByCategory),
            ),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 26, 20, 12),
          sliver: SliverToBoxAdapter(
            child: _DashboardReveal(
              delay: Duration(milliseconds: 200),
              child: _RecentHeader(),
            ),
          ),
        ),
        if (recent.isEmpty)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverToBoxAdapter(
              child: _DashboardReveal(
                delay: Duration(milliseconds: 280),
                child: _EmptyTransactionsCard(),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList.builder(
              itemCount: recent.length,
              itemBuilder: (context, index) {
                final transaction = recent[index];
                return _DashboardReveal(
                  delay: Duration(milliseconds: 260 + (index * 70)),
                  beginOffset: const Offset(0.08, 0),
                  child: TransactionListItem(
                    transaction: transaction,
                    onEdit: () => onEdit(transaction),
                    onDelete: () => onDelete(transaction),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  int _totalOf(
    List<TransactionEntity> source,
    TransactionType type,
  ) {
    return source
        .where((item) => item.type == type)
        .fold(0, (sum, item) => sum + item.amount);
  }

  String? _topExpenseCategory(List<TransactionEntity> source) {
    final totals = <String, int>{};
    for (final item in source) {
      if (item.type == TransactionType.expense) {
        totals.update(
          item.category,
          (value) => value + item.amount,
          ifAbsent: () => item.amount,
        );
      }
    }
    if (totals.isEmpty) return null;
    return totals.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Map<String, int> _expensesByCategory(List<TransactionEntity> source) {
    final totals = <String, int>{};
    for (final item in source) {
      if (item.type == TransactionType.expense) {
        totals.update(
          item.category,
          (value) => value + item.amount,
          ifAbsent: () => item.amount,
        );
      }
    }
    return totals;
  }
}

class _ExpensePieChart extends StatelessWidget {
  const _ExpensePieChart({required this.categoryTotals});

  static const _colors = [
    Color(0xFF2563EB),
    Color(0xFF8B5CF6),
    Color(0xFFF97316),
    Color(0xFF10B981),
    Color(0xFFF43F5E),
    Color(0xFF64748B),
  ];

  final Map<String, int> categoryTotals;

  @override
  Widget build(BuildContext context) {
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, item) => sum + item.value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiêu theo danh mục',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tỷ trọng chi tiêu trong tháng này',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 20),
          if (entries.isEmpty)
            const SizedBox(
              height: 150,
              child: Center(
                child: Text(
                  'Chưa có khoản chi nào để hiển thị.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 190,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 48,
                  sectionsSpace: 3,
                  startDegreeOffset: -90,
                  sections: [
                    for (var index = 0; index < entries.length; index++)
                      PieChartSectionData(
                        value: entries[index].value.toDouble(),
                        color: _colors[index % _colors.length],
                        radius: 42,
                        title: total == 0
                            ? ''
                            : '${(entries[index].value / total * 100).round()}%',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
              ),
            ),
            const SizedBox(height: 14),
            for (var index = 0; index < entries.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _colors[index % _colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        entries[index].key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      _compactCurrency(entries[index].value),
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
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
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.monthLabel,
    required this.balance,
    required this.income,
    required this.expense,
  });

  final String monthLabel;
  final int balance;
  final int income;
  final int expense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFF6FF), Colors.white],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào ngày mới 👋',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Tổng quan tài chính',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0D0F172A), blurRadius: 12),
                  ],
                ),
                child: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [DashboardContent._blue, DashboardContent._navy],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x352563EB),
                  blurRadius: 28,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  right: -18,
                  top: -34,
                  child: _DecorativeCircle(size: 120, opacity: 0.10),
                ),
                const Positioned(
                  right: 54,
                  bottom: -48,
                  child: _DecorativeCircle(size: 82, opacity: 0.07),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Số dư tháng này',
                          style: TextStyle(color: Color(0xFFBFDBFE)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                monthLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: balance.toDouble()),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Text(
                        _currency(value.round()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 23),
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _HeaderMetric(
                            label: 'Thu nhập',
                            amount: income,
                            icon: Icons.south_west_rounded,
                            iconColor: const Color(0xFF6EE7B7),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 38,
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _HeaderMetric(
                            label: 'Chi tiêu',
                            amount: expense,
                            icon: Icons.north_east_rounded,
                            iconColor: const Color(0xFFFDA4AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final int amount;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                _compactCurrency(amount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.transactionCount,
    required this.topCategory,
    required this.expense,
    required this.income,
  });

  final int transactionCount;
  final String? topCategory;
  final int expense;
  final int income;

  @override
  Widget build(BuildContext context) {
    final ratio = income == 0
        ? 0.0
        : (expense / income).clamp(0.0, 1.0).toDouble();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 7,
                  backgroundColor: const Color(0xFFEFF6FF),
                  color: DashboardContent._blue,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '${(ratio * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chi tiêu so với thu nhập',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  transactionCount == 0
                      ? 'Chưa có dữ liệu trong tháng này.'
                      : topCategory == null
                          ? '$transactionCount giao dịch trong tháng.'
                          : 'Chi nhiều nhất cho $topCategory · $transactionCount giao dịch.',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _RecentHeader extends StatelessWidget {
  const _RecentHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Giao dịch gần đây',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        Text(
          'Mới nhất',
          style: TextStyle(
            color: DashboardContent._blue,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyTransactionsCard extends StatelessWidget {
  const _EmptyTransactionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: DashboardContent._blue,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bắt đầu quản lý chi tiêu',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          const Text(
            'Nhấn nút + ở thanh bên dưới để ghi lại khoản thu chi đầu tiên.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DashboardReveal extends StatefulWidget {
  const _DashboardReveal({
    required this.child,
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0, 0.08),
  });

  final Widget child;
  final Duration delay;
  final Offset beginOffset;

  @override
  State<_DashboardReveal> createState() => _DashboardRevealState();
}

class _DashboardRevealState extends State<_DashboardReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : widget.beginOffset,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

String _currency(int amount) => NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(amount);

String _compactCurrency(int amount) => NumberFormat.compactCurrency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(amount);
