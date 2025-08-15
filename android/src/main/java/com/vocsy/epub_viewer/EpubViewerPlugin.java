package com.vocsy.epub_viewer;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import java.util.Map;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import androidx.annotation.NonNull;

/** EpubReaderPlugin */
public class EpubViewerPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {

  private Reader reader;
  private ReaderConfig config;
  private MethodChannel channel;
  static private Activity activity;
  static private Context context;
  static BinaryMessenger messenger;
  static private EventChannel eventChannel;
  static private EventChannel highlightsChannel;

  static private EventChannel.EventSink pageSink;
  static private EventChannel.EventSink highlightsSink;

  private static final String channelName = ReaderChannels.MAIN.getValue();


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    messenger = binding.getBinaryMessenger();
    context = binding.getApplicationContext();
    new EventChannel(messenger,ReaderChannels.PAGE.getValue()).setStreamHandler(new EventChannel.StreamHandler() {

      @Override
      public void onListen(Object o, EventChannel.EventSink eventSink) {

        pageSink = eventSink;
        if(pageSink == null) {
          Log.i("empty", "Sink is empty");
        }
      }

      @Override
      public void onCancel(Object o) {

      }
    });

    new EventChannel(messenger,ReaderChannels.HIGHLIGHTS.getValue()).setStreamHandler(new EventChannel.StreamHandler() {

      @Override
      public void onListen(Object o, EventChannel.EventSink eventSink) {

        highlightsSink = eventSink;
        if(highlightsSink == null) {
          Log.i("empty", "Sink is empty");
        }
      }

      @Override
      public void onCancel(Object o) {

      }
    });

    channel = new MethodChannel(binding.getFlutterEngine().getDartExecutor(), channelName);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    // TODO: your plugin is no longer attached to a Flutter experience.
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {

  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    try {
      switch (call.method) {
        case "setConfig":
          handleSetConfig(call, result);
          break;
        case "open":
          handleOpen(call, result);
          break;
        case "close":
          handleClose(call, result);
          break;
        case "setChannel":
          handleSetChannel(call, result);
          break;
        default:
          result.notImplemented();
          break;
      }
    } catch (Exception e) {
      Log.e("EpubViewerPlugin", "Error handling method call: " + call.method, e);
      result.error("PLUGIN_ERROR", "Error in " + call.method + ": " + e.getMessage(), null);
    }
  }

  private void handleSetConfig(MethodCall call, Result result) {
    Map<String,Object> arguments = (Map<String, Object>) call.arguments;
    if (arguments == null) {
      result.error("INVALID_ARGUMENTS", "Arguments cannot be null", null);
      return;
    }
    
    try {
      String identifier = arguments.get("identifier").toString();
      String themeColor = arguments.get("themeColor").toString();
      String scrollDirection = arguments.get("scrollDirection").toString();
      Boolean nightMode = Boolean.parseBoolean(arguments.get("nightMode").toString());
      Boolean allowSharing = Boolean.parseBoolean(arguments.get("allowSharing").toString());
      Boolean enableTts = Boolean.parseBoolean(arguments.get("enableTts").toString());
      
      config = new ReaderConfig(context, identifier, themeColor,
              scrollDirection, allowSharing, enableTts, nightMode);
      result.success(null);
    } catch (Exception e) {
      result.error("CONFIG_ERROR", "Failed to set config: " + e.getMessage(), null);
    }
  }

  private void handleOpen(MethodCall call, Result result) {
    Map<String,Object> arguments = (Map<String, Object>) call.arguments;
    if (arguments == null) {
      result.error("INVALID_ARGUMENTS", "Arguments cannot be null", null);
      return;
    }

    if (config == null) {
      result.error("CONFIG_NOT_SET", "Must call setConfig before opening a book", null);
      return;
    }

    try {
      String bookPath = arguments.get("bookPath").toString();
      String lastLocation = arguments.get("lastLocation").toString();

      Log.i("EpubViewerPlugin", "Opening book: " + bookPath);
      
      reader = new Reader(context, messenger, config, pageSink, highlightsSink);
      reader.open(bookPath, lastLocation);
      result.success(null);
    } catch (Exception e) {
      result.error("OPEN_ERROR", "Failed to open book: " + e.getMessage(), null);
    }
  }

  private void handleClose(MethodCall call, Result result) {
    try {
      if (reader != null) {
        reader.close();
        result.success(null);
      } else {
        result.error("NO_READER", "No reader instance to close", null);
      }
    } catch (Exception e) {
      result.error("CLOSE_ERROR", "Failed to close reader: " + e.getMessage(), null);
    }
  }

  private void handleSetChannel(MethodCall call, Result result) {
    try {
      eventChannel = new EventChannel(messenger, ReaderChannels.PAGE.getValue());
      eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
        @Override
        public void onListen(Object o, EventChannel.EventSink eventSink) {
          pageSink = eventSink;
        }

        @Override
        public void onCancel(Object o) {
          pageSink = null;
        }
      });

      highlightsChannel = new EventChannel(messenger, ReaderChannels.HIGHLIGHTS.getValue());
      highlightsChannel.setStreamHandler(new EventChannel.StreamHandler() {
        @Override
        public void onListen(Object o, EventChannel.EventSink eventSink) {
          highlightsSink = eventSink;
        }

        @Override
        public void onCancel(Object o) {
          highlightsSink = null;
        }
      });
      
      result.success(null);
    } catch (Exception e) {
      result.error("CHANNEL_ERROR", "Failed to set channels: " + e.getMessage(), null);
    }
  }
}
