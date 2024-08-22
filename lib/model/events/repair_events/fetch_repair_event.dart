import 'package:teklif/model/events/repair_events/add_repair_event.dart';

class FetchRepairsEvent extends RepairEvent {}


class FetchOneRepairEvent extends RepairEvent {
  final String repairId;

  FetchOneRepairEvent({required this.repairId});
}
