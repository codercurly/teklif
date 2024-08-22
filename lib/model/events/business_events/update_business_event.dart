import 'package:teklif/model/events/business_events/business_event.dart';

class UpdateBusinessEvent extends BusinessEvent {
  final String userId;
  final String email;
  final String businessName;
  final String logo;
  final String name;
  final String phone;
  final String businessAddress;


  const UpdateBusinessEvent({
    required this.userId,
    required this.email,
    required this.businessAddress,
    required this.businessName,
    required this.logo,
    required this.name,
    required this.phone,
  });

  @override
  List<Object> get props => [
   userId,
    email,
    businessName,
    logo,
    businessAddress,
    name,
    phone
  ];
}


