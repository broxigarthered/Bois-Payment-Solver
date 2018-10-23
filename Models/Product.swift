//
//  Product.swift
//  Bois Payment Solver
//
//  Created by Adelina Dutskinova on 13/10/2018.
//  Copyright © 2018 Adelina Dutskinova. All rights reserved.
//

import Foundation
import UIKit

class Product: NSObject, NSCoding{
  func encode(with aCoder: NSCoder) {
    aCoder.encode(self.name, forKey: "name")
    aCoder.encode(self.buyer, forKey: "buyer")
    aCoder.encode(self.price, forKey: "price")
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    
    guard let name = aDecoder.decodeObject(forKey: "name") as? String,
      let price = aDecoder.decodeObject(forKey: "price") as? Decimal,
      let buyer = aDecoder.decodeObject(forKey: "buyer") as? String
      else { return nil }
    
    self.init(name: name, price: price, buyerName: buyer)
  }
  
  
  var name: String = ""
  var price: Decimal = 0
  var buyer: String = ""
  
  init(name: String, price: Decimal, buyerName buyer: String) {
    self.name = name
    self.price = price
    self.buyer = buyer
  }
  
  static func == (lhs: Product, rhs: Product) -> Bool {
    return lhs.name == rhs.name
  }
  
  // Have to override the NSObject's isEqual, so it gets recognized by .contains
  override func isEqual(_ object: Any?) -> Bool {
    guard let otherObject = object as? Product else { return false }
    print(self.name == otherObject.name)
    return self.name == otherObject.name
  }
  
}

