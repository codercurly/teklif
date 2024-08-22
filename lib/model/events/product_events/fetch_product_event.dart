import 'package:teklif/model/events/product_events/add_product_event.dart';

class FetchProductEvent extends AddProductEvent {

}
class FetchOneProductEvent extends AddProductEvent {
  final String productId;

  FetchOneProductEvent({required this.productId});
}