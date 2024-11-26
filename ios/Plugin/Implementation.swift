//
//  Implementation.swift
//  Plugin
//
//  Created by Francisco Guerrero Escamilla on 25/11/24.
//  Copyright © 2024 Max Lynch. All rights reserved.
//

import Foundation

import WatchConnectivity
import Capacitor

public let COMMAND_KEY = "jsCommand"

@objc public class MessageSender: NSObject {

  @objc public func sendMessageToWatch(call: CAPPluginCall) {
    guard let value: String = call.getString("value"),
          let key: String = call.getString("key") else {
      call.reject("error with message")
      return
    }
    WCSession.default.sendMessage([key: value], replyHandler: nil)
    call.resolve(["result": true])
  }
}

@objc public class CapWatchSessionDelegate: NSObject, WCSessionDelegate {
  
  public static var shared = CapWatchSessionDelegate()
  
  public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
  }
  
#if os(iOS)
  
  public func sessionDidBecomeInactive(_ session: WCSession) { }
  
  public func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
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
