import 'package:equatable/equatable.dart';
import 'package:teklif/model/events/repair_events/add_repair_event.dart';


class UpdateRepairEvent extends RepairEvent {
  final String repairId;
  final String repairName;
  final String repairDescription;
  final String repairDuration;
  final double repairPrice;
  final String repairDate;
  final String deviceName;
  final String deviceModel;
  final String serialNumber;
  final String problemDescription;
  final bool warrantyStatus;
  final String repairCurrency;
  final String repairStatus;

  const UpdateRepairEvent({
    required this.repairId,
    required this.repairName,
    required this.repairDescription,
    required this.repairDuration,
    required this.repairPrice,
    required this.repairDate,
    required this.deviceName,
    required this.deviceModel,
    required this.serialNumber,
    required this.problemDescription,
    required this.warrantyStatus,
    required this.repairCurrency,
    required this.repairStatus,
  });

  @override
  List<Object> get props => [
    repairId,
    repairName,
    repairDescription,
    repairDuration,
    repairPrice,
    repairDate,
    deviceName,
    deviceModel,
    serialNumber,
    problemDescription,
    warrantyStatus,
    repairCurrency,
    repairStatus,

  ];
}
