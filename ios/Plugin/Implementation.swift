//
//  Implementation.swift
//  Plugin
//
//  Created by Francisco Guerrero Escamilla on 25/11/24.
//  Copyright © 2024 Max Lynch. All rights reserved.
//

import Foundation
import HealthKit
import WatchConnectivity
import Capacitor

public let COMMAND_KEY = "jsCommand"
public let USER_INFO_KEY = "jsUserInfo"
public let HEART_RATE_INFO_KEY = "jsHeartRateMessage"

@objc public class MessageSender: NSObject {

  private let healthStore: HKHealthStore = HKHealthStore()

  @objc public func sendMessageToWatch(call: CAPPluginCall) {
    guard let value: String = call.getString("value"),
          let key: String = call.getString("key") else {
      call.reject("error with message")
      return
    }
    guard WCSession.default.activationState == .activated  else {
      call.reject("activation state has to be active")
      return
    }
    WCSession.default.sendMessage([key: value], replyHandler: nil)
    call.resolve(["result": true])
  }

  @objc public func getWatchInformation(call: CAPPluginCall) {
    guard WCSession.default.activationState == .activated  else {
      call.reject("activation state has to be active")
      return
    }
    WCSession.default.sendMessage([PluginConstants.infoCommand: ""], replyHandler: { reply in
      var response: [String: Any] = [:]
      if let watchName: String = reply[PluginConstants.watchName] as? String {
        UserDefaults.standard.setValue(watchName, forKey: PluginConstants.watchName)
        response.updateValue(watchName, forKey: PluginConstants.watchName)
      }
      if let watchBattery: Int = reply[PluginConstants.watchBattery] as? Int {
        UserDefaults.standard.setValue(watchBattery, forKey: PluginConstants.watchBattery)
        response.updateValue(watchBattery, forKey: PluginConstants.watchBattery)
      }
      call.resolve(["result": response])
    }, errorHandler: { error in
      call.reject(error.localizedDescription)
    })
  }

  @objc public func getWatchStoredName(call: CAPPluginCall) {
    if let name: String = UserDefaults.standard.string(forKey: PluginConstants.watchName) {
      call.resolve(["result": name])
    } else {
      call.reject("apple watch name not stored")
    }
  }

  @objc public func startWatchAppWithWorkoutConfiguration(call: CAPPluginCall) {
    let activityType: String? = call.getString("activityType")
    let locationType: String? = call.getString("locationType")
    
    guard WCSession.default.isPaired  else {
      call.reject("An apple watch has to be paired")
      return
    }
    guard WCSession.default.isWatchAppInstalled  else {
      call.reject("The watch app has to be installed")
      return
    }

    let configuration: HKWorkoutConfiguration = HKWorkoutConfiguration()
    configuration.activityType = .other
    configuration.locationType = .unknown
    healthStore.startWatchApp(with: configuration) { (succeed, error) in
      if let error: Error = error {
        call.reject("error starting workout\(error)")
        return
      }
      call.resolve(["result": succeed])
    }
  }

  @objc public func transferUserInfoToWatch(call: CAPPluginCall) {
    guard let value: String = call.getString("value"),
          let key: String = call.getString("key") else {
      call.reject("error with message")
      return
    }
    guard WCSession.default.activationState == .activated  else {
      call.reject("activation state has to be active")
      return
    }
    WCSession.default.transferUserInfo([key: value])
    call.resolve(["result": true])
  }

  @objc public func updateApplicationContextWatch(call: CAPPluginCall) {
    guard let value: String = call.getString("value"),
          let key: String = call.getString("key") else {
      call.reject("error with message")
      return
    }
    guard WCSession.default.activationState == .activated  else {
      call.reject("activation state has to be active")
      return
    }
    do {
      try WCSession.default.updateApplicationContext([key: value])
      call.resolve(["result": true])
    } catch {
      call.reject("error updateApplicationContext \(error)")
    }
    
  }

  @objc public func isWatchPaired(call: CAPPluginCall) {
    guard WCSession.default.activationState == .activated  else {
      call.reject("activation state has to be active")
      return
    }
    let paired: Bool = WCSession.default.isPaired
    call.resolve(["result": paired])
  }

  @objc public func isWatchAppInstalled(call: CAPPluginCall) {
    guard WCSession.default.activationState == .activated  else {
      call.reject("activation state has to be active")
      return
    }
    let installed: Bool = WCSession.default.isWatchAppInstalled
    call.resolve(["result": installed])
  }
}

@objc public class CapWatchSessionDelegate: NSObject, WCSessionDelegate {
  
  public static var shared = CapWatchSessionDelegate()
  
  public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
  }

#if os(iOS)
  
  public func sessionDidBecomeInactive(_ session: WCSession) {
    debugPrint("Session did become inactive")
  }
  
  public func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
    debugPrint("Session did deactivate")
  }
  
  public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
    handleWatchMessage(message)
  }
  
  public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    handleWatchMessage(message)
  }
  
  public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    handleWatchMessage(applicationContext)
  }

  public func sessionReachabilityDidChange(_ session: WCSession) {
    debugPrint("Session did change reachability is reachable: \(session.isReachable)")
  }

  public func sessionWatchStateDidChange(_ session: WCSession) {
    debugPrint("Session watch state did change \(session.activationState)")
  }
  
  public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
    var args: [String: Any] = [:]
    args[PluginConstants.userInfo] = userInfo
    handleWatchUserInfo(args)
    checkIfContainsWatchData(args)
  }
  
  func commandToJS(_ command: String) {
    NotificationCenter.default.post(
      name: Notification.Name(COMMAND_KEY),
      object: nil,
      userInfo: [COMMAND_KEY: command])
  }
  
  func handleWatchMessage(_ userInfo: [String: Any]) {
    if let command: String = userInfo.values.first as? String {
      commandToJS(command)
    }
    if userInfo.keys.contains(where: { key in
      key.contains(PluginConstants.heartRateMessage)
    }) {
      notifyHeartRate(userInfo)
    }
  }

  func handleWatchUserInfo(_ userInfo: [String: Any]) {
    NotificationCenter.default.post(
      name: Notification.Name(USER_INFO_KEY),
      object: nil,
      userInfo: userInfo)
  }

  func notifyHeartRate(_ message: [String: Any]) {
    NotificationCenter.default.post(
      name: Notification.Name(HEART_RATE_INFO_KEY),
      object: nil,
      userInfo: message)
  }

  private func checkIfContainsWatchData(_ userInfo: [String: Any]) {
    if let userInfo: [String : Any] = userInfo[PluginConstants.userInfo] as? [String : Any] {
      if userInfo.keys.contains(where: { $0 == PluginConstants.watchInfo }) {
        if let watchName: String = userInfo[PluginConstants.watchName] as? String {
          UserDefaults.standard.setValue(watchName, forKey: PluginConstants.watchName)
        }
      }
    }
  }
  
#endif
}
