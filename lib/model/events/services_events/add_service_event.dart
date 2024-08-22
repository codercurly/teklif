import 'package:equatable/equatable.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object> get props => [];
}

class AddServiceEvent extends ServiceEvent {
  final String serviceName;
  final String serviceDescription;
  final double servicePrice;
  final String serviceDuration;
  final String unitPrice;
  final String durationType;

  const AddServiceEvent({
    required this.serviceName,
    required this.serviceDescription,
    required this.servicePrice,
    required this.serviceDuration,
    required this.unitPrice,
    required this.durationType
  });

  @override
  List<Object> get props => [serviceName, serviceDescription,
    servicePrice, serviceDuration, unitPrice,durationType];
}
