import 'package:flutter/material.dart';
import 'resizable_widget_args_info.dart';
import 'resizable_widget_child_data.dart';
import 'separator.dart';
import 'separator_args_info.dart';
import 'widget_size_info.dart';

typedef SeparatorFactory = Widget Function(SeparatorArgsBasicInfo basicInfo);

class ResizableWidgetModel {
  final ResizableWidgetArgsInfo _info;
  final children = <ResizableWidgetChildData>[];
  double? maxSize;

  double? get maxSizeWithoutSeparators => maxSize == null ? null : maxSize! - (children.length ~/ 2) * _info.separatorSize;

  ResizableWidgetModel(this._info);

  void init(SeparatorFactory separatorFactory) {
    final originalChildren = _info.children;
    final size = originalChildren.length;
    final originalPercentages = _info.percentages ?? List.filled(size, 1 / size);
    final originalConstraints = _info.constraints;
    for (var index = 0; index < size - 1; index++) {
      children.add(
        ResizableWidgetChildData(
          originalChildren[index],
          originalPercentages[index],
          originalConstraints?.elementAt(index),
        ),
      );
      final separatorWidget = separatorFactory.call(
        SeparatorArgsBasicInfo(
          2 * index + 1,
          _info.isHorizontalSeparator,
          _info.isDisabledSmartHide,
          _info.separatorSize,
          _info.separatorColor,
        ),
      );
      children.add(
        ResizableWidgetChildData(separatorWidget, null, null),
      );
    }

    // Last widget
    children.add(
      ResizableWidgetChildData(
        originalChildren[size - 1],
        originalPercentages[size - 1],
        originalConstraints?.elementAt(size - 1),
      ),
    );
  }

  void setSizeIfNeeded(BoxConstraints constraints) {
    final max = _info.isHorizontalSeparator ? constraints.maxHeight : constraints.maxWidth;
    if (maxSize != null && maxSize == max) return;

    maxSize = max;
    final remain = maxSizeWithoutSeparators!;

    for (var index = 0; index < children.length; index++) {
      if (children[index].widget is Separator) {
        children[index].percentage = 0;
        children[index].size = _info.separatorSize;
      } else {
        children[index].size = remain * children[index].percentage!;
        children[index].defaultPercentage = children[index].percentage;
      }
    }

    for (var index = 1; index < children.length - 1; index += 2) {
      final originalSize = (children[index - 1].size ?? 0) + (children[index + 1].size ?? 0);
      _updateSizes(index - 1, index + 1, 0, originalSize);
    }
  }

  void resize(BuildContext context, int separatorIndex, Offset offset) {
    if (!_info.isHorizontalSeparator && Directionality.of(context) == TextDirection.rtl) {
      offset = offset * -1;
    }

    var delta = _info.isHorizontalSeparator ? offset.dy : offset.dx;
    final originalSize = (children[separatorIndex - 1].size ?? 0) + (children[separatorIndex + 1].size ?? 0);

    _updateSizes(separatorIndex - 1, separatorIndex + 1, delta, originalSize);
  }

