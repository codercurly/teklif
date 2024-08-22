import 'package:flutter/material.dart';
import 'package:teklif/invoice_service.dart';
import 'package:teklif/model/product_model.dart';

class Generalform extends StatefulWidget {
  const Generalform({super.key});

  @override
  State<Generalform> createState() => _GeneralformState();
}

class _GeneralformState extends State<Generalform> {
  final PdfInvoiceService service = PdfInvoiceService();
  List<Product> products = [
    Product("Membership", 9.99, 19),
    Product("Nails", 0.30, 19),
    Product("Hammer", 26.43, 19),
    Product("Hamburger", 5.99, 7),
  ];
  int number = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice Generator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final currentProduct = products[index];
                  return Row(
                    children: [
                      Expanded(child: Text(currentProduct.name)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Price: ${currentProduct.price.toStringAsFixed(2)} €"),
                            Text("VAT ${currentProduct.vatInPercent.toStringAsFixed(0)} %")
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() => currentProduct.amount++);
                              },
                              icon: const Icon(Icons.add),
                            ),
                            Text(
                              currentProduct.amount.toString(),
                              textAlign: TextAlign.center,
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (currentProduct.amount > 0) {
                                    currentProduct.amount--;
                                  }
                                });
                              },
                              icon: const Icon(Icons.remove),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("VAT"),
                Text("${getVat()} €"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total"),
                Text("${getTotal()} €"),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                final data = await service.createInvoice(products);
                service.savePdfFile("invoice_$number", data);
                setState(() {
                  number++;
                });
              },
              child: const Text("Create Invoice"),
            ),
          ],
        ),
      ),
    );

  }
  String getTotal() {
    return products
        .fold(0.0, (double prev, element) => prev + (element.price * element.amount))
        .toStringAsFixed(2);
  }

  String getVat() {
    return products
        .fold(0.0, (double prev, element) => prev + (element.price / 100 * element.vatInPercent * element.amount))
        .toStringAsFixed(2);
  }
}
