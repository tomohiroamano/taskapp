//
//  AppDelegate.swift
//  taskapp
//
//  Created by 天野智広 on 2019/02/06.
//  Copyright © 2019 天野智広. All rights reserved.
//

import UIKit
import UserNotifications    // 追加

@UIApplicationMain                             // UNUserNotificationCenterDelegateを追加
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // ユーザに通知の許可を求める
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound, .alert]) { (granted, error) in
            // Enable or disable features based on authorization
        }
        center.delegate = self     // 追加
        
        return true
    }
    
    // アプリがフォアグラウンドの時に通知を受け取ると呼ばれるメソッド --- ここから ---
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .alert])
    } // --- ここまで追加 ---
}
