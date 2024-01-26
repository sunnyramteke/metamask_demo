import 'dart:convert';

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utilities/logger.dart';

class MethodDialog extends StatefulWidget {
  static Future<void> show(
    BuildContext context,
    String method,
    Future<dynamic> response,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return MethodDialog(
          method: method,
          response: response,
        );
      },
    );
  }

  const MethodDialog({
    super.key,
    required this.method,
    required this.response,
  });

  final String method;
  final Future<dynamic> response;

  @override
  MethodDialogState createState() => MethodDialogState();
}

class MethodDialogState extends State<MethodDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // backgroundColor: Web3ModalTheme.colorsOf(context).background175,
      title: Text(widget.method),
      content: FutureBuilder<dynamic>(
        future: widget.response,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          logger.d('snapshot: $snapshot');
          if (snapshot.hasData) {
            final String t = jsonEncode(snapshot.data);
            return InkWell(
              onTap: () => _copyToClipboard(t),
              child: Text(t),
            );
          } else if (snapshot.hasError) {
            return InkWell(
              onTap: () => _copyToClipboard(snapshot.data.toString()),
              child: Text(snapshot.error.toString()),
            );
          } else {
            return const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Close',
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then(
      (_) => showPlatformToast(
        child: const Text(
          'Copied to clipboard',
        ),
        context: context,
      ),
    );
  }
}
