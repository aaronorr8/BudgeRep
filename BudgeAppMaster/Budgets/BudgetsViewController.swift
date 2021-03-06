    //
//  BudgetsViewController.swift
//  Budget App
//
//  Created by Aaron Orr on 7/10/18.
//  Copyright © 2018 Icecream. All rights reserved.
//

import UIKit
import Firebase
import AudioToolbox


    
class BudgetsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var gradientLayer: CAGradientLayer!
    var roundButton = UIButton()
    var totalBudgetsAllocation = 0.0
    var totalBudgetsAvailable = 0.0
    var amt: Int = 0

    let hiddenBgColor = UIColor.clear
    let visibleBgColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    let hiddenTitleColor = UIColor.clear
    let visibleTitleColor = UIColor.black
    var hideNav = Bool()
    var totalSpentAllBudgets = Double()
    
    //MARK: PROGRESS BAR SCALE
    let xScale = CGFloat(1.0)
    let yScale = CGFloat(3.0)
    
    
    
    override func viewDidLayoutSubviews() {
        
        
    }
    
    
    func checkSubsciptionStatus() {
        if currentUserG == "" || subscribedUser == false {
            print("BudgetsVC: Send user to login")
            self.performSegue(withIdentifier: "goToLogin", sender: self)
        } else {
            print("BudgetsVC: User is subscribed, don't send to login")
        }
    }
    
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        checkSubsciptionStatus()
        
        //Reset view for new users. Notification is posted when new users sign up
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        

        db = Firestore.firestore()
    
        
        collectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom:15, right: 0)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(BudgetsViewController.handleLongGesture))
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        
        
//        receiptValidation()
        
        timeToResetAlert()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fireStoreListener()
        
    
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
       
        calculateTotalAvailable()
        calculateTotalAllocation()
        
        let amount = Double(amt/100) + Double(amt%100)/100
        self.navigationItem.title = String(convertDoubleToCurency(amount: totalBudgetsAvailable))
        

        
        if reloadBudgetViewCC == true {
            self.collectionView.reloadData()
            reloadBudgetViewCC = false
        }
       
      

    }
    
  
    
    
    func showConfirmationToast() {
        
        if toastOverride != true {
            
            if showToast == true && toastSuccess == true {
                Toast(text: "Saved \(savedAmount) to \(savedBudget)", delay: 0.1, duration: 2.5).show()
                let appearance = ToastView.appearance()
                appearance.backgroundColor = #colorLiteral(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)
                appearance.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                appearance.font = UIFont.boldSystemFont(ofSize: 20)
                
                //Add vibration
                let peek = SystemSoundID(1102)
                AudioServicesPlaySystemSound(peek)
            } else if showToast == true && toastSuccess == false {
                Toast(text: "Saved \(savedAmount) to \(savedBudget)", delay: 0.1, duration: 2.5).show()
                let appearance = ToastView.appearance()
                appearance.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                appearance.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                appearance.font = UIFont.boldSystemFont(ofSize: 20)
            } else {
                //
            }
            
            showToast = false
        }
        toastOverride = false
    }
    
   
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let duration = 0.3
        let offset = scrollView.contentOffset.y
        
        if offset > -40 {
            hideNav = false
        } else {
            hideNav = true
        }
    
        if hideNav == true {
        
            UIView.animate(withDuration: 0.5, animations: {
                self.navigationController?.navigationBar.backgroundColor = self.hiddenBgColor
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: self.hiddenTitleColor]
                self.navigationController?.navigationBar.tintColor = self.hiddenTitleColor
                self.navigationController?.navigationBar.shadowImage = UIImage()
                
            })
        
        } else {
            
            UIView.animate(withDuration: 0.5, animations: {
                self.navigationController?.navigationBar.backgroundColor = self.visibleBgColor
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: self.visibleTitleColor]
                self.navigationController?.navigationBar.tintColor = self.visibleTitleColor
                self.navigationController?.navigationBar.shadowImage = UIImage(named: "shadowImage")
                
            })
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if budgetNameG.count == 0 {
            return 1
        } else {
        
        return budgetNameG.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: view.frame.width - 10, height: 110.0)
    }
    
  
    
    //MARK: COLLECTION HEADER/FOOTER
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionView.elementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! BudgetCollectionReusableView
        
            
            //MARK: HEADER TOTAL REMAINING
            let amount = Double(amt/100) + Double(amt%100)/100
            headerView.totalRemainingBudget.text = String(convertDoubleToCurency(amount: totalBudgetsAvailable))
            self.navigationItem.title = String(convertDoubleToCurency(amount: totalBudgetsAvailable))
            
            
            //MARK: HEADER PROGRESS BAR
            let progress = totalSpentAllBudgets/totalBudgetsAllocation
            
            headerView.wavyProgress.trackColor = colorTrackH
            
            if progress <= 1 {
                headerView.wavyProgress.progressColor = colorGreenH
            } else if progress > 1 {
                headerView.wavyProgress.progressColor = colorRedH
            }
            
            headerView.wavyProgress.setProgressWithAnimation(duration: 1.0, value: Float(progress))
            
           //MARK: HEADER PROGRESS BAR LABELS
            
            let headerSpentTotal = String(convertDoubleToCurency(amount: totalSpentAllBudgets))
            let headerTotalAvailable = String(convertDoubleToCurency(amount: totalBudgetsAllocation))
            
            headerView.progressSpentLabel.text = "\(headerSpentTotal) spent"
            headerView.progressTotalLabel.text = "\(headerTotalAvailable) total budgets"
            
            return headerView
        
        //MARK: COLLECTION FOOTER
        case UICollectionView.elementKindSectionFooter:
            
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath) as! FooterBudgetCollectionView
 
            
            return footerView
            
        default:
            //4
