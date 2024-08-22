import 'package:teklif/model/events/business_events/business_event.dart';

class FetchBusinessUpdateEvent extends BusinessEvent {
  final String userId;

  FetchBusinessUpdateEvent({required this.userId});
}
