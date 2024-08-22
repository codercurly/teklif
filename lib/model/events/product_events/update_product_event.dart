import 'package:equatable/equatable.dart';
import 'package:teklif/model/events/product_events/add_product_event.dart';

class UpdateProductEvent extends AddProductEvent {
  final String productId;
  final String productCode;
  final String productName;
  final int quantity;
  final double price;
  final String priceUnit;
  final List<String> currentImages; // Mevcut resimlerin URL'leri
  final List<String> newImages; // Yeni resimlerin URL'leri

  const UpdateProductEvent({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.priceUnit,
    required this.currentImages,
    required this.newImages,
  });

  @override
  List<Object> get props => [
    productId,
    productCode,
    productName,
    quantity,
    price,
    priceUnit,
    currentImages,
    newImages,
  ];
}
