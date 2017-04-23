//
//  contentTableViewCell.swift
//  Pass No Pass
//
//  Created by Adrian on 4/22/17.
//  Copyright © 2017 Adrian. All rights reserved.
//

import UIKit

class contentTableViewCell: UITableViewCell {
   
    @IBOutlet weak var itemTItle: UILabel!
    @IBOutlet weak var itemScore: UILabel!
    @IBOutlet weak var itemMaxScore: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
