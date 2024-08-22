import 'package:teklif/model/events/product_events/add_product_event.dart';

class UploadImageEvent extends AddProductEvent {
  final String imagePath;

  UploadImageEvent({required this.imagePath});
}
