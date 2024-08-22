import 'package:flutter/material.dart';
import 'package:teklif/base/colors.dart';
import 'package:teklif/pages/forbusiness/business.dart';
import 'package:teklif/pages/forbusiness/customers_page.dart';
import 'package:teklif/pages/forbusiness/offer_page.dart';
import 'package:teklif/pages/forbusiness/products_page.dart';
import 'package:teklif/pages/forbusiness/workers.dart';
import 'package:teklif/pages/transactions_page.dart';

class ManagerPage extends StatefulWidget {
  const ManagerPage({Key? key}) : super(key: key);

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 150.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.orangetree,
                  AppColors.orangetwo,
                  AppColors.orangeone
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                      icon: Icon(Icons.shopping_bag_outlined,
                          color: Colors.white),
                      text: 'İşlemler'),
                  Tab(
                      icon: Icon(Icons.people, color: Colors.white),
                      text: 'Müşteriler'),
                  Tab(
                      icon: Icon(Icons.add_box_rounded,
                          color: Colors.white),
                      text: 'Teklif'),
                  Tab(
                      icon: Icon(Icons.people_rounded,
                          color: Colors.white),
                      text: 'Görevliler'),
                  Tab(
                      icon: Icon(Icons.account_circle,
                          color: Colors.white),
                      text: 'Hesap'),
                ],
                indicatorColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TransactionsPage(),
                CustomersPage(),
                KanbanPage(),
                WorkersPage(),
                CompanyProfilePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
