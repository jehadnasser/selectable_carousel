import 'dart:async';
import 'package:rxdart/rxdart.dart';

class SelectableCarousalController {
  final BehaviorSubject<int> _selectionByIdStreamController =
      BehaviorSubject<int>();
  final BehaviorSubject<int> _animationStreamController =
      BehaviorSubject<int>();

  // Retrieve data from stream
  Stream<int> get selectByIdStream => _selectionByIdStreamController?.stream;

  Stream<int> get animationStream => _animationStreamController?.stream;

  // Add data to stream
  Function(int) get selectById => _selectionByIdStreamController.sink.add;

  Function(int) get withAnimation => _animationStreamController.sink.add;

  void dispose() {
    _selectionByIdStreamController.close();
    _animationStreamController.close();
  }
}
