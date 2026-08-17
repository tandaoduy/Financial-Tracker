import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/transactions/domain/entities/transaction_entity.dart';
import '../../features/transactions/presentation/pages/transaction_form_page.dart';
import '../../features/transactions/presentation/pages/transaction_page.dart';

abstract final class AppRouteNames {
  static const transactions = 'transactions';
  static const transactionForm = 'transaction-form';
}

abstract final class AppRoutePaths {
  static const transactions = '/';
  static const transactionForm = '/transactions/form';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutePaths.transactions,
  routes: [
    GoRoute(
      path: AppRoutePaths.transactions,
      name: AppRouteNames.transactions,
      builder: (context, state) => const TransactionPage(),
    ),
    GoRoute(
      path: AppRoutePaths.transactionForm,
      name: AppRouteNames.transactionForm,
      builder: (context, state) {
        final transaction = state.extra;

        return TransactionFormPage(
          transaction: transaction is TransactionEntity ? transaction : null,
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Không tìm thấy trang')),
    body: Center(child: Text(state.error.toString())),
  ),
);
