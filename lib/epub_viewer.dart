import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'model/enum/epub_scroll_direction.dart';
part 'model/epub_locator.dart';
part 'utils/util.dart';

class VocsyEpub {
  static const MethodChannel _channel = const MethodChannel('vocsy_epub_viewer');
  static const EventChannel _pageChannel = const EventChannel('page');
  static const EventChannel _highlightsChannel = const EventChannel('highlights');


  /// Configure Viewer's with available values
  ///
  /// themeColor is the color of the reader
  /// scrollDirection uses the [EpubScrollDirection] enum
  /// allowSharing
  /// enableTts is an option to enable the inbuilt Text-to-Speech
  static Future<void> setConfig({
    Color themeColor = Colors.blue,
    String identifier = 'book',
    bool nightMode = false,
    EpubScrollDirection scrollDirection = EpubScrollDirection.ALLDIRECTIONS,
    bool allowSharing = false,
    bool enableTts = false,
  }) async {
    try {
      final Map<String, dynamic> args = {
        "identifier": identifier,
        "themeColor": Util.getHexFromColor(themeColor),
        "scrollDirection": Util.getDirection(scrollDirection),
        "allowSharing": allowSharing,
        'enableTts': enableTts,
        'nightMode': nightMode
      };
      await _channel.invokeMethod('setConfig', args);
    } on PlatformException catch (e) {
      throw Exception('Failed to set config: ${e.message}');
    }
  }

  /// bookPath should be a local file.
  /// Last location is only available for android.
  static Future<void> open(String bookPath, {EpubLocator? lastLocation}) async {
    try {
      final Map<String, dynamic> args = {
        "bookPath": bookPath,
        'lastLocation': lastLocation == null ? '' : jsonEncode(lastLocation.toJson()),
      };
      await _channel.invokeMethod('setChannel');
      await _channel.invokeMethod('open', args);
    } on PlatformException catch (e) {
      throw Exception('Failed to open book: ${e.message}');
    }
  }

  /// bookPath should be an asset file path.
  /// Last location is only available for android.
  static Future<void> openAsset(String bookPath, {EpubLocator? lastLocation}) async {
    try {
      if (extension(bookPath) != '.epub') {
        throw Exception('${extension(bookPath)} cannot be opened, use an EPUB File');
      }
      
      final file = await Util.getFileFromAsset(bookPath);
      final Map<String, dynamic> args = {
        "bookPath": file.path,
        'lastLocation': lastLocation == null ? '' : jsonEncode(lastLocation.toJson()),
      };
      await _channel.invokeMethod('setChannel');
      await _channel.invokeMethod('open', args);
    } on PlatformException catch (e) {
      throw Exception('Failed to open asset book: ${e.message}');
    }
  }

  static Future<void> setChannel() async {
    try {
      await _channel.invokeMethod('setChannel');
    } on PlatformException catch (e) {
      throw Exception('Failed to set channel: ${e.message}');
    }
  }

  /// Close the epub reader
  static Future<void> close() async {
    try {
      await _channel.invokeMethod('close');
    } on PlatformException catch (e) {
      throw Exception('Failed to close reader: ${e.message}');
    }
  }

  /// Stream to get EpubLocator for android and pageNumber for iOS
  static Stream<dynamic> get locatorStream {
    return _pageChannel.receiveBroadcastStream();
  }

  /// Stream to get Highlights
  static Stream<dynamic> get highlightsStream {
    return _highlightsChannel.receiveBroadcastStream();
  }
}
