//
//  NotificationService.swift
//  roma-push
//
//  Created by Barrett Breshears on 6/14/19.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import UserNotifications
import UIKit


class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) modified"
            NotificationCenter.default.post(name: Notification.Name(rawValue: "refpush1"), object: nil)
            if let userDefaults = UserDefaults(suiteName: "group.com.vm.roma.wormhole") {
                
                let badgeCount = userDefaults.integer(forKey: "badge-count") + 1
                userDefaults.set(badgeCount, forKey: "badge-count")
                bestAttemptContent.badge = NSNumber(value: badgeCount)
                
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
