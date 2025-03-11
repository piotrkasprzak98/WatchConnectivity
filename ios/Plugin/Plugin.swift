import Foundation
import Capacitor
import WatchConnectivity

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapacitorWatchMessage)
public class CapacitorWatchMessage: CAPPlugin {

  private let implementation: MessageSender = MessageSender()

  override public func load() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.handleApplicationActive(notification:)),
      name: UIApplication.didBecomeActiveNotification,
      object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.handleCommandFromWatch(_:)),
      name: Notification.Name(COMMAND_KEY),
      object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.handleUserInfoFromWatch(_:)),
      name: Notification.Name(USER_INFO_KEY),
      object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.handleHeartRateFromWatch(_:)),
      name: Notification.Name(HEART_RATE_INFO_KEY),
      object: nil)
  }

  @objc func sendMessageToWatch(_ call: CAPPluginCall) {
    implementation.sendMessageToWatch(call: call)
  }

  @objc public func startWatchAppWithWorkoutConfiguration(_ call: CAPPluginCall) {
    implementation.startWatchAppWithWorkoutConfiguration(call: call)
  }

  @objc public func transferUserInfoToWatch(_ call: CAPPluginCall) {
    implementation.transferUserInfoToWatch(call: call)
  }

  @objc public func updateApplicationContextWatch(_ call: CAPPluginCall) {
    implementation.updateApplicationContextWatch(call: call)
  }

  @objc public func isWatchPaired(_ call: CAPPluginCall){
    implementation.isWatchPaired(call: call)
  }

  @objc public func isWatchAppInstalled(_ call: CAPPluginCall) {
    implementation.isWatchAppInstalled(call: call)
  }

  @objc public func getWatchInformation(_ call: CAPPluginCall) {
    implementation.getWatchInformation(call: call)
  }

  @objc public func getWatchStoredName(_ call: CAPPluginCall) {
    implementation.getWatchStoredName(call: call)
  }

  @objc func handleApplicationActive(notification: NSNotification) {
    assert(WCSession.isSupported(), "This sample requires Watch Connectivity support!")
    WCSession.default.delegate = CapWatchSessionDelegate.shared
    WCSession.default.activate()
  }

  @objc func handleCommandFromWatch(_ notification: NSNotification) {
      if let command = notification.userInfo?[COMMAND_KEY] as? String {
          debugPrint("WATCH process: \(command)")
        notifyListeners(PluginConstants.commandListener, data: [PluginConstants.command: command])
      }
  }

  @objc func handleUserInfoFromWatch(_ notification: NSNotification) {
    if let userInfo: [String : Any] = notification.userInfo?[PluginConstants.userInfo] as? [String : Any] {
      debugPrint("WATCH user Info: \(userInfo)")
      notifyListeners(PluginConstants.userInfoListener, data: userInfo)
    }
  }

  @objc func handleHeartRateFromWatch(_ notification: NSNotification) {
    if let userInfo: [String : Any] = notification.userInfo as? [String : Any] {
      notifyListeners(PluginConstants.heartRateListener, data: userInfo)
    }
  }
}
