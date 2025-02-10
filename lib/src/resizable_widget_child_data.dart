import 'package:flutter/material.dart';

class ResizableWidgetChildData {
  final Widget widget;
  double? size;
  double? percentage;
  BoxConstraints? constraints;
  double? defaultPercentage;
  double? hidingPercentage;
  ResizableWidgetChildData(this.widget, this.percentage, this.constraints);
}
