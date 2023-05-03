class OutputInformation {
  List<int> _actualByte = [];
  List<int> lastByte = [];

  OutputInformation(this._actualByte, this.lastByte);

  void addBit(int bit) {
    _actualByte.add(bit);
  }

  void copyLastByte(List<int> oldLastByte) {
    lastByte = [...oldLastByte];
  }
}
