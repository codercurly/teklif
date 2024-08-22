import 'package:teklif/model/events/customer_events/add_customer_event.dart';


class FetchCustomerEvent extends CustomersEvent {

}

class FetchCustomerUpdateEvent extends CustomersEvent {
  final String customerId;

  FetchCustomerUpdateEvent({required this.customerId});
}

