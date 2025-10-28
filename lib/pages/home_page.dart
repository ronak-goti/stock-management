import 'package:flutter/material.dart';
import '../deshboard_page/bill_add-remove.dart';
import '../deshboard_page/bill_details.dart';
import '../deshboard_page/customer_add-remove.dart';
import '../deshboard_page/customer_details.dart';
import '../deshboard_page/stock_Add_Remove.dart';
import '../deshboard_page/stock_details.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          const SizedBox(height: 10),
          _buildRow(
            context,
            leftIcon: Icons.account_balance_wallet,
            leftTitle: "Stock\nAdd-Remove",
            leftScreen: const StockAddRemoveScreen(),
            rightIcon: Icons.add_chart_outlined,
            rightTitle: "Stock\nDetails",
            rightScreen: const StockDetailsScreen(),
          ),
          _buildRow(
            context,
            leftIcon: Icons.dashboard_customize,
            leftTitle: "Customer\nAdd-Remove",
            leftScreen: CustomerAddRemoveScreen(),
            rightIcon: Icons.person,
            rightTitle: "Customer\nDetails",
            rightScreen: CustomerDetailsScreen(),
          ),
          _buildRow(
            context,
            leftIcon: Icons.border_inner_outlined,
            leftTitle: "Bill\nAdd-Remove",
            leftScreen:  BillAddRemoveScreen(),
            rightIcon: Icons.add_card_rounded,
            rightTitle: "Bill\nDetails",
            rightScreen:  BillDetailsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
      BuildContext context, {
        required IconData leftIcon,
        required String leftTitle,
        required Widget leftScreen,
        required IconData rightIcon,
        required String rightTitle,
        required Widget rightScreen,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 15),
          _buildTile(context, leftIcon, leftTitle, leftScreen),
          _buildTile(context, rightIcon, rightTitle, rightScreen),
          const SizedBox(width: 15),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        height: 160,
        width: 160,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.lightBlue, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              spreadRadius: 2,
              offset: Offset(5, 5),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 55, color: Colors.black),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
