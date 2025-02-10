import 'package:flutter/material.dart';
import 'resizable_widget_controller.dart';

class SeparatorController {
  final int _index;
  final ResizableWidgetController _parentController;

  const SeparatorController(this._index, this._parentController);

  void onPanUpdate(BuildContext context, DragUpdateDetails details) {
    _parentController.resize(context, _index, details.delta);
  }

  void onDoubleTap(BuildContext context) {
    _parentController.tryHideOrShow(context, _index);
  }
}
