//
//  detailTableViewController.swift
//  Pass No Pass
//
//  Created by Adrian on 4/22/17.
//  Copyright © 2017 Adrian. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class detailViewController: UIViewController {

    var classTitle: String = ""
    var currentGrade: Double = 0.0
    @IBOutlet weak var gradeLabel: UILabel!
    
    @IBOutlet weak var fureAssignField: UITextField!
    var itemTitle = [String]() //empty array to store assignment title
    @IBOutlet weak var aLabel: UILabel!
    @IBOutlet weak var bLabel: UILabel!
    @IBOutlet weak var cLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = classTitle
        self.gradeLabel.text = "\(currentGrade)%"
        fureAssignField.keyboardType = UIKeyboardType.decimalPad
        fetchClassData()
        textFieldCheck()
    }
    
    
    //editing textfield
    @IBAction func editFieldAction(_ sender: Any) {
        
        textFieldCheck()
        
        
        // user has more fure assignment
        if let futureAssignCount = Int(fureAssignField.text!) {
            
            let currentAssignCount: Double = Double(itemTitle.count)
            let totalAssignCount: Double = Double(currentAssignCount) + Double(futureAssignCount)
            
            print(futureAssignCount)
            print(currentAssignCount)
            print(totalAssignCount)
            
            
//            var result: Double = ((90.0 * Double(futureAssignCount)) / (90.0 * Double(totalAssignCount) - Double(currentGrade) * Double(currentAssignCount))) * 100
            var result: Double = 90.0 * totalAssignCount
                result = result - Double(currentGrade) * Double(currentAssignCount)
                result = result / Double(futureAssignCount)
                result = Double(result).roundTo(places: 2)  // round off double to 2 decimal digits

            print("result -> ", result)
            
//            if(result >= 90.0){
//                aLabel.text = "\(result)%"
//                bLabel.text = "100%"
//                cLabel.text = "100%"
//            } else if(result >= 80.0 && result < 90.0){
//                aLabel.text = "0%"
//                bLabel.text = "\(result)%"
//                cLabel.text = "100%"
//            }  else if(result >= 70.0 && result < 80.0){
//                aLabel.text = "0%"
//                bLabel.text = "0%"
//                cLabel.text = "\(result)%"
//            } else if(result < 70.0){
//                aLabel.text = "0%"
//                bLabel.text = "0%"
//                cLabel.text = "0%"
//            }
            
            if(currentGrade >= 90.0){
//                aLabel.text = "\(result)%"
//                bLabel.text = "100%"
//                cLabel.text = "100%"
            } else if(currentGrade >= 80.0 && result < 90.0){
//                aLabel.text = "0%"
//                bLabel.text = "\(result)%"
//                cLabel.text = "100%"
            }  else if(currentGrade >= 70.0 && result < 80.0){
//                aLabel.text = "0%"
//                bLabel.text = "0%"
//                cLabel.text = "\(result)%"
            } else if(currentGrade < 70.0){
//                aLabel.text = "0%"
//                bLabel.text = "0%"
//                cLabel.text = "0%"
            }


            
            
        }
    }
    
    // download user's data if possible
    func fetchClassData(){
        if let user = FIRAuth.auth()?.currentUser {
            let classRef = FIRDatabase.database().reference().child("Users").child(user.uid).child("Classes").child(classTitle)
            
            classRef.observeSingleEvent(of: .value, with: { (snapshot) in
                self.itemTitle.removeAll()
                if let snapDict = snapshot.value as? NSDictionary{
                    //get all keys
                    self.itemTitle = snapDict.allKeys as! [String]
                    self.itemTitle.remove(at: self.itemTitle.index(of: "totalScoredEarned")!)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }// end if
        
    }//end fetch class data

    
    func textFieldCheck(){
        if(fureAssignField.text == ""){
            // user has no more future assignment
            if(currentGrade >= 90.0){
                aLabel.text = "100%"
                bLabel.text = "100%"
                cLabel.text = "100%"
            } else if(currentGrade >= 80.0 && currentGrade < 90.0){
                aLabel.text = "0%"
                bLabel.text = "100%"
                cLabel.text = "100%"
            }  else if(currentGrade >= 70.0 && currentGrade < 80.0){
                aLabel.text = "0%"
                bLabel.text = "0%"
                cLabel.text = "100%"
            } else if(currentGrade < 70.0){
                aLabel.text = "0%"
                bLabel.text = "0%"
                cLabel.text = "0%"
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "possibleToAssign") {
            // initialize new view controller and cast it as your view controller
            guard let destVC = segue.destination as? createAssignmentViewController else {return}
            destVC.classTitle = classTitle
        }
    }//end prepare

    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
    }

}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

