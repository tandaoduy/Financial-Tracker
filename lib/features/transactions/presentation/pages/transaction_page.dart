import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/dashboard_content.dart';
import '../widgets/transaction_list_item.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<TransactionBloc, TransactionState>(
          listenWhen: (previous, current) =>
              previous.actionStatus != current.actionStatus,
          listener: _handleActionState,
          builder: (context, state) {
            if (state.status == TransactionStatus.loading &&
                state.transactions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == TransactionStatus.failure &&
                state.transactions.isEmpty) {
              return _ErrorView(message: state.errorMessage);
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: _selectedIndex == 0
                  ? DashboardContent(
                      key: const ValueKey('dashboard'),
                      transactions: state.transactions,
                      onEdit: (item) => _openForm(context, item),
                      onDelete: (item) => _confirmDelete(context, item),
                    )
                  : _TransactionHistory(
                      key: const ValueKey('history'),
                      transactions: state.transactions,
                      onEdit: (item) => _openForm(context, item),
                      onDelete: (item) => _confirmDelete(context, item),
                    ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x331B1724),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _openForm(context),
          elevation: 0,
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 76,
        padding: EdgeInsets.zero,
        color: Colors.white,
        elevation: 16,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            Expanded(
              child: _NavigationItem(
                icon: Icons.grid_view_rounded,
                label: 'Tổng quan',
                selected: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
            ),
            const SizedBox(width: 74),
            Expanded(
              child: _NavigationItem(
                icon: Icons.receipt_long_rounded,
                label: 'Giao dịch',
                selected: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleActionState(BuildContext context, TransactionState state) {
    if (state.actionStatus == TransactionActionStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu giao dịch')),
      );
    } else if (state.actionStatus == TransactionActionStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Đã có lỗi xảy ra')),
      );
    }
  }

  Future<void> _openForm(
    BuildContext context, [
    TransactionEntity? transaction,
  ]) async {
    final result = await context.pushNamed<TransactionEntity>(
      AppRouteNames.transactionForm,
      extra: transaction,
    );

    if (result == null || !context.mounted) return;

    final bloc = context.read<TransactionBloc>();
    bloc.add(
      transaction == null
          ? TransactionAddRequested(result)
          : TransactionUpdateRequested(result),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TransactionEntity transaction,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: Text('Bạn có chắc muốn xóa “${transaction.title}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    final id = transaction.id;
    if (shouldDelete == true && id != null && context.mounted) {
      context.read<TransactionBloc>().add(TransactionDeleteRequested(id));
    }
  }
}

class _TransactionHistory extends StatelessWidget {
  const _TransactionHistory({
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final List<TransactionEntity> transactions;
  final ValueChanged<TransactionEntity> onEdit;
  final ValueChanged<TransactionEntity> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tất cả giao dịch',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        Expanded(
          child: transactions.isEmpty
              ? const Center(child: Text('Chưa có giao dịch'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 116),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final item = transactions[index];
                    return TransactionListItem(
                      transaction: item,
                      onEdit: () => onEdit(item),
                      onDelete: () => onDelete(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF1B1724) : const Color(0xFF9B96A0);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48),
          const SizedBox(height: 12),
          Text(message ?? 'Không thể tải dữ liệu'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context
                .read<TransactionBloc>()
                .add(const TransactionsStarted()),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
