import 'package:teklif/model/events/customer_events/add_customer_event.dart';
import 'package:teklif/model/events/repair_events/add_repair_event.dart';
import 'package:teklif/states/repair_state.dart';

class DeleteRepairEvent extends RepairEvent {
  final String repairId;

  DeleteRepairEvent({required this.repairId});

  @override
  List<Object> get props => [repairId];
}