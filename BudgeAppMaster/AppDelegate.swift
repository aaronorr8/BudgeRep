//
//  AppDelegate.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 3/8/19.
//  Copyright © 2019 Icecream. All rights reserved.
//

import UIKit
import Firebase
import StoreKit
import FirebaseDatabase



/*
 App Launch Logic
 
 1. If new users, currentUserID is empty, send to intro screen and then to budgets
 2. If returning user, send directly to budget
 2a. if currentUserID is populated, save to FireStore
 2b. if user is subscribed, allow unlimited budgets, no ads, and syncing
 2c. if user consumable, allow unlimited budgets and no ads
 
 */




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        UITabBar.appearance().tintColor = #colorLiteral(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)
        
        db = Firestore.firestore()
        
        if Auth.auth().currentUser?.uid != nil {
            currentUserG = Auth.auth().currentUser!.uid
            print("AppDelegate: currentUserG: \(currentUserG)")
            
            let docRef = db.collection("budgets").document(currentUserG)
            
            docRef.getDocument(source: .cache) { (document, error) in
                if let document = document {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Cached document data: \(dataDescription)")
                    
                    if let subStatusFromDoc = document.get("subscribedUser") {
                        subscribedUser = subStatusFromDoc as! Bool
                        print("AppDelegate: subscribedUser: \(subscribedUser)")
                    } else {
                        print("AppDelegate: Couldn't get subscriber status")
                    }
                } else {
                    print("Document does not exist in cache")
                }
            }
        } else {
            print("AppDeletage: Could not get userID")
        }
        
        return true
    }
    
    
    func goToInitialView() { //not being used
        
        if currentUserG != "" {
            print("AppDelegate - send to budgets")
            self.sendToBudgets()
        } else {
            print("AppDelegate - send to login")
            self.sendToBudgets()
        }
        
    }
    
    
    
    func sendToLogin() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeFlow")
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
    
    func sendToBudgets() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
    
    
    func setInitialView() {
        //MARK: Set Initial View
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if subscribedUser == true {
            print("currentUserG: \(currentUserG), subscribedUser: \(subscribedUser), Send to TabBarController")
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        } else {
            print("currentUserG: \(currentUserG), subscribedUser: \(subscribedUser), Send to WelcomeFlow")
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeFlow")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
    }
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

}

