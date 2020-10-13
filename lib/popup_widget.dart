import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:simple_popup_flutter/components/popup_clipper.dart';
import 'package:simple_popup_flutter/components/popup_controller.dart';
import 'package:simple_popup_flutter/components/popup_position.dart';

class PopupWidget extends StatefulWidget {

  final PopupController controller;

  /// Если true, то контент позади попапа будет затемняться
  final bool withBlackout;

  /// Содержимое попапа
  final Widget popupContent;

  /// Если у попапа должна быть стрелочка по направлению к активатору, тогда
  /// следует передать этот параметр.
  final PopupClipper popupClipper;

  /// Виджет-активатор, при клике по которому будет появляться попап.
  final Widget child;

  /// Callback, срабатываемый при переключении видимости попапа
  final Function(bool visible) onVisibilityChanged;

  /// Положение [popupContent] относительно [child].
  ///
  /// По умолчанию положение определяется автоматически,
  /// исходя из свободного места на экране.
  ///
  /// При желании можно задать положение вручную,
  /// передав нужное значение [PopupPosition].
  final PopupPosition position;

  /// Смещение попапа по осям X и Y
  final Offset contentOffset;

  /// Коэффициент (от 0.0 до 1.0, по умолчанию - 1.0), применяемый к максимально
  /// возможной ширине и высоте попапа
  ///
  /// (по умолчанию, если не задавать попапу
  /// четких размеров, он может распространяться до краев экрана; если же
  /// дополнительно указать этот коэффициент, то можно ограничить пределы
  /// попапа; например, указав 0.9, мы позволим ему занять не более 90%
  /// площади между границами экрана).
  final double expansionFactor;

  /// Если поставить true, попап будет закрываться при клике по нему
  /// (по умолчанию он закрывается только при клике мимо него)
  final bool closesOnClick;

  PopupWidget({
    Key key,
    this.controller,
    @required this.child,
    @required this.popupContent,
    this.popupClipper,
    this.withBlackout = false,
    this.position = PopupPosition.AUTO,
    this.contentOffset,
    this.expansionFactor = 1.0,
    this.closesOnClick = false,
    this.onVisibilityChanged,
  }) : super(key: key);

  @override
  _PopupWidgetState createState() => _PopupWidgetState();
}

class _PopupWidgetState extends State<PopupWidget> {
  final GlobalKey _key = GlobalKey();

  OverlayEntry _overlay;
  bool _opened = false;
  PopupController _controller;
  Offset _offset;
  ArrowPosition _arrowPosition = ArrowPosition.NONE;

  double _top = 0;
  double _bottom = 0;
  double _right = 0;
  double _left = 0;
  double _maxHeight = 0;
  double _maxWidth = 0;

  @override
  void initState() {
    super.initState();
    _offset = widget.contentOffset ?? Offset(0.0, 0.0);
    _controller = widget.controller ?? PopupController();
    _controller.setOpen = _openPopup;
    _controller.setClose = _closePopup;
  }

