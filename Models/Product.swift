//
//  Product.swift
//  Bois Payment Solver
//
//  Created by Adelina Dutskinova on 13/10/2018.
//  Copyright © 2018 Adelina Dutskinova. All rights reserved.
//

import Foundation
import UIKit

class Product{
    var name: String = ""
    var price: Decimal = 0
    var buyer: String = ""
    
    init(name: String, price: Decimal, buyerName buyer: String) {
        self.name = name
        self.price = price
        self.buyer = buyer
    }
}

