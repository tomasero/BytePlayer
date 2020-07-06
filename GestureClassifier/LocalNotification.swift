//
//  LocalNotification.swift
//  GestureClassifier
//
//  Created by Shardul Sapkota on 7/5/20.
//  Copyright © 2020 Abishkar Chhetri. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func userRequest() {
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    
        func scheduleNotification(notificationType: String) {
        
        let content = UNMutableNotificationContent()
        let categoryIdentifire = "Byte Player"
        
        content.title = notificationType
        content.body = "What do you want to do with this notification?."
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = categoryIdentifire
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let actionReadLater = UNNotificationAction(identifier: "readLater", title: "Read Later", options: [])
        let actionShowDetails = UNNotificationAction(identifier: "showDetails", title: "Show Details", options: [.foreground])
        let category = UNNotificationCategory(identifier: categoryIdentifire,
                                              actions: [actionReadLater, actionShowDetails],
                                              intentIdentifiers: [],
                                              options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "Local Notification" {
            print("Handling notifications with the Local Notification Identifier")
        }
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Read Later":
            print("Read Later")
            scheduleNotification(notificationType: "sdfd")
        case "Show Details":
            print("Show Details")
        default:
            print("Unknown action")
        }
        completionHandler()
    }
}
