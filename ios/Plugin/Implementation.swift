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
    var args: [String: Any] = [:]
    args["message"] = message
    handleWatchMessage(message)
  }
  
  public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    var args: [String: Any] = [:]
    args["message"] = message
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
    args["userInfo"] = userInfo
    handleWatchMessage(userInfo)
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
  }
  
#endif
}
