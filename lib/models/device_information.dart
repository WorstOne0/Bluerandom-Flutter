// Map with id, name, rssiNew, rssiOld
class DeviceInformation {
  late String id;
  late String name;
  late int rssiNew;
  int? rssiOld;

  DeviceInformation(this.id, this.name, this.rssiNew, this.rssiOld);
}
