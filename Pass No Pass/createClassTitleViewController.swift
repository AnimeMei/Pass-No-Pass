//
//  createClassTitleViewController.swift
//  Pass No Pass
//
//  Created by Adrian on 4/22/17.
//  Copyright © 2017 Adrian. All rights reserved.
//

import UIKit

class createClassTitleViewController: UIViewController {

    @IBOutlet weak var nextBtn: UIButton!
    var classTitle: String = ""
    
    @IBOutlet weak var classField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        nextBtn.isHidden = true
        nextBtn.layer.cornerRadius = 5
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let destVC = segue.destination as? createAssignmentViewController else {
            return
        }
        destVC.classTitle = classField.text!.uppercased()
    }

    @IBAction func textFieldChanged(_ sender: Any) {
        nextBtn.isHidden = false
    }

    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
    }


}
