import 'package:teklif/model/events/services_events/add_service_event.dart';

class UpdateServiceEvent extends ServiceEvent {
  final String serviceId;
  final String serviceName;
  final String serviceDescription;
  final double servicePrice;
  final String serviceDuration;
  final String unitPrice;
  final String durationType;

  const UpdateServiceEvent({
    required this.serviceId,
    required this.serviceName,
    required this.serviceDescription,
    required this.servicePrice,
    required this.serviceDuration,
    required this.unitPrice,
    required this.durationType
  });

  @override
  List<Object> get props => [serviceId, serviceName,
    serviceDescription, servicePrice, serviceDuration, unitPrice, durationType];
}
