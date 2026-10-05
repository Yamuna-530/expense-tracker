import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('transactions');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14B8A6),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F8),
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
    );
  }
}

// ------------------------------------------------------------
// DATA
// ------------------------------------------------------------

const List<String> expenseCategories = [
  'Food',
  'Travel',
  'Bills',
  'Shopping',
  'Health',
  'Other',
];

const List<String> incomeCategories = ['Salary', 'Business', 'Gift', 'Other'];

final money = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

List<Map> getAll() {
  final box = Hive.box('transactions');

  final list = box.keys.map((key) {
    final item = Map<String, dynamic>.from(box.get(key));
    item['key'] = key;
    return item;
  }).toList();

  list.sort((a, b) => b['date'].compareTo(a['date']));

  return list;
}

// ------------------------------------------------------------
// COLORS
// ------------------------------------------------------------

const Color primaryColor = Color(0xFF14B8A6);
const Color darkColor = Color(0xFF102A2A);
const Color backgroundColor = Color(0xFFF5F7F8);
const Color greenColor = Color(0xFF16A34A);
const Color redColor = Color(0xFFEF4444);

// ------------------------------------------------------------
// HOME SCREEN
// ------------------------------------------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  IconData categoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Travel':
        return Icons.directions_car_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Health':
        return Icons.favorite_rounded;
      case 'Salary':
        return Icons.work_rounded;
      case 'Business':
        return Icons.business_center_rounded;
      case 'Gift':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ------------------------------------------------------
      // FLOATING ADD BUTTON
      // ------------------------------------------------------
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: ValueListenableBuilder(
        valueListenable: Hive.box('transactions').listenable(),

        builder: (context, box, _) {
          final items = getAll();

          double income = 0;
          double expense = 0;

          for (final transaction in items) {
            if (transaction['isIncome'] == true) {
              income += transaction['amount'];
            } else {
              expense += transaction['amount'];
            }
          }

          final balance = income - expense;

          return CustomScrollView(
            slivers: [
              // ------------------------------------------------
              // TOP HEADER
              // ------------------------------------------------

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 50, 24, 10),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: primaryColor,
                          size: 26,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Your Financial Dashboard',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: darkColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Reports
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          tooltip: 'Reports',
                          icon: const Icon(
                            Icons.bar_chart_rounded,
                            color: darkColor,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReportsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ------------------------------------------------
              // BALANCE CARD
              // ------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.25),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL BALANCE',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          money.format(balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.trending_up_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Financial Overview',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------
              // INCOME / EXPENSE CARDS
              // ------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Income',
                          amount: income,
                          icon: Icons.arrow_downward_rounded,
                          color: greenColor,
                          background: const Color(0xFFEAF8EF),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: _SummaryCard(
                          title: 'Expenses',
                          amount: expense,
                          icon: Icons.arrow_upward_rounded,
                          color: redColor,
                          background: const Color(0xFFFFEEEE),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ------------------------------------------------
              // QUICK OVERVIEW
              // ------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quick Overview',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: darkColor,
                        ),
                      ),
                      Text(
                        '${items.length} transaction${items.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ------------------------------------------------
              // CATEGORY MINI CARDS
              // ------------------------------------------------
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 105,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _QuickCategory(
                        icon: Icons.restaurant_rounded,
                        title: 'Food',
                        color: Colors.orange,
                      ),
                      _QuickCategory(
                        icon: Icons.shopping_bag_rounded,
                        title: 'Shopping',
                        color: Colors.purple,
                      ),
                      _QuickCategory(
                        icon: Icons.directions_car_rounded,
                        title: 'Travel',
                        color: Colors.blue,
                      ),
                      _QuickCategory(
                        icon: Icons.receipt_long_rounded,
                        title: 'Bills',
                        color: Colors.red,
                      ),
                      _QuickCategory(
                        icon: Icons.favorite_rounded,
                        title: 'Health',
                        color: Colors.pink,
                      ),
                    ],
                  ),
                ),
              ),

              // ------------------------------------------------
              // RECENT TRANSACTIONS TITLE
              // ------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: darkColor,
                        ),
                      ),
                      if (items.isNotEmpty)
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ------------------------------------------------
              // TRANSACTIONS
              // ------------------------------------------------
              if (items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              size: 34,
                              color: primaryColor,
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Your financial journey starts here ✨',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: darkColor,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Add your first transaction and start tracking your money.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, height: 1.4),
                          ),

                          const SizedBox(height: 20),

                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add First Transaction'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final t = items[index];
                      final isIncome = t['isIncome'] == true;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: ValueKey(t['key']),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 25),
                            decoration: BoxDecoration(
                              color: redColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            Hive.box('transactions').delete(t['key']);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.035),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: (isIncome ? greenColor : redColor)
                                        .withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(
                                    categoryIcon(t['category']),
                                    color: isIncome ? greenColor : redColor,
                                  ),
                                ),

                                const SizedBox(width: 13),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t['title'],
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${t['category']} • ${DateFormat('dd MMM yyyy').format(DateTime.parse(t['date']))}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Text(
                                  '${isIncome ? '+' : '-'}${money.format(t['amount'])}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: isIncome ? greenColor : redColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: items.length),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------
// SUMMARY CARD
// ------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final Color background;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 17),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            money.format(amount),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: darkColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// QUICK CATEGORY
// ------------------------------------------------------------

class _QuickCategory extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _QuickCategory({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// ADD TRANSACTION
// ------------------------------------------------------------

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  bool isIncome = false;

  String category = expenseCategories.first;

  DateTime date = DateTime.now();

  void save() {
    final amount = double.tryParse(amountCtrl.text);

    if (titleCtrl.text.trim().isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and valid amount ivvandi')),
      );
      return;
    }

    Hive.box('transactions').add({
      'title': titleCtrl.text.trim(),
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'isIncome': isIncome,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cats = isIncome ? incomeCategories : expenseCategories;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isIncome
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: primaryColor,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Track your money',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Add income or expense details',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 24),

                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.arrow_upward_rounded),
                      label: Text('Expense'),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.arrow_downward_rounded),
                      label: Text('Income'),
                    ),
                  ],
                  selected: {isIncome},
                  onSelectionChanged: (value) {
                    setState(() {
                      isIncome = value.first;

                      category = isIncome
                          ? incomeCategories.first
                          : expenseCategories.first;
                    });
                  },
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    prefixIcon: const Icon(Icons.edit_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF7F8F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    prefixIcon: const Icon(Icons.currency_rupee_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF7F8F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  key: ValueKey(isIncome),
                  initialValue: category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF7F8F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: cats
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => category = value);
                    }
                  },
                ),

                const SizedBox(height: 15),

                ListTile(
                  tileColor: const Color(0xFFF7F8F9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: const Icon(
                    Icons.calendar_month_rounded,
                    color: primaryColor,
                  ),
                  title: Text(DateFormat('dd MMM yyyy').format(date)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      setState(() => date = picked);
                    }
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: save,
                    child: const Text(
                      'Save Transaction',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// REPORTS SCREEN
// ------------------------------------------------------------

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);

  void changeMonth(int delta) {
    setState(() {
      month = DateTime(month.year, month.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = getAll().where((t) {
      final d = DateTime.parse(t['date']);

      return d.year == month.year && d.month == month.month;
    }).toList();

    double income = 0;
    double expense = 0;

    final Map<String, double> byCategory = {};

    for (final t in items) {
      if (t['isIncome'] == true) {
        income += t['amount'];
      } else {
        expense += t['amount'];

        byCategory[t['category']] =
            (byCategory[t['category']] ?? 0) + t['amount'];
      }
    }

    const colors = [
      Colors.orange,
      Colors.blue,
      Colors.red,
      Colors.purple,
      Colors.green,
      Colors.brown,
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Financial Reports',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Month selector
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => changeMonth(-1),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(month),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => changeMonth(1),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Monthly summary
          Row(
            children: [
              Expanded(
                child: _ReportCard(
                  title: 'Income',
                  amount: income,
                  color: greenColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReportCard(
                  title: 'Expense',
                  amount: expense,
                  color: redColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Pie chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expenses by Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 240,
                  child: byCategory.isEmpty
                      ? const Center(
                          child: Text(
                            'No expenses this month',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 48,
                            sections: [
                              for (var i = 0; i < byCategory.length; i++)
                                PieChartSectionData(
                                  value: byCategory.values.elementAt(i),
                                  color: colors[i % colors.length],
                                  title: byCategory.keys.elementAt(i),
                                  radius: 75,
                                  titleStyle: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Bar chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Income vs Expense',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 240,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (income > expense ? income : expense) * 1.2 + 1,
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: income,
                              color: greenColor,
                              width: 45,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: expense,
                              color: redColor,
                              width: 45,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        ),
                      ],
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: const AxisTitles(),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              return Text(
                                value == 0 ? 'Income' : 'Expense',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// REPORT CARD
// ------------------------------------------------------------

class _ReportCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _ReportCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            money.format(amount),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
