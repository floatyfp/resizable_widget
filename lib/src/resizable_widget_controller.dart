import 'dart:async';
import 'package:flutter/material.dart';
import 'resizable_widget_args_info.dart';
import 'resizable_widget_child_data.dart';
import 'resizable_widget_model.dart';
import 'separator.dart';
import 'separator_args_info.dart';

class ResizableWidgetController {
  final eventStream = StreamController<Object>();
  final ResizableWidgetModel _model;
  List<ResizableWidgetChildData> get children => _model.children;

  ResizableWidgetController(ResizableWidgetArgsInfo info)
      : _model = ResizableWidgetModel(info) {
    _model.init(_separatorFactory);
  }

  void setSizeIfNeeded(BoxConstraints constraints) {
    _model.setSizeIfNeeded(constraints);
    _model.callOnResized();
  }

  void resize(BuildContext context, int separatorIndex, Offset offset) {
    _model.resize(context, separatorIndex, offset);

    eventStream.add(this);
    _model.callOnResized();
  }

  void tryHideOrShow(BuildContext context, int separatorIndex) {
    final result = _model.tryHideOrShow(context, separatorIndex);

    if (result) {
      eventStream.add(this);
      _model.callOnResized();
    }
  }

  Widget _separatorFactory(SeparatorArgsBasicInfo basicInfo) {
    return Separator(SeparatorArgsInfo(this, basicInfo));
  }
}
