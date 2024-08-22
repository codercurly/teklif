import 'package:equatable/equatable.dart';

abstract class CustomersEvent extends Equatable {
  const CustomersEvent();

  @override
  List<Object?> get props => [];
}

class SubmitCustomerEvent extends CustomersEvent {
  final String customerNo;
  final String customerName;
  final String customerBusiness;
  final String customerMail;
  final String customerPhone;
  final String companyLogo;
  final String customerAdres;
  final String customerNote;

  SubmitCustomerEvent({
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
  List<Object?> get props => [
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

