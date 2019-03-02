class StatusBarState {
  static StatusBarState _singleton =StatusBarState.initial();
  double _height = 0;

  factory StatusBarState() {
    return _singleton;
  }

  StatusBarState.initial();

  double get height => _height;

  void setHeight(double height) {
    this._height = height;
  }
}