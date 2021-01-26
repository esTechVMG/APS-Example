//
//  AppDelegate.swift
//  pushNotifications
//
//  Created by A4-iMAC01 on 26/01/2021.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.registerForPushNotifications()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let notificationOption = launchOptions?[.remoteNotification]
        if let notification = notificationOption as? [String: AnyObject],
           let aps = notification["aps"] as? [String:AnyObject]{
            print("Titulo de la notificacion: \(aps["category"] as! String)")
        }
        
        // Override point for customization after application launch.
        return true
    }
    //
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //This output doesn t work in Xcode simulator. Only real device
        guard let aps = userInfo["aps"] as? [String: AnyObject] else{
            completionHandler(.failed)
            return
        }
        
        let alert = UIAlertController(title: "hola", message: "Esto es una notificacion", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //Present the alert
        (UIApplication.shared.windows.filter{$0.isKeyWindow}.first)?.rootViewController?.present(alert, animated: true, completion: nil)
        
        
        
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func registerForPushNotifications() -> Void {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {(granted:Bool,error:Error?) -> Void in
            print("Permission Granted: \(granted)")
            guard granted else {return}
            //Acciones personalizadas
            let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "Aceptar", options: [.foreground])
            let denyAction = UNNotificationAction(identifier: "DENY_ACTION", title: "Denegar", options: [.foreground])
            //Tipo de notificaciones
            let notifCategory = UNNotificationCategory(identifier: "TEST_PUSH", actions: [acceptAction,denyAction], intentIdentifiers: [], options: .customDismissAction)
            
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.setNotificationCategories([notifCategory])
            
            self.getNotificationSettings()
            UNUserNotificationCenter.current().delegate = self
        })
        
    }
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {settings in
            print("Configuracion Push: \(settings)")
            guard settings.authorizationStatus == .authorized else {return}
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        })
    }
    //Completed registering to APNS
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map({data in String(format: "%02.2hh%", data)
        })
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    //Error while registering to APNS
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Fallo al registrar: \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        //let username = userInfo["username"] as! String
        if let aps = userInfo["aps"] as? [String: AnyObject]{
            /*
             This works in the simulator
             print(aps)
             */
            
            switch response.actionIdentifier {
            case "ACCEPT_ACTION":
                print("El usuario ha aceptado")
                break
            case "DENY_ACTION":
                print("El usuario ha denegado")
                break
            default:
               print("Abierta la notificacion sin click")
            }
        }
    }
}
/*
{
    "aps":{
        "alert": {
            "title": "Notificación recibida de la aplicacion push",
            "body": "Acepta el nuevo evento para mas informacion"
        },
        "sound": "default",
        "link_url": "https://escuelaestech.es",
        "category": "TEST_PUSH"
    },
    "username": "Vicente"
}
*/
