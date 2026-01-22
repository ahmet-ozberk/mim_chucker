import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';

/// Widget for displaying JSON data with controls
class JsonViewerPanel extends StatefulWidget {
  /// The JSON data to display
  final dynamic jsonData;

  /// Title of the panel
  final String title;

  /// Constructor
  const JsonViewerPanel({
    super.key,
    required this.jsonData,
    required this.title,
  });

  @override
  State<JsonViewerPanel> createState() => _JsonViewerPanelState();
}

class _JsonViewerPanelState extends State<JsonViewerPanel> {
  bool _isTreeView = true;
  dynamic _parsedData;
  bool _canShowTreeView = false;

  @override
  void initState() {
    super.initState();
    _processData();
  }

  @override
  void didUpdateWidget(JsonViewerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jsonData != widget.jsonData) {
      _processData();
    }
  }

  void _processData() {
    final data = widget.jsonData;
    if (data is Map || data is List) {
      _parsedData = data;
      _canShowTreeView = true;
    } else if (data is String) {
      try {
        final decoded = json.decode(data);
        if (decoded is Map || decoded is List) {
          _parsedData = decoded;
          _canShowTreeView = true;
        } else {
          _parsedData = data;
          _canShowTreeView = false;
        }
      } catch (_) {
        _parsedData = data;
        _canShowTreeView = false;
      }
    } else {
      _parsedData = data;
      _canShowTreeView = false;
    }

    if (!_canShowTreeView) {
      _isTreeView = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (_canShowTreeView)
                      IconButton(
                        icon: Icon(
                          _isTreeView ? Icons.code : Icons.account_tree,
                        ),
                        onPressed: () {
                          setState(() {
                            _isTreeView = !_isTreeView;
                          });
                        },
                        tooltip: _isTreeView ? 'Show as text' : 'Show as tree',
                      ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _copyJson,
                      tooltip: 'Copy to clipboard',
                    ),
                  ],
                ),
              ],
            ),
          ),
          _isTreeView && _canShowTreeView
              ? JsonViewer(_parsedData)
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _getContentAsString(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  /// Copy content to clipboard
  void _copyJson() {
    Clipboard.setData(ClipboardData(text: _getContentAsString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Content copied to clipboard'),
      ),
    );
  }

  /// Get content as string (pretty JSON if available, otherwise raw string)
  String _getContentAsString() {
    if (_canShowTreeView) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(_parsedData);
      } catch (_) {
        return _parsedData.toString();
      }
    }
    return _parsedData?.toString() ?? '';
  }
}
