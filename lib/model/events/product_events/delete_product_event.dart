import 'package:teklif/model/events/product_events/add_product_event.dart';

class DeleteProductEvent extends AddProductEvent {
  final String productId;

  DeleteProductEvent({required this.productId});

  @override
  List<Object?> get props => [productId];
}