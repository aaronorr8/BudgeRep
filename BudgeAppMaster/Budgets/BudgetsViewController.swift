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

var needToShowWelcomeScreen = true
var progressFromValueArray = [Double]()
var cellWidth = CGFloat()

class BudgetsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //        var gradientLayer: CAGradientLayer!
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
    
    
    func checkLoginStatus() {
        if currentUserG == "" {
            print("BudgetsVC: Send user to login")
            //            self.performSegue(withIdentifier: "goToLogin", sender: self)
        } else {
            print("BudgetsVC: User is logged in")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Reset view for new users. Notification is posted when new users sign up
//        NotificationCenter.default.addObserver(self, selector: #selector(combineBudgets(notification:)), name: Notification.Name("TestNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: "reload"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signoutReload), name: NSNotification.Name(rawValue: "signoutReload"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showWelcomeScreen), name: NSNotification.Name(rawValue: "showWelcomeScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(generic), name: NSNotification.Name(rawValue: "generic"), object: nil)
        
        db = Firestore.firestore()
        
        collectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom:15, right: 0)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(BudgetsViewController.handleLongGesture))
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        timeToResetAlert()
        loadUserDefaultsUserAttributes()
        
        applybackgroundColor()
        
        loadBudgetData()
        calculateTotalAvailable()
        calculateTotalAllocation()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
        
        showWelcomeScreen()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("BudgetsVC did appear")
        let amount = Double(amt/100) + Double(amt%100)/100
        self.navigationItem.title = String(convertDoubleToCurency(amount: totalBudgetsAvailable))
        
        calculateTotalAvailable()
        calculateTotalAllocation()
        
        if reloadView == true {
            loadBudgetData()
            collectionView.reloadData()
            collectionView.reloadInputViews()
            reloadView = false
            print("reloadView called")
            
        }
        
        
        
        
        
        print("Number of budgets = \(budgetNameG.count)")
    }
    
    
    @objc func combineBudgets (notification: NSNotification){
        
    }
    
    @objc func generic() {
        if showSyncInstructions == true {
            showSyncInstructions = false
            goToSyncInstructions()
        }
    }
    
    @objc func goToSyncInstructions() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "syncInstructionsNav")
        self.present(viewController, animated: true)
    }
    
    func applybackgroundColor() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [
            Colors.themeWhite.cgColor,
            Colors.themeWhite.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0,y: 0)
        gradientLayer.endPoint = CGPoint(x: 0,y: 1)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    
    func loadBudgetData() {
        if currentUserG != "" {
            print("Load data from Firebase")
            fireStoreListener()
        } else {
        print("Load data from Defaults")
        loadUserDefaultsBudgets()
    }
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
        
        cellWidth = view.frame.size.width - 20
        print("cellWidth = \(cellWidth)")
        return CGSize(width: view.frame.width - 20, height: 105.0)
       
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
            headerView.totalRemainingBudget.textColor = Colors.themeBlack
            headerView.remainingLabel.textColor = Colors.themeBlack
            headerView.summarySpentBudgetedLabel.textColor = Colors.themeBlack
            headerView.summarySpentBudgetedLabel.text = "Spent \(convertDoubleToCurency(amount: totalSpentAllBudgets)) of \(convertDoubleToCurency(amount: totalBudgetsAllocation)) budgeted"
            let percentSpent = totalSpentAllBudgets/totalBudgetsAllocation
            
            
//            if percentSpent > 1 {
//                headerView.totalProgressBar.progressColor = Colors.themeRed
//            } else if percentSpent == 1 {
//                headerView.totalProgressBar.progressColor = Colors.themeBlue
//            } else if percentSpent < 0.95 {
//                headerView.totalProgressBar.progressColor = Colors.themeGreen
//            } else {
//                headerView.totalProgressBar.progressColor = Colors.themeYellow
//            }
//            
//            headerView.totalProgressBar.trackColor = Colors.themeGray
//            headerView.totalProgressBar.setProgressWithAnimation(duration: 0.75, fromValue: 0.0, toValue: Float(percentSpent))
            
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
        
        
        if budgetNameG.count == 0 {
            emptyCell.backgroundColor = Colors.themeGray
            return emptyCell
        } else {
            
            
            //MARK: CELL DESIGN
            cell.backgroundColor = Colors.themeGray
            
            //MARK: CELL VIEW LABELS
            cell.budgetNameLabel.text = budgetNameG[indexPath.row]
            //                cell.budgetRemainingLabel.text = "\(String(convertDoubleToCurency(amount: budgetRemainingG[indexPath.row])))"
            cell.budgetRemainingLabel.text = (String(convertDoubleToCurency(amount: budgetAmountG[indexPath.row] - budgetHistoryAmountG[budgetNameG[indexPath.row]]!.reduce(0, +))))
            cell.budgetNameLabel.textColor =        Colors.themeBlack
            cell.budgetRemainingLabel.textColor =   Colors.themeBlack
            cell.progressTotalLabel.textColor =     Colors.themeBlack
            
            
            
            
            //MARK: PROGRESS BAR LABELS
            let selectedBudget = budgetNameG[indexPath.row]
            var amountSpentInd = budgetHistoryAmountG[selectedBudget]?.reduce(0, +)
            
            if amountSpentInd == nil {
                amountSpentInd = 0
            }
            
            
            cell.progressTotalLabel.text = "Spent \(String(convertDoubleToCurency(amount: amountSpentInd!))) of \(String(convertDoubleToCurency(amount: budgetAmountG[indexPath.row])))"
            
            
            let cellProgress = Float(amountSpentInd!/budgetAmountG[indexPath.row])
            let progressToValue = Float(amountSpentInd!/budgetAmountG[indexPath.row])

            if progressFromValueArray.count != budgetNameG.count {
                cell.progressContainer.setProgressWithAnimation(duration: 0.75, fromValue: 0.0, toValue: progressToValue)
            } else {
                cell.progressContainer.setProgressWithAnimation(duration: 0.75, fromValue: Float(progressFromValueArray[indexPath.row]), toValue: progressToValue)
            }
            
            //cell colors
            cell.progressContainer.trackColor = Colors.themeClear
            if cellProgress > 1 {
                cell.progressContainer.progressColor = Colors.themeRed
            } else if cellProgress == 1 {
                cell.progressContainer.progressColor = Colors.themeBlue
            } else if cellProgress < 0.95 {
                cell.progressContainer.progressColor = Colors.themeGreen
            } else {
                cell.progressContainer.progressColor = Colors.themeYellow
            }
            
            
            return cell
            
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if budgetNameG.count == 0 {
            goToAddBudget()
        } else {
            myIndexG = indexPath.row
            goToAddSpend()
        }
    }
    
    
    
    
    
    func calculateTotalAvailable() {
        let array = Array(budgetHistoryAmountG.values)
        let flatArray = array.flatMap {$0}
        totalSpentAllBudgets = flatArray.reduce(0, +)
        let budgets = budgetAmountG.reduce(0, +)
        totalBudgetsAvailable = budgets - totalSpentAllBudgets
        print("totalBudgetsAvailable: \(totalBudgetsAvailable)")
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

        save()
        
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
    
    @objc func goToAddSpend() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddSpendNav")
        self.present(viewController, animated: true)
        
    }
    
    
    @objc func goToAddBudget() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddBudgetNav")
        self.present(viewController, animated: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if roundButton.superview != nil {
            DispatchQueue.main.async {
                self.roundButton.removeFromSuperview()
                
            }
        }
        
    }
    
    //MARK: BUTTONS
    
    @IBAction func addNewBudgetButton(_ sender: Any) {
      
        if subscribedUser == true || unlimitedUser == true {
            goToAddBudget()
        } else if budgetNameG.count < freeBudgets {
            goToAddBudget()
        } else {
            self.performSegue(withIdentifier: "goToIAP", sender: self)

        }
    }
    
    
    
    
    //MARK: SAVE
    func save() {
        if subscribedUser == true && currentUserG != "" {
            saveToFireStore()
            print("Save to FireStore")
        } else {
            setUserDefaults()
            print("Save to UserDefaults")
        }
    }
    
    //MARK: Save to UserDefaults
    func setUserDefaults() {
        defaults.set(budgetNameG, forKey: "budgetNameUD")
        defaults.set(budgetAmountG, forKey: "budgetAmountUD")
        defaults.set(budgetHistoryAmountG, forKey: "budgetHistoryAmountUD")
        defaults.set(budgetHistoryDateG, forKey: "budgetHistoryDateUD")
        defaults.set(budgetHistoryTimeG, forKey: "budgetHistoryTimeUD")
        defaults.set(budgetNoteG, forKey: "budgetNoteUD")
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
                "subscribedUser": subscribedUser,
                "userID" : userID
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
                    subscribedUser = document.get("subscribedUser") as! Bool
                    
                    self.collectionView.reloadData()
                    self.calculateTotalAvailable()
                    self.calculateTotalAllocation()
                    
                }
        }
        
        
    }
    
    //MARK: Load User Defaults
    func loadUserDefaultsBudgets() {
        if defaults.value(forKey: "budgetNameUD") != nil {budgetNameG = defaults.value(forKey: "budgetNameUD") as! [String]}
        if defaults.value(forKey: "budgetAmountUD") != nil {budgetAmountG = defaults.value(forKey: "budgetAmountUD") as! [Double]}
        if defaults.value(forKey: "budgetHistoryAmountUD") != nil {budgetHistoryAmountG = defaults.value(forKey: "budgetHistoryAmountUD") as! [String : [Double]]}
        if defaults.value(forKey: "budgetHistoryDateUD") != nil {budgetHistoryDateG = defaults.value(forKey: "budgetHistoryDateUD") as! [String: [String]]}
        if defaults.value(forKey: "budgetHistoryTimeUD") != nil {budgetHistoryTimeG = defaults.value(forKey: "budgetHistoryTimeUD") as! [String: [String]]}
        if defaults.value(forKey: "budgetNoteUD") != nil {budgetNoteG = defaults.value(forKey: "budgetNoteUD") as! [String: [String]]}
        print("budgetNameG: \(budgetNameG)")
        print("budgetAmountG: \(budgetAmountG)")
        print("budgetHistoryAmountG: \(budgetHistoryAmountG)")
        print("budgetHistoryDateG: \(budgetHistoryDateG)")
        print("budgetHistoryTimeG: \(budgetHistoryTimeG)")
        print("budgetNoteG: \(budgetNoteG)")
    }
    
    func loadUserDefaultsUserAttributes() {
        if defaults.value(forKey: "SubscribedUser") != nil {subscribedUser = defaults.value(forKey: "SubscribedUser") as! Bool}
        if defaults.value(forKey: "unlimitedUser") != nil {unlimitedUser = defaults.value(forKey: "unlimitedUser") as! Bool}
        print("subscribedUser: \(subscribedUser)")
        print("unlimitedUser: \(unlimitedUser)")
    }
    
    
    
    
    @objc func reload() {
        loadBudgetData()
        calculateTotalAvailable()
        calculateTotalAllocation()
        self.collectionView.reloadData()
        print("Notification Load List")
    }
    
    @objc func signoutReload() {
        calculateTotalAvailable()
        calculateTotalAllocation()
        self.collectionView.reloadData()
        self.cleanData()
        print("Reload after signout")
    }
    
    func cleanData() {
        budgetNameG.removeAll()
        budgetAmountG.removeAll()
        budgetHistoryAmountG.removeAll()
        budgetNoteG.removeAll()
        budgetHistoryDateG.removeAll()
        budgetHistoryTimeG.removeAll()
    }
    

    
    @objc func showWelcomeScreen() {
        if currentUserG == "" && budgetNameG.count == 0 && needToShowWelcomeScreen == true {
            UIView.setAnimationsEnabled(false) //turn off animation so the welcome screen shows without sliding
            performSegue(withIdentifier: "goToWelcomeScreen", sender: self)
        }
        needToShowWelcomeScreen = false
        
    }
    
    
    
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


