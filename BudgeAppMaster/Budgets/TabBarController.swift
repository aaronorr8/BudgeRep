//
//  TabBarController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 5/2/20.
//  Copyright © 2020 Icecream. All rights reserved.
//

import UIKit
import Firebase

class TabBarController: UITabBarController {
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        db = Firestore.firestore()
        fireStoreListener()

        

    }
    
    
    //MARK: FireStore Listener
    func fireStoreListener() {
        if let userID = Auth.auth().currentUser?.uid {
            db.collection("budgets").document(userID)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        print("send user to login screen")
                        self.performSegue(withIdentifier: "goToLogin", sender: self)
                        return
                    }
                    subscribedUser = document.get("subscribedUser") as! Bool
                    print("From Firestore, subscribedUser = \(subscribedUser)")
                    
                    if subscribedUser == false {
                        print("send user to login screen")
                        self.performSegue(withIdentifier: "goToLogin", sender: self)
                    } else {
                        print("Send user to budgets")
                    }
                    
            }
        }
        
        
    }

 

}
