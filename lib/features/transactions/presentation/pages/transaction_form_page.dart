import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/transaction_entity.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({this.transaction, super.key});

  final TransactionEntity? transaction;

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  static const _blue = Color(0xFF2563EB);

  static const _expenseCategories = <_CategoryOption>[
    _CategoryOption('Ăn uống', Icons.restaurant_rounded),
    _CategoryOption('Mua sắm', Icons.shopping_bag_rounded),
    _CategoryOption('Di chuyển', Icons.directions_bus_rounded),
    _CategoryOption('Giải trí', Icons.sports_esports_rounded),
    _CategoryOption('Nhà ở', Icons.home_rounded),
    _CategoryOption('Sức khỏe', Icons.favorite_rounded),
    _CategoryOption('Giáo dục', Icons.school_rounded),
    _CategoryOption('Điện thoại', Icons.smartphone_rounded),
    _CategoryOption('Làm đẹp', Icons.content_cut_rounded),
    _CategoryOption('Thể thao', Icons.fitness_center_rounded),
    _CategoryOption('Quần áo', Icons.checkroom_rounded),
    _CategoryOption('Du lịch', Icons.flight_rounded),
    _CategoryOption('Thú cưng', Icons.pets_rounded),
    _CategoryOption('Sửa chữa', Icons.build_rounded),
    _CategoryOption('Quà tặng', Icons.card_giftcard_rounded),
    _CategoryOption('Khác', Icons.more_horiz_rounded),
  ];

  static const _incomeCategories = <_CategoryOption>[
    _CategoryOption('Lương', Icons.work_rounded),
    _CategoryOption('Đầu tư', Icons.trending_up_rounded),
    _CategoryOption('Làm thêm', Icons.payments_rounded),
    _CategoryOption('Tiền thưởng', Icons.emoji_events_rounded),
    _CategoryOption('Quà tặng', Icons.redeem_rounded),
    _CategoryOption('Khác', Icons.more_horiz_rounded),
  ];

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _reasonController;
  late TransactionType _type;
  String? _selectedCategory;

  List<_CategoryOption> get _categories =>
      _type == TransactionType.expense ? _expenseCategories : _incomeCategories;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _titleController = TextEditingController(text: transaction?.title);
    _amountController = TextEditingController(text: transaction?.amount.toString());
    _reasonController = TextEditingController(text: transaction?.note);
    _type = transaction?.type ?? TransactionType.expense;
    _selectedCategory = transaction?.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          widget.transaction == null ? 'Thêm giao dịch' : 'Sửa giao dịch',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(76),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            child: _TypeSelector(
              selectedType: _type,
              onChanged: (type) {
                setState(() {
                  _type = type;
                  _selectedCategory = null;
                });
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
              child: Text(
                'Chọn danh mục',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Chạm vào một danh mục để nhập thông tin giao dịch.',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final option = _categories[index];
                  return _CategoryTile(
                    option: option,
                    selected: option.name == _selectedCategory,
                    onTap: () => _selectCategory(option.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCategory(String category) async {
    setState(() => _selectedCategory = category);
    final shouldSave = await _showTransactionDetails();

    if (shouldSave == true && mounted) {
      final now = DateTime.now();
      final oldTransaction = widget.transaction;
      context.pop(
        TransactionEntity(
          id: oldTransaction?.id,
          title: _titleController.text.trim(),
          amount: int.parse(_amountController.text),
          type: _type,
          category: category,
          note: _reasonController.text.trim().isEmpty
              ? null
              : _reasonController.text.trim(),
          transactionDate: oldTransaction?.transactionDate ?? now,
          createdAt: oldTransaction?.createdAt ?? now,
          updatedAt: now,
        ),
      );
    }
  }

  Future<bool?> _showTransactionDetails() {
    final formKey = GlobalKey<FormState>();

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SafeArea(
              top: false,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(_selectedCategoryIcon(), color: _blue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedCategory ?? '',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  _type == TransactionType.expense
                                      ? 'Khoản chi tiêu'
                                      : 'Khoản thu nhập',
                                  style: const TextStyle(color: Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: _titleController,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Tên giao dịch',
                          prefixIcon: Icon(Icons.edit_note_rounded),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Vui lòng nhập tên giao dịch'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Số tiền',
                          prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                          suffixText: '₫',
                        ),
                        validator: (value) {
                          final amount = int.tryParse(value ?? '');
                          return amount == null || amount <= 0
                              ? 'Số tiền phải lớn hơn 0'
                              : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Lý do / ghi chú',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(sheetContext, true);
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          backgroundColor: _blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Lưu giao dịch',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _selectedCategoryIcon() {
    return _categories
        .firstWhere((item) => item.name == _selectedCategory)
        .icon;
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selectedType, required this.onChanged});

  final TransactionType selectedType;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: TransactionType.values.map((type) {
          final selected = type == selectedType;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type == TransactionType.expense ? 'Chi tiêu' : 'Thu nhập',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? const Color(0xFF1E3A8A) : Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _CategoryOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF2563EB) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? const Color(0xFF1D4ED8) : const Color(0xFFE5E7EB),
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x0D000000), blurRadius: 10),
              ],
            ),
            child: Icon(
              option.icon,
              color: selected ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            option.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryOption {
  const _CategoryOption(this.name, this.icon);

  final String name;
  final IconData icon;
}
