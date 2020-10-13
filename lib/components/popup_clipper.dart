import 'package:flutter/material.dart';

/// Если контент попапа должен иметь стрелочку, то объект класса
/// [PopupClipper] должен быть передан в конструктор попапа
class PopupClipper {
  final Color caretColor;
  final bool isWithShadow;
  final double caretSize;
  final double caretOffset;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;

  PopupClipper({
    this.caretColor,
    this.isWithShadow = false,
    this.caretSize = 7.0,
    this.caretOffset = 9.0,
    this.borderRadius = 6.0,
    this.borderWidth = 0.0,
    this.borderColor,
  });
}

/// Положение стрелочки между всплывашкой и кнопкой
enum CaretPosition {
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
  final double caretOffset;
  final double caretSize;
  final CaretPosition caretPosition;
  final double borderRadius;
  final double strokeWidth;
  final Color strokeColor;
  final Widget child;

  PopupClipPath({
    @required this.child,
    this.caretOffset = 0,
    this.caretSize = 0,
    this.caretPosition = CaretPosition.NONE,
    this.borderRadius,
    this.strokeWidth = 0,
    this.strokeColor,
  });

  _PopupContentClipper get clipper => _PopupContentClipper(
    caretSize: caretSize,
    caretPosition: caretPosition,
    caretOffset: caretOffset,
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
  final double caretOffset;
  final double caretSize;
  final CaretPosition caretPosition;
  final double borderRadius;

  _PopupContentClipper({
    this.caretOffset,
    this.caretSize,
    this.caretPosition,
    this.borderRadius,
  });

  Path _getTopLeftCaret(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // caretSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(caretSize + borderRadius, caretSize);

    // Стрелка между всплывашкой и активатором
    path.lineTo(caretSize + borderRadius + caretOffset, caretSize);
    if (caretSize > 0) {
      path.lineTo(caretSize + borderRadius + caretOffset + caretSize, 0.0);
      path.lineTo(caretSize + borderRadius + caretOffset + caretSize * 2, caretSize);
    }

    // Линия до точки перед закруглением правого верхнего угла
    path.lineTo(size.width - caretSize - borderRadius, caretSize);
    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - caretSize, borderRadius + caretSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - caretSize, size.height - caretSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - caretSize - borderRadius, size.height - caretSize),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(caretSize + borderRadius, size.height - caretSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(caretSize, size.height - caretSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(caretSize, caretSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(caretSize + borderRadius, caretSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }


  Path _getTopRightCaret(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // caretSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(caretSize + borderRadius, caretSize);

    // Линия до стрелки
    path.lineTo(size.width - caretSize * 3 - borderRadius - caretOffset, caretSize);

    // Стрелка между всплывашкой и активатором
    if (caretSize > 0) {
      path.lineTo(size.width - caretSize * 2 - borderRadius - caretOffset, 0.0);
      path.lineTo(size.width - caretSize - borderRadius - caretOffset, caretSize);
    }
    path.lineTo(size.width - caretSize - borderRadius, caretSize);

    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - caretSize, borderRadius + caretSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - caretSize, size.height - caretSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - caretSize - borderRadius, size.height - caretSize),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(caretSize + borderRadius, size.height - caretSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(caretSize, size.height - caretSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(caretSize, caretSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(caretSize + borderRadius, caretSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }

  Path _getBottomLeftCaret(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // caretSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(caretSize + borderRadius, caretSize);

    // Линия до начала закругления правого верхнего угла
    path.lineTo(size.width - caretSize - borderRadius, caretSize);

    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - caretSize, borderRadius + caretSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - caretSize, size.height - caretSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - caretSize - borderRadius, size.height - caretSize),
        radius: Radius.circular(borderRadius));

    // Линия до начала стрелки
    path.lineTo(caretSize + borderRadius + caretOffset + caretSize * 2, size.height - caretSize);

    // Стрелка между всплывашкой и активатором
    if (caretSize > 0) {
      path.lineTo(caretSize + borderRadius + caretOffset + caretSize, size.height);
      path.lineTo(caretSize + borderRadius + caretOffset, size.height - caretSize);
    }

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(caretSize + borderRadius, size.height - caretSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(caretSize, size.height - caretSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(caretSize, caretSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(caretSize + borderRadius, caretSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }


  Path _getBottomRightCaret(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // caretSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(caretSize + borderRadius, caretSize);

    // Линия до начала закругления правого верхнего угла
    path.lineTo(size.width - caretSize - borderRadius, caretSize);

    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - caretSize, borderRadius + caretSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - caretSize, size.height - caretSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - caretSize - borderRadius, size.height - caretSize),
        radius: Radius.circular(borderRadius));

    // Линия до начала стрелки
    path.lineTo(size.width - caretSize - borderRadius - caretOffset, size.height - caretSize);

    // Стрелка между всплывашкой и активатором
    if (caretSize > 0) {
      path.lineTo(size.width - caretSize * 2 - borderRadius - caretOffset, size.height);
      path.lineTo(size.width - caretSize * 3 - borderRadius - caretOffset, size.height - caretSize);
    }

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(caretSize + borderRadius, size.height - caretSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(caretSize, size.height - caretSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(caretSize, caretSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(caretSize + borderRadius, caretSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }


  Path _getLeftTopCaret(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // caretSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(caretSize + borderRadius, caretSize);

    // Линия до начала закругления правого верхнего угла
    path.lineTo(size.width - caretSize - borderRadius, caretSize);

    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - caretSize, borderRadius + caretSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - caretSize, size.height - caretSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - caretSize - borderRadius, size.height - caretSize),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(caretSize + borderRadius, size.height - caretSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(caretSize, size.height - caretSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до начала стрелки
    path.lineTo(caretSize, caretSize * 3 + borderRadius + caretOffset);

    // Стрелка между всплывашкой и активатором
    if (caretSize > 0) {
      path.lineTo(0.0, caretSize * 2 + borderRadius + caretOffset);
      path.lineTo(caretSize, caretSize + borderRadius + caretOffset);
    }

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(caretSize, caretSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(caretSize + borderRadius, caretSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }


  Path _getLeftBottomCaret(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // caretSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(caretSize + borderRadius, caretSize);

    // Линия до начала закругления правого верхнего угла
    path.lineTo(size.width - caretSize - borderRadius, caretSize);

    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - caretSize, borderRadius + caretSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - caretSize, size.height - caretSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - caretSize - borderRadius, size.height - caretSize),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(caretSize + borderRadius, size.height - caretSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(caretSize, size.height - caretSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до начала стрелки
    path.lineTo(caretSize, size.height - caretSize - borderRadius - caretOffset);

    // Стрелка между всплывашкой и активатором
    if (caretSize > 0) {
      path.lineTo(0.0, size.height - caretSize * 2 - borderRadius - caretOffset);
      path.lineTo(caretSize, size.height - caretSize * 3 - borderRadius - caretOffset);
    }

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(caretSize, caretSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(caretSize + borderRadius, caretSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }


  Path _getRightTopCaret(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // caretSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(caretSize + borderRadius, caretSize);

    // Линия до начала закругления правого верхнего угла
    path.lineTo(size.width - caretSize - borderRadius, caretSize);

    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - caretSize, borderRadius + caretSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до начала стрелки
    path.lineTo(size.width - caretSize, caretSize + borderRadius + caretOffset);

    // Стрелка между всплывашкой и активатором
    if (caretSize > 0) {
      path.lineTo(size.width, caretSize * 2 + borderRadius + caretOffset);
      path.lineTo(size.width - caretSize, caretSize * 3 + borderRadius + caretOffset);
    }

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - caretSize, size.height - caretSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - caretSize - borderRadius, size.height - caretSize),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(caretSize + borderRadius, size.height - caretSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(caretSize, size.height - caretSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(caretSize, caretSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(caretSize + borderRadius, caretSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }


  Path _getRightBottomCaret(Size size) {
    Path path = Path();

    // Начало фигуры (сразу после закругления левого верхнего угла)
    // caretSize - это не только размер стрелки, но и число, на которое обрезается контент
    path.moveTo(caretSize + borderRadius, caretSize);

    // Линия до начала закругления правого верхнего угла
    path.lineTo(size.width - caretSize - borderRadius, caretSize);

    // Закругление правого верхнего угла
    path.arcToPoint(Offset(size.width - caretSize, borderRadius + caretSize),
        radius: Radius.circular(borderRadius)); // закругление

    // Линия до начала стрелки
    path.lineTo(size.width - caretSize, size.height - caretSize * 3 - borderRadius - caretOffset);

    // Стрелка между всплывашкой и активатором
    if (caretSize > 0) {
      path.lineTo(size.width, size.height - caretSize * 2 - borderRadius - caretOffset);
      path.lineTo(size.width - caretSize, size.height - caretSize - borderRadius - caretOffset);
    }

    // Линия до точки перед закруглением правого нижнего угла
    path.lineTo(size.width - caretSize, size.height - caretSize - borderRadius);
    // Закругление правого нижнего угла
    path.arcToPoint(
        Offset(size.width - caretSize - borderRadius, size.height - caretSize),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого нижнего угла
    path.lineTo(caretSize + borderRadius, size.height - caretSize);
    // Закругление левого нижнего угла
    path.arcToPoint(Offset(caretSize, size.height - caretSize - borderRadius),
        radius: Radius.circular(borderRadius));

    // Линия до точки перед закруглением левого верхнего угла
    path.lineTo(caretSize, caretSize + borderRadius);
    // Закругление левого верхнего угла
    path.arcToPoint(Offset(caretSize + borderRadius, caretSize),
        radius: Radius.circular(borderRadius));

    // Замыкаем контур
    path.close();

    return path;
  }


  @override
  Path getClip(Size size) {
    if (caretPosition == CaretPosition.TOP_LEFT)
      return _getTopLeftCaret(size);
    else if (caretPosition == CaretPosition.TOP_RIGHT)
      return _getTopRightCaret(size);
    else if (caretPosition == CaretPosition.BOTTOM_LEFT)
      return _getBottomLeftCaret(size);
    else if (caretPosition == CaretPosition.BOTTOM_RIGHT)
      return _getBottomRightCaret(size);
    else if (caretPosition == CaretPosition.LEFT_TOP)
      return _getLeftTopCaret(size);
    else if (caretPosition == CaretPosition.LEFT_BOTTOM)
      return _getLeftBottomCaret(size);
    else if (caretPosition == CaretPosition.RIGHT_TOP)
      return _getRightTopCaret(size);
    else if (caretPosition == CaretPosition.RIGHT_BOTTOM)
      return _getRightBottomCaret(size);
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
BoxShadow getBoxShadowClipped(double caretSize) => BoxShadow(
  color: Colors.black26,
  spreadRadius: - caretSize * 1.3, // Уменьшаем площадь тени, т.к. фигура обрезана
  blurRadius: 4.0,
  offset: Offset(
    4.0, // смещение вправо
    4.0, // смещение вниз
  ),
);