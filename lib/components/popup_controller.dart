/// Контроллер для управления попапом
class PopupController {
  Function _toOpen, _toClose;
  bool _opened = false;

  set setOpen(Function f) => _toOpen = f;
  set setClose(Function f) => _toClose = f;

  /// Закрыть связанный попап
  closePopup() {
    if(_toClose != null)
      _toClose();
    _opened = false;
  }

  /// Открыть связанный попап
  openPopup() {
    if(_toOpen != null)
      _toOpen();
    _opened = true;
  }

  /// Получаем текущее состояние попапа (открыт/закрыт)
  get isOpened => _opened;
}


