import 'package:teklif/model/events/services_events/add_service_event.dart';

class DeleteServiceEvent extends ServiceEvent {
  final String serviceId;

  const DeleteServiceEvent({required this.serviceId});

  @override
  List<Object> get props => [serviceId];
}