  void _updateSizes(int index1, int index2, double delta, double originalSize) {
    final childData1 = children[index1];
    final childData2 = children[index2];
    final constraints1 = childData1.constraints ?? const BoxConstraints();
    final constraints2 = childData2.constraints ?? const BoxConstraints();

    var size1 = (childData1.size ?? 0) + delta;
    var size2 = (childData2.size ?? 0) - delta;

    // Check which panel has constraints
    final hasConstraints1 = constraints1 != const BoxConstraints();
    final hasConstraints2 = constraints2 != const BoxConstraints();

    if (_info.isHorizontalSeparator) {
      // Handle vertical resizing
      if (hasConstraints1 && !hasConstraints2) {
        // Panel 1 has constraints, Panel 2 doesn't - prioritize Panel 1's constraints
        if (size1 < constraints1.minHeight) size1 = constraints1.minHeight;
        if (size1 > constraints1.maxHeight) size1 = constraints1.maxHeight;
        size2 = originalSize - size1;
      } else if (!hasConstraints1 && hasConstraints2) {
        // Panel 2 has constraints, Panel 1 doesn't - prioritize Panel 2's constraints
        if (size2 < constraints2.minHeight) size2 = constraints2.minHeight;
        if (size2 > constraints2.maxHeight) size2 = constraints2.maxHeight;
        size1 = originalSize - size2;
      } else if (hasConstraints1 && hasConstraints2) {
        // Both panels have constraints - try to satisfy both
        if (delta < 0) {
          while (size1 < constraints1.minHeight || size2 > constraints2.maxHeight) {
            if (size1 < constraints1.minHeight) {
              size1 = constraints1.minHeight;
              size2 = originalSize - size1;
            }
            if (size2 > constraints2.maxHeight) {
              size2 = constraints2.maxHeight;
              size1 = originalSize - size2;
            }
          }
        } else {
          while (size1 > constraints1.maxHeight || size2 < constraints2.minHeight) {
            if (size1 > constraints1.maxHeight) {
              size1 = constraints1.maxHeight;
              size2 = originalSize - size1;
            }
            if (size2 < constraints2.minHeight) {
              size2 = constraints2.minHeight;
              size1 = originalSize - size2;
            }
          }
        }
      }
    } else {
      // Handle horizontal resizing
      if (hasConstraints1 && !hasConstraints2) {
        // Panel 1 has constraints, Panel 2 doesn't - prioritize Panel 1's constraints
        if (size1 < constraints1.minWidth) size1 = constraints1.minWidth;
        if (size1 > constraints1.maxWidth) size1 = constraints1.maxWidth;
        size2 = originalSize - size1;
      } else if (!hasConstraints1 && hasConstraints2) {
        // Panel 2 has constraints, Panel 1 doesn't - prioritize Panel 2's constraints
        if (size2 < constraints2.minWidth) size2 = constraints2.minWidth;
        if (size2 > constraints2.maxWidth) size2 = constraints2.maxWidth;
        size1 = originalSize - size2;
      } else if (hasConstraints1 && hasConstraints2) {
        // Both panels have constraints - try to satisfy both
        if (delta < 0) {
          while (size1 < constraints1.minWidth || size2 > constraints2.maxWidth) {
            if (size1 < constraints1.minWidth) {
              size1 = constraints1.minWidth;
              size2 = originalSize - size1;
            }
            if (size2 > constraints2.maxWidth) {
              size2 = constraints2.maxWidth;
              size1 = originalSize - size2;
            }
          }
        } else {
          while (size1 > constraints1.maxWidth || size2 < constraints2.minWidth) {
            if (size1 > constraints1.maxWidth) {
              size1 = constraints1.maxWidth;
              size2 = originalSize - size2;
            }
            if (size2 < constraints2.minWidth) {
              size2 = constraints2.minWidth;
              size1 = originalSize - size2;
            }
          }
        }
      }
    }

    _resizeImpl(childData1, size1);
    _resizeImpl(childData2, size2);
  }

  void callOnResized() {
    _info.onResized?.call(
      children
          .where((widgetData) => widgetData.widget is! Separator)
          .map((widgetData) => WidgetSizeInfo(widgetData.size!, widgetData.percentage!, widgetData.constraints))
          .toList(),
    );
  }

  bool tryHideOrShow(BuildContext context, int separatorIndex) {
    if (_info.isDisabledSmartHide) {
      return false;
    }

    final isLeft = separatorIndex == 1;
    final isRight = separatorIndex == children.length - 2;
    if (!isLeft && !isRight) {
      // valid only for both ends.
      return false;
    }

    final target = children[isLeft ? 0 : children.length - 1];
    final size = target.size!;
    final coefficient = isLeft ? 1 : -1;
    if (_isNearlyZero(size)) {
      // show
      final offsetScala = maxSize! * (target.hidingPercentage ?? target.defaultPercentage!) - size;
      final offset = _info.isHorizontalSeparator ? Offset(0, offsetScala * coefficient) : Offset(offsetScala * coefficient, 0);
      resize(context, separatorIndex, offset);
    } else {
      // hide
      target.hidingPercentage = target.percentage!;
      final offsetScala = maxSize! * target.hidingPercentage!;
      final offset = _info.isHorizontalSeparator ? Offset(0, -offsetScala * coefficient) : Offset(-offsetScala * coefficient, 0);
      resize(context, separatorIndex, offset);
    }

    return true;
  }

  double _resizeImpl(ResizableWidgetChildData childData, double newSize) {
    childData.size = newSize;
    childData.percentage = childData.size! / maxSizeWithoutSeparators!;
    return childData.size!;
  }

  bool _isNearlyZero(double size) {
    return size < 2;
  }
}
