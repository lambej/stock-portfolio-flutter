// stateless widget for the text clipboard page that allow to add text and display all the text added

import 'package:cloud_clipboard/text_clipboard/text_clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_clipboard/super_clipboard.dart';

const _notAvailableMessage =
    'There is no text available in the clipboard. Please add some text to the clipboard to see it here.';

class TextClipboardPage extends StatefulWidget {
  const TextClipboardPage({super.key});
  @override
  State<TextClipboardPage> createState() => _TextClipboardPageState();
  static Page<void> page() => MaterialPage<void>(
        child: BlocProvider(
          create: (context) => TextClipboardBloc(
            clipboardRepository: context.read<ClipboardRepository>(),
          )..add(TextClipboardRegister()),
          child: const TextClipboardPage(),
        ),
      );
}

class _TextClipboardPageState extends State<TextClipboardPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    ClipboardEvents.instance?.registerPasteEventListener(_onPasteEvent);
  }

  @override
  void dispose() {
    super.dispose();
    ClipboardEvents.instance?.unregisterPasteEventListener(_onPasteEvent);
  }

  Future<void> _onPasteEvent(ClipboardReadEvent event) async {
    context.read<TextClipboardBloc>().add(
          TextClipboardEventPaste(context),
        );
  }

  List<Widget> contentWidgets = <Widget>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Clipboard'),
      ),
      body: _textClipboardBody(),
      floatingActionButton: _addTextButton(context),
    );
  }

  // floating action button to add text
  FloatingActionButton _addTextButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        context.read<TextClipboardBloc>().add(
              TextClipboardEventPaste(context),
            );
      },
      child: const Icon(Icons.paste),
    );
  }

  void showMessage(String notAvailableMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(notAvailableMessage),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  Widget _textClipboardBody() {
    return BlocConsumer<TextClipboardBloc, TextClipboardState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state.status == TextClipboardStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state.status == TextClipboardStatus.initial ||
            state.status == TextClipboardStatus.success) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.clipboardTexts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Center(
                            child: Text(state.clipboardTexts[index]),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              context.read<TextClipboardBloc>().add(
                                    TextClipboardEventAddText(
                                      state.clipboardTexts[index],
                                    ),
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Text copied to clipboard'),
                                  duration: Duration(milliseconds: 1500),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text(_notAvailableMessage));
        }
      },
    );
  }
}
