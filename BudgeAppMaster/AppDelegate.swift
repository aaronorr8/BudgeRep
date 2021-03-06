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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    


    
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        UITabBar.appearance().tintColor = #colorLiteral(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)
        
        
        
        
//        if defaults.object(forKey: "SubscribedUser") != nil {
//            print("Set subscribedUser defaults: \(defaults.object(forKey: "SubscribedUser") as? Bool ?? false)")
//            subscribedUser = defaults.object(forKey: "SubscribedUser") as? Bool ?? false
//        } else {
//            print("subscribedUser defaults are nil")
//        }
//
//        if defaults.object(forKey: "CurrentUserG") != nil {
//            print("Set currentUserG defaults: \(defaults.object(forKey: "CurrentUserG") as? String ?? "")")
//            currentUserG = defaults.object(forKey: "CurrentUserG") as? String ?? ""
//        } else {
//            print("currentUserG defaults are nil")
//        }



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
                
                if subscribedUser == true {
                   self.sendToBudgets()
                } else {
                    self.sendToLogin()
                }
                
                
            }
        } else {
            print("AppDeletage: Could not get userID")
            self.sendToLogin()
        }
 
        
        return true
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
    
    
   
    
 
    
    
//    func receiptValidation() {
//        let SUBSCRIPTION_SECRET = "9508e678719b4253bc6c7ae9fb430df1"
//        let receiptPath = Bundle.main.appStoreReceiptURL?.path
//        if FileManager.default.fileExists(atPath: receiptPath!){
//            var receiptData:NSData?
//            do{
//                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
//            }
//            catch{
//                print("ERROR: " + error.localizedDescription)
//            }
//            //let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
//
//            print(base64encodedReceipt!)
//
//
//            let requestDictionary = ["receipt-data":base64encodedReceipt!,"password":SUBSCRIPTION_SECRET]
//
//            guard JSONSerialization.isValidJSONObject(requestDictionary) else {  print("requestDictionary is not valid JSON");  return }
//            do {
//                let requestData = try JSONSerialization.data(withJSONObject: requestDictionary)
//                let validationURLString = "https://sandbox.itunes.apple.com/verifyReceipt"  // this works but as noted above it's best to use your own trusted server
//                guard let validationURL = URL(string: validationURLString) else { print("the validation url could not be created, unlikely error"); return }
//                let session = URLSession(configuration: URLSessionConfiguration.default)
//                var request = URLRequest(url: validationURL)
//                request.httpMethod = "POST"
//                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
//                let task = session.uploadTask(with: request, from: requestData) { (data, response, error) in
//                    if let data = data , error == nil {
//                        do {
//                            let appReceiptJSON = try JSONSerialization.jsonObject(with: data)
//                            print("success. here is the json representation of the app receipt: \(appReceiptJSON)")
//                            // if you are using your server this will be a json representation of whatever your server provided
//                        } catch let error as NSError {
//                            print("json serialization failed with error: \(error)")
//                        }
//                    } else {
//                        print("the upload task returned an error: \(error)")
//                    }
//                }
//                task.resume()
//            } catch let error as NSError {
//                print("json serialization failed with error: \(error)")
//            }
//
//
//
//        }
//    }
    
   //https://www.logisticinfotech.com/blog/ios-swift-in-app-subscription-with-receipt-validation/
    //https://www.revenuecat.com/apple-receipt-validation#receipt-form-btn
    //https://app.revenuecat.com/apps/c590dec9/products
}

