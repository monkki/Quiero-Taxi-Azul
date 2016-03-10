//
//  AppDelegate.swift
//  Quiero Taxi
//
//  Created by Roberto Gutierrez on 09/11/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        [GMSServices.provideAPIKey("AIzaSyC8UUZX2HaonS8AV09n8nLu8ZRYy8dcjGo")]
        
        IQKeyboardManager.sharedManager().enable = true
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = UIColor(red:0.271, green:0.439, blue:0.58, alpha:1)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        if #available(iOS 8.0, *) {
            
            let type: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound]
            
            let setting = UIUserNotificationSettings(forTypes: type, categories: nil)
        
            UIApplication.sharedApplication().registerUserNotificationSettings(setting)
        
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
        } else {
            // Fallback on earlier versions
        }

        
        if let options = launchOptions {
            if let notification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
                if let userInfo = notification.userInfo {
                    _ = userInfo["CustomField1"] as! String
                    // do something neat here
                }
            }
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
  
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        //print("el sevice token es:")
        //print(deviceToken)
        
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        let aux_device: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        //print(aux_device)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        prefs.setObject(aux_device, forKey: "DEVICETOKEN")
        
    }
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
         //print(error)
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        print("Recived ;) : \(userInfo)")
        //Parsing userinfo:
        //let temp : NSDictionary = userInfo
        if let info = userInfo["aps"] as? Dictionary<String, AnyObject>
        {
            let alertMsg = info["alert"] as! String
            let alert: UIAlertView!
            alert = UIAlertView(title: "", message: alertMsg, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        print("simon la notificacion")
        print(notification.alertBody)
        
        if let userInfo = notification.userInfo {
            let customField1 = userInfo["CustomField1"] as! String
            print("didReceiveLocalNotification: \(customField1)")
        }
        
        
      //  let alert = UIAlertController(title: "Quiero Taxi", message: "Su taxi esta en camino", preferredStyle: UIAlertControllerStyle.Alert)
      //  alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        /*
        let activeViewCont = application.windows[0].rootViewController as! CenterViewController
        
        //let activeViewCont = navigationController.visibleViewController
        
        //activeViewCont.presentedViewController(alert, animated: true, completion: nil)
        
        
        
        
        activeViewCont.presentViewController(alert, animated: true, completion: nil)
        
        */
        
     //   UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
    
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

