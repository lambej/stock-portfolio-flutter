import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_clipboard/text_clipboard/repository/clipboard_repository.dart';
import 'package:cloud_clipboard/text_clipboard/widget/widget_for_reader.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:super_clipboard/super_clipboard.dart';

part 'text_clipboard_event.dart';
part 'text_clipboard_state.dart';

class TextClipboardBloc extends Bloc<TextClipboardEvent, TextClipboardState> {
  TextClipboardBloc({required ClipboardRepository clipboardRepository})
      : _clipboardRepository = clipboardRepository,
        super(const TextClipboardState()) {
    on<TextClipboardEventAddText>(_copyText);
    on<TextClipboardEventPaste>(_paste);
    on<TextClipboardRegister>(_register);
  }
  final ClipboardRepository _clipboardRepository;
  Future<void> _paste(
    TextClipboardEventPaste event,
    Emitter<TextClipboardState> emit,
  ) async {
    emit(state.copyWith(status: () => TextClipboardStatus.loading));
    final clipboard = await _readClipboardData();
    if (clipboard != '') {
      await _clipboardRepository.saveClipboard(clipboard);
      emit(
        state.copyWith(
          status: () => TextClipboardStatus.success,
        ),
      );
    } else {
      emit(state.copyWith(status: () => TextClipboardStatus.failure));
    }
  }

  Future<void> _copyText(
    TextClipboardEventAddText event,
    Emitter<TextClipboardState> emit,
  ) async {
    emit(state.copyWith(status: () => TextClipboardStatus.loading));
    final clipboard = state.clipboard ?? SystemClipboard.instance;
    if (clipboard != null) {
      final item = DataWriterItem()..add(Formats.plainText(event.text));

      await clipboard.write([item]);

      emit(
        state.copyWith(
          status: () => TextClipboardStatus.success,
          clipboard: clipboard,
        ),
      );
    } else {
      emit(state.copyWith(status: () => TextClipboardStatus.failure));
    }
  }

  Future<String> _readClipboardData() async {
    final clipboard = state.clipboard ?? SystemClipboard.instance;
    if (clipboard != null) {
      final reader = await clipboard.read();
      final readers = await Future.wait(
        reader.items.map(ReaderInfo.fromReader),
      );

      final string = await Future.wait(
        readers.mapIndexed(
          (index, element) =>
              _getClipboardFromReader(element.reader, index, Formats.plainText),
        ),
      );

      return string.first ?? '';
    }

    return '';
  }

  Future<String?> _getClipboardFromReader(
    DataReader reader,
    int index,
    DataFormat format,
  ) async {
    final text = await reader.readValue(Formats.plainText);
    if (text == null) {
      return null;
    } else {
      // Sometimes macOS uses CR for line break;
      return text.replaceAll(RegExp('\r[\n]?'), '\n');
    }
  }

  Future<void> _register(
    TextClipboardRegister event,
    Emitter<TextClipboardState> emit,
  ) async {
    emit(state.copyWith(status: () => TextClipboardStatus.loading));

    await emit.forEach<List<String>>(
      _clipboardRepository.getClipboard(),
      onData: (texts) => state.copyWith(
        status: () => TextClipboardStatus.success,
        clipboardTexts: texts,
      ),
      onError: (_, __) => state.copyWith(
        status: () => TextClipboardStatus.failure,
      ),
    );
  }
}

/// Turn [DataReader.getValue] into a future.
extension _ReadValue on DataReader {
  Future<T?> readValue<T extends Object>(ValueFormat<T> format) {
    final c = Completer<T?>();
    final progress = getValue<T>(
      format,
      c.complete,
      onError: c.completeError,
    );
    if (progress == null) {
      c.complete(null);
    }
    return c.future;
  }
}
