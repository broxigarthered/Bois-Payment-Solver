//
//  BoiShopTableViewCell.swift
//  Bois Payment Solver
//
//  Created by Adelina Dutskinova on 14.09.18.
//  Copyright © 2018 Adelina Dutskinova. All rights reserved.
//

import UIKit

class BoiShopTableViewCell: UITableViewCell {

  @IBOutlet weak var shopNameLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
