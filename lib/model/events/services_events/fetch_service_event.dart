import 'package:teklif/model/events/services_events/add_service_event.dart';

class FetchServicesEvent extends ServiceEvent {}

class FetchOneServiceEvent extends ServiceEvent {
  final String serviceId;

  const FetchOneServiceEvent({required this.serviceId});

  @override
  List<Object> get props => [serviceId];
}