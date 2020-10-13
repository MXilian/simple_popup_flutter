import 'package:flutter/material.dart';

/// Если контент попапа должен иметь стрелочку, то объект класса
/// [PopupClipper] должен быть передан в конструктор попапа
class PopupClipper {
  final Color arrowColor;
  final bool isWithShadow;
  final double arrowSize;
  final double arrowOffset;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;

  PopupClipper({
    this.arrowColor,
    this.isWithShadow = false,
    this.arrowSize = 7.0,
    this.arrowOffset = 9.0,
    this.borderRadius = 6.0,
    this.borderWidth = 0.0,
    this.borderColor,
  });
}

/// Положение стрелочки между всплывашкой и кнопкой
enum ArrowPosition {
  NONE,
  TOP_LEFT,
  TOP_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_RIGHT,
  LEFT_TOP,
  LEFT_BOTTOM,
  RIGHT_TOP,
  RIGHT_BOTTOM,
}

/// Класс, возвращающий обрезанный child с границами
class PopupClipPath extends StatelessWidget {
  final double arrowOffset;
  final double arrowSize;
  final ArrowPosition arrowPosition;
  final double borderRadius;
  final double strokeWidth;
  final Color strokeColor;
  final Widget child;

  PopupClipPath({
    @required this.child,
    this.arrowOffset = 0,
    this.arrowSize = 0,
    this.arrowPosition = ArrowPosition.NONE,
    this.borderRadius,
    this.strokeWidth = 0,
    this.strokeColor,
  });

  _PopupContentClipper get clipper => _PopupContentClipper(
    arrowSize: arrowSize,
    arrowPosition: arrowPosition,
    arrowOffset: arrowOffset,
    borderRadius: borderRadius,
  );

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PopupBorderPainter(
        clipper: clipper,
        strokeWidth: strokeWidth,
        strokeColor: strokeColor,
      ),
      child: ClipPath(
        clipper: clipper,
        child: child,
      ),
    );
  }
}

////////////////////////////////////

/// Обрезаем контейнер, чтобы придать ему форму со стрелочкой
class _PopupContentClipper extends CustomClipper<Path> {
  final double arrowOffset;
  final double arrowSize;
  final ArrowPosition arrowPosition;
  final double borderRadius;

  _PopupContentClipper({
    this.arrowOffset,
    this.arrowSize,
    this.arrowPosition,
    this.borderRadius,
  });

