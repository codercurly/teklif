import 'package:teklif/model/events/customer_events/add_customer_event.dart';

class UpdateCustomerEvent extends CustomersEvent {
  final String customerId;
  final String customerNo;
  final String customerName;
  final String customerBusiness;
  final String customerMail;
  final String customerPhone;
  final String companyLogo;
  final String customerAdres;
  final String customerNote;

  const UpdateCustomerEvent({
    required this.customerId,
    required this.customerNo,
    required this.customerName,
    required this.customerBusiness,
    required this.customerMail,
    required this.customerPhone,
    required this.companyLogo,
    required this.customerAdres,
    required this.customerNote,
  });

  @override
  List<Object> get props => [
    customerId,
    customerNo,
    customerName,
    customerBusiness,
    customerMail,
    customerPhone,
    companyLogo,
    customerAdres,
    customerNote,
  ];
}
