part of 'text_clipboard_bloc.dart';

enum TextClipboardStatus { initial, loading, success, failure }

extension TextClipboardStatusX on TextClipboardStatus {
  bool get isLoadingOrSuccess => [
        TextClipboardStatus.loading,
        TextClipboardStatus.success,
      ].contains(this);
}

@immutable
final class TextClipboardState extends Equatable {
  const TextClipboardState({
    this.status = TextClipboardStatus.initial,
    this.clipboard,
    this.clipboardTexts = const [],
  });

  final TextClipboardStatus status;
  final SystemClipboard? clipboard;
  final List<String> clipboardTexts;
  TextClipboardState copyWith({
    TextClipboardStatus Function()? status,
    SystemClipboard? clipboard,
    List<String>? clipboardTexts,
  }) {
    return TextClipboardState(
      status: status != null ? status() : this.status,
      clipboard: clipboard ?? this.clipboard,
      clipboardTexts: clipboardTexts ?? this.clipboardTexts,
    );
  }

  @override
  List<Object?> get props => [status, clipboard, clipboardTexts];
}
