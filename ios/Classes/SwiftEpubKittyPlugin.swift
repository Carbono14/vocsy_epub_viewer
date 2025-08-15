import Flutter
import UIKit
import EpubViewerKit

public class SwiftEpubViewerPlugin: NSObject, FlutterPlugin,FolioReaderPageDelegate,FlutterStreamHandler {
    
    let folioReader = FolioReader()
    static var pageResult: FlutterResult? = nil
    static var pageChannel:FlutterEventChannel? = nil
    
    var config: EpubConfig?
    
    
    //12.13
    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "vocsy_epub_viewer", binaryMessenger: registrar.messenger())
      let instance = SwiftEpubViewerPlugin()
        
      pageChannel = FlutterEventChannel.init(name: "page",
                                  binaryMessenger: registrar.messenger());
      
      registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setConfig":
            handleSetConfig(call: call, result: result)
        case "open":
            handleOpen(call: call, result: result)
        case "close":
            handleClose(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleSetConfig(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Arguments must be a dictionary", details: nil))
            return
        }
        
        guard let identifier = arguments["identifier"] as? String,
              let scrollDirection = arguments["scrollDirection"] as? String,
              let color = arguments["themeColor"] as? String,
              let allowSharing = arguments["allowSharing"] as? Bool,
              let enableTts = arguments["enableTts"] as? Bool,
              let nightMode = arguments["nightMode"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
            return
        }
        
        do {
            self.config = EpubConfig(Identifier: identifier, tintColor: color, allowSharing: allowSharing,
                                   scrollDirection: scrollDirection, enableTts: enableTts, nightMode: nightMode)
            result(nil)
        } catch {
            result(FlutterError(code: "CONFIG_ERROR", message: "Failed to set config: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func handleOpen(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let bookPath = arguments["bookPath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Book path is required", details: nil))
            return
        }
        
        guard config != nil else {
            result(FlutterError(code: "CONFIG_NOT_SET", message: "Must call setConfig before opening a book", details: nil))
            return
        }
        
        setPageHandler()
        open(epubPath: bookPath)
        result(nil)
    }
    
    private func handleClose(call: FlutterMethodCall, result: @escaping FlutterResult) {
        close()
        result(nil)
    }
      
      private func setPageHandler(){
          SwiftEpubViewerPlugin.pageChannel?.setStreamHandler(self)

      }
      
      public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
          SwiftEpubViewerPlugin.pageResult = events
          return nil
      }

      public func onCancel(withArguments arguments: Any?) -> FlutterError? {
          return nil
      }
      
      
      fileprivate func open(epubPath: String) {
           if epubPath == "" {
              return
          }

          guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = windowScene.windows.first,
                let readerVc = window.rootViewController else {
              return
          }
          
          folioReader.presentReader(parentViewController: readerVc, withEpubPath: epubPath, andConfig: self.config!.config, shouldRemoveEpub: false)
          folioReader.readerCenter?.pageDelegate = self
      }

      public func pageWillLoad(_ page: FolioReaderPage) {
          
          print("page.pageNumber:"+String(page.pageNumber))

          if (SwiftEpubViewerPlugin.pageResult != nil){
              SwiftEpubViewerPlugin.pageResult!(String(page.pageNumber))
          }

      }
      
      private func close(){
          folioReader.readerContainer?.dismiss(animated: true, completion: nil)
      }

  }
