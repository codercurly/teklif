import 'package:equatable/equatable.dart';

abstract class AddProductEvent extends Equatable {
  const AddProductEvent();

  @override
  List<Object?> get props => [];
}

class SubmitProductEvent extends AddProductEvent {
  final String productCode;
  final String productName;
  final int quantity;
  final double price;
  final String priceUnit;
  final List<String> images;

  SubmitProductEvent({
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.priceUnit,
    required this.images,
  });

  @override
  List<Object?> get props => [productCode, productName, quantity, price, priceUnit, images];
}
