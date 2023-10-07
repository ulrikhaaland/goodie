import 'package:flutter/foundation.dart';

class BottomNavigationProvider with ChangeNotifier {
  ChangeNotifier onTapCurrentTabListener = ChangeNotifier();

  final ValueNotifier<int> _currentIndex = ValueNotifier(0);

  ValueListenable<int> get currentIndexListener => _currentIndex;

  set index(int newIndex) {
    if (newIndex == _currentIndex.value) {
      onTapCurrentTabListener.notifyListeners();
    } else {
      _currentIndex.value = newIndex;
    }
  }
}
