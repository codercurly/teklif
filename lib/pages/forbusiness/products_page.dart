import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teklif/base/colors.dart';
import 'package:teklif/base/dimension.dart';
import 'package:teklif/base/failed_snackbar.dart';
import 'package:teklif/base/success_snackbar.dart';
import 'package:teklif/bloc/product_bloc.dart';
import 'package:teklif/components/app_table.dart';
import 'package:teklif/components/custom_text.dart';
import 'package:teklif/components/label_container.dart';
import 'package:teklif/components/mysuccess_buton.dart';
import 'package:teklif/components/navbar_items.dart';
import 'package:teklif/model/events/product_events/delete_product_event.dart';
import 'package:teklif/model/events/product_events/fetch_product_event.dart';
import 'package:teklif/pages/auth/login_page.dart';
import 'package:teklif/pages/forbusiness/addPages/add_product_page.dart';
import 'package:teklif/pages/forbusiness/addPages/add_repair_page.dart';
import 'package:teklif/pages/forbusiness/updatePages/update_product_page.dart';
import 'package:teklif/states/product_state.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late ProductBloc _productBloc;

  @override
  void initState() {
    super.initState();
    _productBloc = BlocProvider.of<ProductBloc>(context);
    _fetchProductData();
  }

  void _fetchProductData() {
    _productBloc.add(FetchProductEvent());
  }

  void _deleteProduct(String productId) {
    _productBloc.add(DeleteProductEvent(productId: productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is AddProductFailure) {
            MyFailureSnackbar.show(context, state.error);
          } else if (state is DeleteProductSuccess) {
            MySuccessSnackbar.show(context, state.message);
          } else if (state is ProductAuthFailure && state.authError) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          }
        },
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is FetchProductSuccess) {
              List<Map<String, dynamic>> products = state.productData;

              return Column(
                children: [
                  NavBarItems(
                    label: "Ürünler",
                    buttonText: "Ürün ekle",
                    onButtonTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRepairPage(),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CustomDataTable(
                            labels: [
                              'Ürün Kodu',
                              'Ad',
                              'Miktar',
                              'Fiyat',
                              'Resimler',
                              'İşlemler'
                            ],
                            rows: products.map((product) {
                              String price = '${product['price']} ${product['priceUnit']}';
                              price = price.replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
                              return {
                                'Ürün Kodu': product['productCode'],
                                'Ad': product['productName'],
                                'Miktar': product['quantity'],
                                'Fiyat': price,
                                'images':  product['images'] != null && product['images'].isNotEmpty
                                    ? List<String>.from(product['images'])
                                    : ['assets/default.png'], // Resimler buraya eklendi


                              };
                            }).toList(),
                            onEditPressed: (index) {
                              if(products[index]['id'] != null) {
                                String productId = products[index]['id'];
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) =>
                                        UpdateProductPage(productId: productId)));
                              }
                            },
                            onDeletePressed: (index) {
                              if(products[index]['id'] != null){
                                String productId = products[index]['id'];
                                _deleteProduct(productId);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is FetchProductLoading) {
              return Center(child: CircularProgressIndicator());
            } else {
            return  NavBarItems(
                label: "Ürünler",
                buttonText: "Ürün ekle",
                onButtonTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddRepairPage(),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
