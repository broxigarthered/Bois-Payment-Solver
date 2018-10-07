//
//  BoisTRCell.swift
//  Bois Payment Solver
//
//  Created by Adelina Dutskinova on 13.09.18.
//  Copyright © 2018 Adelina Dutskinova. All rights reserved.
//

import UIKit

class BoisTRCell: UITableViewCell {

    @IBOutlet weak var boiName: UILabel!
    @IBOutlet weak var boiMoney: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