//            assert(false, "Unexpected element kind")
            fatalError("Unexpected element kind")
        }
        
        
    }
    
    
    //MARK: HIDE ADD BUDGET BUTTON IF EMPTY
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if budgetNameG.count == 0 {
            return CGSize.zero
        } else {
        
        return CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.08)
        }

    }
    
    //MARK: COLLECTION CELLS
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BudgetCollectionViewCell
        let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! BudgetCollectionViewCell
        
        //Set cell border
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.cornerRadius = 8.0
        cell.contentView.layer.borderColor = UIColor.darkGray.cgColor
        emptyCell.contentView.layer.borderWidth = 1.0
        emptyCell.contentView.layer.cornerRadius = 8.0
        emptyCell.contentView.layer.borderColor = UIColor.darkGray.cgColor
        
        
        if budgetNameG.count == 0 {
            return emptyCell
        } else {
        
        
        //MARK: CELL DESIGN
        cell.backgroundColor = cellBackground
        
        //MARK: CELL VIEW LABELS
        cell.budgetNameLabel.text = budgetNameG[indexPath.row]
        cell.budgetRemainingLabel.text = "\(String(convertDoubleToCurency(amount: budgetRemainingG[indexPath.row])))"
   
        
        //MARK: PROGRESS BAR LABELS
            let selectedBudget = budgetNameG[indexPath.row]
            var amountSpentInd = budgetHistoryAmountG[selectedBudget]?.reduce(0, +)
            
            if amountSpentInd == nil {
               amountSpentInd = 0
            }
            
            cell.progressTotalLabel.text = "\(String(convertDoubleToCurency(amount: amountSpentInd!))) of \(String(convertDoubleToCurency(amount: budgetAmountG[indexPath.row]))) spent"
            
            cell.progressCircle.trackColor = colorTrackC
            
            let cellProgress = Float(amountSpentInd!/budgetAmountG[indexPath.row])
            
            if cellProgress <= 1 {
                cell.progressCircle.progressColor = colorGreenC
            } else if cellProgress > 1 {
                cell.progressCircle.progressColor = colorRedC
            }
            
            cell.progressCircle.setProgressWithAnimation(duration: 0.5, value: cellProgress)
            
            
            
            
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if budgetNameG.count == 0 {
        } else {
            myIndexG = indexPath.row
            switchView()
        }
    }
    

    func calculateTotalAvailable() {

        let array = Array(budgetHistoryAmountG.values)
        let flatArray = array.flatMap {$0}
        totalSpentAllBudgets = flatArray.reduce(0, +)
        let budgets = budgetAmountG.reduce(0, +)
        totalBudgetsAvailable = budgets - totalSpentAllBudgets
        
    
    }
    
  
    
    func calculateTotalAllocation() {
        
        totalBudgetsAllocation = budgetAmountG.reduce(0, +)
    }
    
    
    //MARK: REARRANGE BUDGETS
     func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {

        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let item = budgetNameG[sourceIndexPath.row]
        budgetNameG.remove(at: sourceIndexPath.row)
        budgetNameG.insert(item, at: destinationIndexPath.row)
        
        let item2 = budgetAmountG[sourceIndexPath.row]
        budgetAmountG.remove(at: sourceIndexPath.row)
        budgetAmountG.insert(item2, at: destinationIndexPath.row)
        
        let item3 = budgetRemainingG[sourceIndexPath.row]
        budgetRemainingG.remove(at: sourceIndexPath.row)
        budgetRemainingG.insert(item3, at: destinationIndexPath.row)

        saveToFireStore()
        
    }
   
    
    func addNewBudgetHandler(alert: UIAlertAction) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "EditBudget")
        self.present(viewController, animated: true)
    }
    
   
    //MARK: GESTURE RECOGNIZER
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer)
    {
        switch(gesture.state)
        {
            
        case .began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else
            {
                break
            }
            
            self.collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            
        case .changed:
            self.collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            
        case .ended:
            self.collectionView.endInteractiveMovement()
            
        default:
            self.collectionView.cancelInteractiveMovement()
        }
    }
   
    @objc func switchView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddSpendNav")
        self.present(viewController, animated: true)
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if roundButton.superview != nil {
            DispatchQueue.main.async {
                self.roundButton.removeFromSuperview()
                
            }
        }
    }
    
    
    //MARK: Save to FireStore
    func saveToFireStore() {
        
        if let userID = Auth.auth().currentUser?.uid {
            db.collection("budgets").document(userID).setData([
                "budgetName": budgetNameG,
                "budgetAmount": budgetAmountG,
                "budgetHistoryAmount": budgetHistoryAmountG,
                "budgetNote": budgetNoteG,
                "budgetHistoryDate": budgetHistoryDateG,
                "budgetHistoryTime": budgetHistoryTimeG,
                "budgetRemaining": budgetRemainingG,
                "subscribedUser": subscribedUser
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    self.calculateTotalAvailable()
                }
            }
        }
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
                        print("BudgetsVC Document data was empty.")
                        return
                    }
                    budgetNameG = document.get("budgetName") as! [String]
                    budgetAmountG = document.get("budgetAmount") as! [Double]
                    budgetHistoryAmountG = document.get("budgetHistoryAmount") as! [String : [Double]]
                    budgetNoteG = document.get("budgetNote") as! [String : [String]]
                    budgetHistoryDateG = document.get("budgetHistoryDate") as! [String : [String]]
                    budgetHistoryTimeG = document.get("budgetHistoryTime") as! [String : [String]]
                    budgetRemainingG = document.get("budgetRemaining") as! [Double]
                    subscribedUser = document.get("subscribedUser") as! Bool
                    
                    self.collectionView.reloadData()
                    self.calculateTotalAvailable()
                    self.calculateTotalAllocation()
                    
            }
        }
        
        
    }
    
  
    
    @objc func loadList() {
        cleanData()
        calculateTotalAvailable()
        calculateTotalAllocation()
        self.collectionView.reloadData()
    }
    
    func cleanData() {
        budgetNameG.removeAll()
        budgetAmountG.removeAll()
        budgetHistoryAmountG.removeAll()
        budgetNoteG.removeAll()
        budgetHistoryDateG.removeAll()
        budgetHistoryTimeG.removeAll()
        budgetRemainingG.removeAll()
    }
    
   
    
