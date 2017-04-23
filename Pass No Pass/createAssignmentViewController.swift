//
//  createAssignmentViewController.swift
//  Pass No Pass
//
//  Created by Adrian on 4/22/17.
//  Copyright © 2017 Adrian. All rights reserved.
//

import UIKit
import SCLAlertView
import FirebaseDatabase
import FirebaseAuth

class createAssignmentViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    let rootRef = FIRDatabase.database().reference()
    
    var classTitle: String = ""
    var itemTitle = [String]() //empty array to store assignment title
    var itemPoint = [Double]()     //empty array to store assignment points
    var maxPoint = [Double]()     //empty array to store assignment maximum points
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        self.navigationItem.title = classTitle
        doneBtn.isEnabled = false
        
        fetchClassData()
        
        self.tableView.reloadData()
    }
    
        //table view functions
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as! contentTableViewCell
            cell.itemTItle.text = itemTitle[indexPath.row]
            cell.itemScore.text = String(itemPoint[indexPath.row])
            cell.itemMaxScore.text = String(maxPoint[indexPath.row])
            return cell
        }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if itemTitle.count > 0 {
            return itemTitle.count
        } else {
            return 0
        }
    }
    
    //add new item for current class
    @IBAction func addItemAction(_ sender: Any) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )
        
        let alert = SCLAlertView(appearance: appearance)

        let title = alert.addTextField("Enter a title")
        let score = alert.addTextField("Enter a score received")
        let maxScore = alert.addTextField("Enter maximum score")
        score.keyboardType = UIKeyboardType.decimalPad
        maxScore.keyboardType = UIKeyboardType.decimalPad
        
        alert.addButton("Save") {
            guard let text1 = title.text, !text1.isEmpty else {return}
            guard let text2 = score.text, !text2.isEmpty else {return}
            guard let text3 = maxScore.text, !text3.isEmpty else {return}
            
            
            if let intText2: Double = Double(text2) {
                self.itemPoint.append(intText2)
            }
            if let intText3: Double = Double(text3) {
                self.maxPoint.append(intText3)
            }
            
            self.itemTitle.append(text1.uppercased())
            self.doneBtn.isEnabled = true
            self.tableView.reloadData()
        }
        alert.addButton("Cancel") { }
        alert.showEdit("Edit Item", subTitle: "Input an item for this class")
    }
    
    
    
    
    
    //update class data to firebase
    @IBAction func updateClass(_ sender: Any) {
        print("uploading class data")
        var totalScoreReceived = 0.0
        var totalMaxPoint = 0.0
        var result = 0.0
        
        if let user = FIRAuth.auth()?.currentUser {
            for i in 0..<itemTitle.count {
                let itemRef = rootRef.child("Users").child(user.uid).child("Classes").child(classTitle).child(itemTitle[i] )
                itemRef.child("score").setValue(itemPoint[i])
                itemRef.child("maxScore").setValue(maxPoint[i])
            }
            
            for i in 0..<itemTitle.count {
                totalScoreReceived += itemPoint[i] 
                totalMaxPoint += maxPoint[i]

                print("totalScoreReceived ", totalScoreReceived)
                print("totalMaxPoint: ", totalMaxPoint)
                
                result = (totalScoreReceived / totalMaxPoint) * 100
                result = Double(result).roundTo(places: 2)  // round off double to 2 decimal digits
            }
            
            rootRef.child("Users").child(user.uid).child("Classes").child(classTitle).child("totalScoredEarned").setValue(result)
            
            //MODALLY SEGUE TO MAIN SCREEN
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "navController") as! UINavigationController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    // download user's data if possible
    func fetchClassData(){
        if let user = FIRAuth.auth()?.currentUser {
            let classRef = FIRDatabase.database().reference().child("Users").child(user.uid).child("Classes").child(classTitle)
            
            classRef.observeSingleEvent(of: .value, with: { (snapshot) in
                // ...
                self.itemTitle.removeAll()
                self.itemPoint.removeAll()
                self.maxPoint.removeAll()
                
                if let snapDict = snapshot.value as? NSDictionary{
                    print("\n\nsnapDict: ", snapDict)
                    print("snapDict: ", snapDict.count)
                    
                    //get all keys
                    self.itemTitle = snapDict.allKeys as! [String]
                    self.itemTitle.remove(at: self.itemTitle.index(of: "totalScoredEarned")!)
                    
                    print("itemTitle -> ", self.itemTitle)
                    
                    
                    for i in 0..<(snapDict.count - 1) {
                        if let item = snapDict[self.itemTitle[i]] as? NSDictionary {
                            print("item -> ", item["score"]!)
                            print("maxScore item -> ", item["maxScore"]!)
                            self.itemPoint.append(item["score"]! as! Double)
                            self.maxPoint.append(item["maxScore"]! as! Double)
                        }
                    }//end for
                }//end if
                
                self.tableView.reloadData()

            }) { (error) in
                print(error.localizedDescription)
            }
        }// end if
        
    }//end fetch class data


}

