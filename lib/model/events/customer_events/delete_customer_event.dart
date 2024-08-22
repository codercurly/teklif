import 'package:teklif/model/events/customer_events/add_customer_event.dart';

class DeleteCustomerEvent extends CustomersEvent {
  final String customerId;

  DeleteCustomerEvent({required this.customerId});

  @override
  List<Object?> get props => [customerId];
}