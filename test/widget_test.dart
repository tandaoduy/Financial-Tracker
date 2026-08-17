import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/features/transactions/presentation/pages/transaction_form_page.dart';

void main() {
  group('TransactionFormPage', () {
    testWidgets('hiển thị loại giao dịch và danh mục', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TransactionFormPage(),
        ),
      );

      expect(find.text('Thêm giao dịch'), findsOneWidget);
      expect(find.text('Chi tiêu'), findsOneWidget);
      expect(find.text('Thu nhập'), findsOneWidget);
      expect(find.text('Chọn danh mục'), findsOneWidget);
      expect(find.text('Ăn uống'), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
    });

    testWidgets('mở modal và hiển thị lỗi khi gửi form rỗng', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TransactionFormPage(),
        ),
      );

      await tester.tap(find.text('Ăn uống'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu giao dịch'));
      await tester.pump();

      expect(find.text('Vui lòng nhập tên giao dịch'), findsOneWidget);
      expect(find.text('Số tiền phải lớn hơn 0'), findsOneWidget);
    });

    testWidgets('chấp nhận dữ liệu giao dịch hợp lệ', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => context.push('/form'),
                  child: const Text('Mở form'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/form',
            builder: (context, state) => const TransactionFormPage(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );

      await tester.tap(find.text('Mở form'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ăn uống'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Ăn trưa');
      await tester.enterText(fields.at(1), '50000');

      await tester.tap(find.widgetWithText(FilledButton, 'Lưu giao dịch'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập tên giao dịch'), findsNothing);
      expect(find.text('Số tiền phải lớn hơn 0'), findsNothing);
      expect(find.text('Mở form'), findsOneWidget);
    });
  });
}