  Path _getTopLeftArrow(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // arrowSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(arrowSize + borderRadius, arrowSize);

    // Стрелка между всплывашкой и активатором
    path.lineTo(arrowSize + borderRadius + arrowOffset, arrowSize);
    if (arrowSize > 0) {
      path.lineTo(arrowSize + borderRadius + arrowOffset + arrowSize, 0.0);
      path.lineTo(arrowSize + borderRadius + arrowOffset + arrowSize * 2, arrowSize);
    }

    // Линия до точки перед закруглением правого верхнего угла
    path.lineTo(size.width - arrowSize - borderRadius, arrowSize);
    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - arrowSize, borderRadius + arrowSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - arrowSize, size.height - arrowSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - arrowSize - borderRadius, size.height - arrowSize),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(arrowSize + borderRadius, size.height - arrowSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(arrowSize, size.height - arrowSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(arrowSize, arrowSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(arrowSize + borderRadius, arrowSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }


  Path _getTopRightArrow(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // arrowSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(arrowSize + borderRadius, arrowSize);

    // Линия до стрелки
    path.lineTo(size.width - arrowSize * 3 - borderRadius - arrowOffset, arrowSize);

    // Стрелка между всплывашкой и активатором
    if (arrowSize > 0) {
      path.lineTo(size.width - arrowSize * 2 - borderRadius - arrowOffset, 0.0);
      path.lineTo(size.width - arrowSize - borderRadius - arrowOffset, arrowSize);
    }
    path.lineTo(size.width - arrowSize - borderRadius, arrowSize);

    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - arrowSize, borderRadius + arrowSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - arrowSize, size.height - arrowSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - arrowSize - borderRadius, size.height - arrowSize),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(arrowSize + borderRadius, size.height - arrowSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(arrowSize, size.height - arrowSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(arrowSize, arrowSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(arrowSize + borderRadius, arrowSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }

  Path _getBottomLeftArrow(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // arrowSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(arrowSize + borderRadius, arrowSize);

    // Линия до начала закругления правого верхнего угла
    path.lineTo(size.width - arrowSize - borderRadius, arrowSize);

    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - arrowSize, borderRadius + arrowSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - arrowSize, size.height - arrowSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - arrowSize - borderRadius, size.height - arrowSize),
        radius: Radius.circular(borderRadius));

    // Линия до начала стрелки
    path.lineTo(arrowSize + borderRadius + arrowOffset + arrowSize * 2, size.height - arrowSize);

    // Стрелка между всплывашкой и активатором
    if (arrowSize > 0) {
      path.lineTo(arrowSize + borderRadius + arrowOffset + arrowSize, size.height);
      path.lineTo(arrowSize + borderRadius + arrowOffset, size.height - arrowSize);
    }

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(arrowSize + borderRadius, size.height - arrowSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(arrowSize, size.height - arrowSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(arrowSize, arrowSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(arrowSize + borderRadius, arrowSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }


  Path _getBottomRightArrow(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // arrowSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(arrowSize + borderRadius, arrowSize);

    // Линия до начала закругления правого верхнего угла
    path.lineTo(size.width - arrowSize - borderRadius, arrowSize);

    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - arrowSize, borderRadius + arrowSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - arrowSize, size.height - arrowSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - arrowSize - borderRadius, size.height - arrowSize),
        radius: Radius.circular(borderRadius));

    // Линия до начала стрелки
    path.lineTo(size.width - arrowSize - borderRadius - arrowOffset, size.height - arrowSize);

    // Стрелка между всплывашкой и активатором
    if (arrowSize > 0) {
      path.lineTo(size.width - arrowSize * 2 - borderRadius - arrowOffset, size.height);
      path.lineTo(size.width - arrowSize * 3 - borderRadius - arrowOffset, size.height - arrowSize);
    }

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(arrowSize + borderRadius, size.height - arrowSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(arrowSize, size.height - arrowSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(arrowSize, arrowSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(arrowSize + borderRadius, arrowSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }


  Path _getLeftTopArrow(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // arrowSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(arrowSize + borderRadius, arrowSize);

    // Линия до начала закругления правого верхнего угла
    path.lineTo(size.width - arrowSize - borderRadius, arrowSize);

    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - arrowSize, borderRadius + arrowSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - arrowSize, size.height - arrowSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - arrowSize - borderRadius, size.height - arrowSize),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(arrowSize + borderRadius, size.height - arrowSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(arrowSize, size.height - arrowSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до начала стрелки
    path.lineTo(arrowSize, arrowSize * 3 + borderRadius + arrowOffset);

    // Стрелка между всплывашкой и активатором
    if (arrowSize > 0) {
      path.lineTo(0.0, arrowSize * 2 + borderRadius + arrowOffset);
      path.lineTo(arrowSize, arrowSize + borderRadius + arrowOffset);
    }

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(arrowSize, arrowSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(arrowSize + borderRadius, arrowSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }


  Path _getLeftBottomArrow(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // arrowSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(arrowSize + borderRadius, arrowSize);

    // Линия до начала закругления правого верхнего угла
    path.lineTo(size.width - arrowSize - borderRadius, arrowSize);

    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - arrowSize, borderRadius + arrowSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - arrowSize, size.height - arrowSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - arrowSize - borderRadius, size.height - arrowSize),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(arrowSize + borderRadius, size.height - arrowSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(arrowSize, size.height - arrowSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до начала стрелки
    path.lineTo(arrowSize, size.height - arrowSize - borderRadius - arrowOffset);

    // Стрелка между всплывашкой и активатором
    if (arrowSize > 0) {
      path.lineTo(0.0, size.height - arrowSize * 2 - borderRadius - arrowOffset);
      path.lineTo(arrowSize, size.height - arrowSize * 3 - borderRadius - arrowOffset);
    }

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(arrowSize, arrowSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(arrowSize + borderRadius, arrowSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }


  Path _getRightTopArrow(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // arrowSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(arrowSize + borderRadius, arrowSize);

    // Линия до начала закругления правого верхнего угла
    path.lineTo(size.width - arrowSize - borderRadius, arrowSize);

    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - arrowSize, borderRadius + arrowSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до начала стрелки
    path.lineTo(size.width - arrowSize, arrowSize + borderRadius + arrowOffset);

    // Стрелка между всплывашкой и активатором
    if (arrowSize > 0) {
      path.lineTo(size.width, arrowSize * 2 + borderRadius + arrowOffset);
      path.lineTo(size.width - arrowSize, arrowSize * 3 + borderRadius + arrowOffset);
    }

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - arrowSize, size.height - arrowSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - arrowSize - borderRadius, size.height - arrowSize),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(arrowSize + borderRadius, size.height - arrowSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(arrowSize, size.height - arrowSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(arrowSize, arrowSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(arrowSize + borderRadius, arrowSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }


  Path _getRightBottomArrow(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // arrowSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(arrowSize + borderRadius, arrowSize);

    // Линия до начала закругления правого верхнего угла
    path.lineTo(size.width - arrowSize - borderRadius, arrowSize);

    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - arrowSize, borderRadius + arrowSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до начала стрелки
    path.lineTo(size.width - arrowSize, size.height - arrowSize * 3 - borderRadius - arrowOffset);

    // Стрелка между всплывашкой и активатором
    if (arrowSize > 0) {
      path.lineTo(size.width, size.height - arrowSize * 2 - borderRadius - arrowOffset);
      path.lineTo(size.width - arrowSize, size.height - arrowSize - borderRadius - arrowOffset);
    }

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - arrowSize, size.height - arrowSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - arrowSize - borderRadius, size.height - arrowSize),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(arrowSize + borderRadius, size.height - arrowSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(arrowSize, size.height - arrowSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(arrowSize, arrowSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(arrowSize + borderRadius, arrowSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }


  @override
  Path getClip(Size size) {
    if (arrowPosition == ArrowPosition.TOP_LEFT)
      return _getTopLeftArrow(size);
    else if (arrowPosition == ArrowPosition.TOP_RIGHT)
      return _getTopRightArrow(size);
    else if (arrowPosition == ArrowPosition.BOTTOM_LEFT)
      return _getBottomLeftArrow(size);
    else if (arrowPosition == ArrowPosition.BOTTOM_RIGHT)
      return _getBottomRightArrow(size);
    else if (arrowPosition == ArrowPosition.LEFT_TOP)
      return _getLeftTopArrow(size);
    else if (arrowPosition == ArrowPosition.LEFT_BOTTOM)
      return _getLeftBottomArrow(size);
    else if (arrowPosition == ArrowPosition.RIGHT_TOP)
      return _getRightTopArrow(size);
    else if (arrowPosition == ArrowPosition.RIGHT_BOTTOM)
      return _getRightBottomArrow(size);
    else
      return Path();
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

///////////////////////////////////////////////////

/// Добавляем контейнеру границы
class _PopupBorderPainter extends CustomPainter {
  final _PopupContentClipper clipper;
  final double strokeWidth;
  final Color strokeColor;

  /// Добавляем контейнеру границы
  _PopupBorderPainter({
    this.clipper,
    this.strokeWidth,
    this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = this.strokeWidth
      ..color = strokeColor ?? Colors.black26;

    Path path = clipper.getClip(size);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


/// Тень для попапа с переданным параметром [PopupClipper]
BoxShadow getBoxShadowClipped(double arrowSize) => BoxShadow(
  color: Colors.black26,
  spreadRadius: - arrowSize * 1.3, // Уменьшаем площадь тени, т.к. фигура обрезана
  blurRadius: 4.0,
  offset: Offset(
    4.0, // смещение вправо
    4.0, // смещение вниз
  ),
);