import 'package:flutter/material.dart';
import 'package:teklif/pages/forbusiness/products_page.dart';
import 'package:teklif/pages/repair_page.dart';
import 'package:teklif/pages/services_page.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          child: SafeArea(
            child: TabBar(

              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.shopping_bag), text: 'Ürünler'),
                Tab(icon: Icon(Icons.miscellaneous_services), text: 'Hizmetler'),
                Tab(icon: Icon(Icons.build), text: 'Tamirler'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ProductsPage(),
          ServicesPage(),
          RepairsPage(),
        ],
      ),
    );
  }
}



