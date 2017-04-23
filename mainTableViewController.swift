//
//  mainTableViewController.swift
//  Pass No Pass
//
//  Created by Adrian on 4/22/17.
//  Copyright © 2017 Adrian. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class mainTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var classTitle = [Any]()
    var gradeArray = [Double]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
//        self.tableView.backgroundColor = UIColor(rgb: 0x82f7ff).withAlphaComponent(0.5)

        fetchClassData() //doenload all user's info on classes
        
    }


    

    //table view functions
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainTableCell", for: indexPath) as! mainTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.classLabel.text = classTitle[indexPath.row] as? String
        cell.gradeLabel.text = "\(gradeArray[indexPath.row])%"
        
//        cell.gradeLabel.textColor = UIColor.white
//        cell.classLabel.textColor = UIColor.white
        cell.gradeLabel.font = UIFont.boldSystemFont(ofSize: 25)

        
        if(gradeArray[indexPath.row] > 90.0){
            cell.gradeLabel.textColor = UIColor(rgb: 0x43A047)
        }
        if(gradeArray[indexPath.row] >= 80.0 && gradeArray[indexPath.row] < 90.0){
            cell.gradeLabel.textColor = UIColor(rgb: 0xFFC400)
        }
        if(gradeArray[indexPath.row] >= 70.0 && gradeArray[indexPath.row] < 80.0){
            cell.gradeLabel.textColor = UIColor(rgb: 0x673AB7)
        }
        if(gradeArray[indexPath.row] < 70.0){
            cell.backgroundColor = UIColor(rgb: 0xD32F2F).withAlphaComponent(0.7)
            cell.classLabel.textColor = UIColor.white
            cell.gradeLabel.textColor = UIColor.white
        }
        
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.classTitle.count > 0 {
            return classTitle.count
        } else {
            return 0
        }
    }
    
    func fetchClassData(){
        if let user = FIRAuth.auth()?.currentUser {
            let classRef = FIRDatabase.database().reference().child("Users").child(user.uid).child("Classes")
            classRef.observe(.value, with: {(snapshot) in
                
                self.classTitle.removeAll() //emptty an array
                self.gradeArray.removeAll()
                
                //get all keys
                if let myClass = snapshot.value as? NSDictionary {
                    self.classTitle = myClass.allKeys
                }//end if
                
                
                if let snapDict = snapshot.value as? NSDictionary{
                    for i in 0..<self.classTitle.count {
                        let item = snapDict[self.classTitle[i]]! as? NSDictionary
                        if let itemGrade = item?["totalScoredEarned"]{
                            self.gradeArray.append(itemGrade as! Double)
//                            print("sample  -> ",(itemGrade))
                        }//end if
                    }//end for
                }//end if
                
                self.tableView.reloadData()
                
            })//end observe
        }
    }
    
    
    var titleDataToPass:String!
    var currentGradeDataToPass:Double!
    // get selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        titleDataToPass = classTitle[indexPath.row] as? String
        currentGradeDataToPass = gradeArray[indexPath.row] as? Double
        performSegue(withIdentifier: "mainToPossible", sender: self)

    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "mainToPossible") {
            // initialize new view controller and cast it as your view controller
            guard let destVC = segue.destination as? detailViewController else {return}
            if let dataToPass = titleDataToPass {
                destVC.classTitle = dataToPass
            }
            if let gradeDataToPass = currentGradeDataToPass {
                destVC.currentGrade = gradeDataToPass
            }

            

            
        }
    }//end prepare

}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