//    func receiptValidation() {
//        let SUBSCRIPTION_SECRET = "yourpasswordift"
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
//            let requestDictionary = ["receipt-data":base64encodedReceipt!,"9508e678719b4253bc6c7ae9fb430df1":SUBSCRIPTION_SECRET]
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
    
    func timeToResetAlert() {
        //Get date
        let date = Date()
        let calendar = Calendar.current
        let month = String(calendar.component(.month, from: date))
        let year = String(calendar.component(.year, from: date))
        var formattedMonth = String()
        
        //Get user defaults
        monthlyResetSetting = defaults.bool(forKey: "MonthlyResetSetting")
        monthlyResetLastMonth = defaults.integer(forKey: "MonthlyResetLastMonth")
        print("MonthlyResetLastMonth: \(monthlyResetLastMonth)")
        
        //Determine if alert should be shown
        var shouldShowMonthlyResetAlert = Bool()
        
        if month.count == 1 {
            formattedMonth = "0\(month)"
        } else {
            formattedMonth = month
        }
        
        let newDate = "\(year)\(formattedMonth)"
        
        if String(monthlyResetLastMonth) < newDate {
            shouldShowMonthlyResetAlert = true
        } else {
            shouldShowMonthlyResetAlert = false
        }
        
        if monthlyResetSetting == true && shouldShowMonthlyResetAlert == true {
            showResetBudgetsAlert()
            monthlyResetLastMonth = Int(newDate)!
            defaults.set(monthlyResetLastMonth, forKey: "MonthlyResetLastMonth")
        } else {
            print("don't show reset budget alert")
        }
        
    }
    
    
    
    func showResetBudgetsAlert() {
        let alert = UIAlertController(title: "It's a new month, do you want to reset your budgets?", message: "You can always reset your budgets from the Settings page anytime.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes, go to Settings", style: UIAlertAction.Style.default, handler: { _ in
            //Go to Settings tab
            self.tabBarController?.selectedIndex = 2
            
        }))
        alert.addAction(UIAlertAction(title: "Not now", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func determineInitialScreen() {
        
    }
    
    
    

}
    
 