  @override
  void dispose() {
    if (_opened) _overlay?.remove();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      child: widget.child,
      onTap: _opened ? _controller.closePopup : _controller.openPopup,
    );
  }


  void _closePopup() {
    _overlay?.remove();
    _overlay = null;

    if (widget.onVisibilityChanged != null)
      widget.onVisibilityChanged(false);

    setState(() {
      _opened = false;
    });
  }


  void _openPopup() {

    if (widget.onVisibilityChanged != null)
      widget.onVisibilityChanged(true);

    updatePosition();

    _overlay = OverlayEntry(
        builder: (context) {

          return Container(
            // padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top), // Сюда можно подставить высоту аппбара, если она кастомная
            child: Stack(
              children: <Widget>[
                //
                // Ловим тапы, чтобы спрятать попап.
                GestureDetector(
                  onTap: _controller.closePopup,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: widget.withBlackout ? Colors.black26.withOpacity(0.66) : Colors.transparent,
                    child: Container(),
                  ),
                ),
                //
                // Сама всплывашка
                widget.position == PopupPosition.CENTER_OF_SCREEN
                    ? Container(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: GestureDetector(
                        child: Material(child: widget.popupContent,),
                        onTap: widget.closesOnClick ? () {_controller.closePopup(); } : null,
                      ),
                    )
                )
                    : Positioned(
                  child: GestureDetector(
                    child: widget.popupClipper == null || _arrowPosition == ArrowPosition.NONE
                        ? Container(
                      constraints: BoxConstraints(
                        maxHeight: _maxHeight,
                        maxWidth: _maxWidth,
                      ),
                      child: SingleChildScrollView(
                        child: Material(child: widget.popupContent),
                      ),
                    )
                        : Container(
                      decoration: widget.popupClipper.isWithShadow
                          ? BoxDecoration(
                        boxShadow: [getBoxShadowClipped(widget.popupClipper.arrowSize)],
                      )
                          : null,
                      child: PopupClipPath(
                        arrowSize: widget.popupClipper.arrowSize, //widget.arrowSize
                        arrowPosition: _arrowPosition,
                        arrowOffset: widget.popupClipper.arrowOffset,
                        borderRadius: widget.popupClipper.borderRadius,
                        strokeWidth: widget.popupClipper?.borderWidth ?? 0.0,
                        strokeColor: widget.popupClipper?.borderColor ?? Colors.black26,
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: _maxHeight,
                            maxWidth: _maxWidth,
                          ),
                          child: SingleChildScrollView(
                            child: Material(
                                color: widget.popupClipper.arrowColor ?? Colors.grey,
                                child: Padding(
                                  padding: EdgeInsets.all(widget.popupClipper.arrowSize),
                                  child: widget.popupContent,
                                )
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: widget.closesOnClick ? () {_controller.closePopup(); } : null,
                  ),
                  // width: constraints.maxWidth,
                  // height: constraints.maxHeight,
                  top: _top,
                  bottom: _bottom,
                  left: _left,
                  right: _right,
                ),
              ],
            ),

          );
        }
    );

    setState(() {
      _opened = true;
      Overlay.of(context).insert(_overlay);
    });
  }


  void updatePosition() {
    RenderBox box = _key.currentContext.findRenderObject();
    Size activatorSize = box.size;
    Offset activatorOffset = box.localToGlobal(Offset.zero);
    final double _screenWidth = MediaQuery.of(context).size.width;
    final double _screenHeight = MediaQuery.of(context).size.height;

    double top;
    double bottom;
    double left;
    double right;
    double maxHeight;
    double maxWidth;
    ArrowPosition arrowPosition;

    var _position = widget.position;
    
    double bottomBarHeight = MediaQuery.of(context).padding.bottom; // Сюда можно подставить высоту bottomNavigationBar, если он есть
    double appBarHeight = MediaQuery.of(context).padding.top; // Сюда можно подставить высоту appBar, если он кастомный

    // Выбираем подходящую позицию, если выбран режим AUTO
    if (_position == PopupPosition.AUTO) {
      bool isAbove = false;
      bool isLeft = false;
      if (activatorOffset.dy >=
          _screenHeight - activatorOffset.dy - activatorSize.height)
        isAbove = true;
      else
        isAbove = false;
      if (activatorOffset.dx + activatorSize.width >
          _screenWidth - activatorOffset.dx)
        isLeft = true;
      else
        isLeft = false;

      if (isAbove && isLeft)
        _position = PopupPosition.ABOVE_from_topRight_corner;
      else if (isAbove && !isLeft)
        _position = PopupPosition.ABOVE_from_topLeft_corner;
      else if (!isAbove && isLeft)
        _position = PopupPosition.UNDER_from_bottomRight_corner;
      else if (!isAbove && !isLeft)
        _position = PopupPosition.UNDER_from_bottomLeft_corner;
    }

    // Дополнительный отступ, устраняющий лишние пробелы, возникающие из-за клиппера
    double indent = widget.popupClipper?.arrowSize ?? 0;

    // Вычисляем положение всплывашки исходя из выбранной позиции
    //
    // Если распространяется вниз, то берем отступ сверху (иначе - снизу)
    // Если распространяется налево, то берем отступ справа (иначе - слева)
    switch (_position) {
    // Начиная от левого верхнего угла, распространяется вверх и направо
      case PopupPosition.ABOVE_from_topLeft_corner:
        top = null;
        bottom = _screenHeight - activatorOffset.dy - bottomBarHeight
            + _offset.dy + indent;
        left = activatorOffset.dx + _offset.dx - indent;
        right = null;
        maxHeight = activatorOffset.dy - appBarHeight * 2;
        maxWidth = _screenWidth - activatorOffset.dx;
        arrowPosition = ArrowPosition.BOTTOM_LEFT;
        break;
    // Начиная от правого верхнего угла, распространяется вверх и налево
      case PopupPosition.ABOVE_from_topRight_corner:
        top = null;
        bottom = _screenHeight - activatorOffset.dy - bottomBarHeight
            + _offset.dy + indent;
        left = null;
        right = _screenWidth - activatorOffset.dx - activatorSize.width + _offset.dx - indent;
        maxHeight = activatorOffset.dy - appBarHeight * 2;
        maxWidth = activatorOffset.dx + activatorSize.width;
        arrowPosition = ArrowPosition.BOTTOM_RIGHT;
        break;
    // Начиная от нижнего левого угла, распространяется вниз и направо
      case PopupPosition.UNDER_from_bottomLeft_corner:
        top = activatorOffset.dy + activatorSize.height + _offset.dy - appBarHeight + indent;
        bottom = null;
        left = activatorOffset.dx + _offset.dx - indent;
        right = null;
        maxHeight = _screenHeight - activatorOffset.dy - activatorSize.height - bottomBarHeight;
        maxWidth = _screenWidth - activatorOffset.dx;
        arrowPosition = ArrowPosition.TOP_LEFT;
        break;
    // Начиная от нижнего правого угла, распространяется вниз и налево
      case PopupPosition.UNDER_from_bottomRight_corner:
        top = activatorOffset.dy + activatorSize.height + _offset.dy - appBarHeight + indent;
        bottom = null;
        left = null;
        right = _screenWidth - activatorOffset.dx - activatorSize.width + _offset.dx - indent;
        maxHeight = _screenHeight - activatorOffset.dy - activatorSize.height - bottomBarHeight;
        maxWidth = activatorOffset.dx + activatorSize.width;
        arrowPosition = ArrowPosition.TOP_RIGHT;
        break;
    // Начиная от верхнего левого угла, распространяется налево и вниз
      case PopupPosition.LEFT_from_topLeft_corner:
        top = activatorOffset.dy + _offset.dy - appBarHeight - indent;
        bottom = null;
        right = _screenWidth - activatorOffset.dx + _offset.dx + indent;
        left = null;
        maxHeight = _screenHeight - activatorOffset.dy - bottomBarHeight;
        maxWidth = activatorOffset.dx;
        arrowPosition = ArrowPosition.RIGHT_TOP;
        break;
    // Начиная от нижнего левого угла, распространяется налево и вверх
      case PopupPosition.LEFT_from_bottomLeft_corner:
        top = null;
        bottom = _screenHeight - activatorOffset.dy - activatorSize.height + _offset.dy - bottomBarHeight - indent;
        right = _screenWidth - activatorOffset.dx + _offset.dx + indent;
        maxHeight = activatorOffset.dy + activatorSize.height - appBarHeight * 2;
        maxWidth = activatorOffset.dx;
        arrowPosition = ArrowPosition.RIGHT_BOTTOM;
        left = null;
        break;
    // Начиная от верхнего правого угла, распространяется направо и вниз
      case PopupPosition.RIGHT_from_topRight_corner:
        top = activatorOffset.dy + _offset.dy - appBarHeight - indent;
        bottom = null;
        right = null;
        left = activatorOffset.dx + activatorSize.width + _offset.dx + indent;
        maxHeight = _screenHeight - activatorOffset.dy - bottomBarHeight;
        maxWidth = _screenWidth - activatorOffset.dx - activatorSize.width;
        arrowPosition = ArrowPosition.LEFT_TOP;
        break;
    // Начиная от нижнего правого угла, распространяется направо и вверх
      case PopupPosition.RIGHT_from_bottomRight_corner:
        top = null;
        bottom = _screenHeight - activatorOffset.dy - activatorSize.height + _offset.dy - bottomBarHeight - indent;
        right = null;
        left = activatorOffset.dx + activatorSize.width + _offset.dx + indent;
        maxHeight = activatorOffset.dy + activatorSize.height - appBarHeight * 2;
        maxWidth = _screenWidth - activatorOffset.dx - activatorSize.width;
        arrowPosition = ArrowPosition.LEFT_BOTTOM;
        break;
    // Начиная от левой стороны экрана и верхней стороны активатора, распространяется направо и вверх
      case PopupPosition.ABOVE_from_left_side_of_screen:
        top = null;
        bottom = _screenHeight - activatorOffset.dy + _offset.dy - bottomBarHeight;
        left = _offset.dx;
        right = null;
        maxHeight = activatorOffset.dy - appBarHeight * 2;
        maxWidth = _screenWidth;
        arrowPosition = ArrowPosition.NONE;
        break;
    // Начиная от правой стороны экрана и верхней стороны активатора, распространяется налево и вверх
      case PopupPosition.ABOVE_from_right_side_of_screen:
        top = null;
        bottom = _screenHeight - activatorOffset.dy + _offset.dy - bottomBarHeight;
        left = null;
        right = _offset.dx;
        maxHeight = activatorOffset.dy - appBarHeight * 2;
        maxWidth = _screenWidth;
        arrowPosition = ArrowPosition.NONE;
        break;
    // Начиная от левой стороны экрана и нижней стороны активатора, распространяется направо и вниз
      case PopupPosition.UNDER_from_left_side_of_screen:
        top = activatorOffset.dy + activatorSize.height + _offset.dy - appBarHeight ;
        bottom = null;
        left = _offset.dx;
        right = null;
        maxHeight = _screenHeight - activatorOffset.dy - activatorSize.height - bottomBarHeight;
        maxWidth = _screenWidth;
        arrowPosition = ArrowPosition.NONE;
        break;
    // Начиная от правой стороны экрана и нижней стороны активатора, распространяется налево и вниз
      case PopupPosition.UNDER_from_right_side_of_screen:
        top = activatorOffset.dy + activatorSize.height + _offset.dy - appBarHeight ;
        bottom = null;
        left = null;
        right = _offset.dx;
        maxHeight = _screenHeight - activatorOffset.dy - activatorSize.height - bottomBarHeight;
        maxWidth = _screenWidth;
        arrowPosition = ArrowPosition.NONE;
        break;
    // Начиная от центра экрана, распространяется равномерно во все стороны
      case PopupPosition.CENTER_OF_SCREEN:
      default:
        top = 0;
        bottom = 0;
        right = 0;
        left = 0;
        maxHeight = _screenHeight - appBarHeight * 2 - bottomBarHeight;
        maxWidth = _screenWidth;
        arrowPosition = ArrowPosition.NONE;
        break;
    }

    setState(() {
      _top = top;
      _bottom = bottom;
      _left = left;
      _right = right;
      _maxHeight = maxHeight * widget.expansionFactor;
      _maxWidth = maxWidth * widget.expansionFactor;
      _arrowPosition = arrowPosition;
    });
  }
}