part of 'text_clipboard_bloc.dart';

@immutable
sealed class TextClipboardEvent {}

final class TextClipboardEventAddText extends TextClipboardEvent {
  TextClipboardEventAddText(this.text);
  final String text;
}

final class TextClipboardEventPaste extends TextClipboardEvent {
  TextClipboardEventPaste(this.context);
  final BuildContext context;
}

final class TextClipboardRegister extends TextClipboardEvent {
  TextClipboardRegister();
}
