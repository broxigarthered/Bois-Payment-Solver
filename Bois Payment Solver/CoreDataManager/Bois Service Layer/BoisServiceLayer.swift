//
//  BoisServiceLayer.swift
//  Bois Payment Solver
//
//  Created by Adelina Dutskinova on 15.10.18.
//  Copyright © 2018 Adelina Dutskinova. All rights reserved.
//

import Foundation
import CoreData

// TODO: Move all the helper methods for Bois CRUD to here
class BoisServiceLayer {
    
    static let sharedManager = BoisServiceLayer()
    
    private init(){}
  
  // Method for removing a product upon deselection in the tableview.
  func removeProductFromBoiDictionary(productName: String, shopName: String, boi: BoiMO) -> [String: [Product]]?{
    var shopProductsDictionary = boi.products as! [String: [Product]]
    if shopProductsDictionary[shopName] != nil {
      if(shopProductsDictionary[shopName]?.contains(where: { (p: Product) -> Bool in
        return p.name == productName
      }))! {
        // filter returns the array after it's been filtered
        if let products = shopProductsDictionary[shopName]?.filter({ (p:Product) -> Bool in
          return p.name != productName
        }) {
          shopProductsDictionary[shopName] = products
          return shopProductsDictionary
        }
      }
    }
    
    return nil
  }
  
  // Temporal method for printing and testing
  func printBoisShopsAndProducts(boi: BoiMO) {
    print(boi.name)
    for b in boi.products as! [String: [Product]]{
      print("- \(b.key)")
      for p in b.value{
        print("-- " + p.name + " \(p.price)")
      }
    }
  }
  
  // Checks if boi exists in context and returns true/false + the boi if it exists
  func boiExistsInContext(boiName: String) -> (Bool,BoiMO?){
    if let fetchedBoi = self.getBoi(boiName: boiName){
      return (true, fetchedBoi)
    }
    
    return (false, nil)
  }
  
  // Gets boi by it's name
  func getBoi(boiName: String) -> BoiMO? {
    let request = NSFetchRequest<BoiMO>(entityName: "Boi")
    request.returnsObjectsAsFaults = false
    request.predicate = NSPredicate(format: "name == %@", boiName)
    var results: [NSManagedObject] = []
    
    do {
      results = try CoreDataManager.sharedManager.persistentContainer.viewContext.fetch(request) as [NSManagedObject]
      if results.count > 0{
        return results[0] as? BoiMO
      }
    } catch {
      print("Failed")
    }
    
    return nil
  }
  
  
  // MARK: Depricated methods
  func substractBoiMoneyTotalPriceOwed(boi: BoiMO, price: Decimal){
    if var currentTotalMoney = boi.totapPriceOwed?.decimalValue {
      currentTotalMoney = currentTotalMoney - price
      boi.totapPriceOwed = currentTotalMoney as NSDecimalNumber
      print(boi.totapPriceOwed)
    }
  }
  
  func addBoiMoneyTotalPriceOwed(boi: BoiMO, price: Decimal){
    if var currentTotalMoney = boi.totapPriceOwed?.decimalValue {
      currentTotalMoney = currentTotalMoney + price
      boi.totapPriceOwed = currentTotalMoney as NSDecimalNumber
      
    }
  }
  
  // Method for calculating the total money owed by one boi
  func getBoiOwedMoney(boiName: String) -> String {
    if let boi = getBoi(boiName: boiName){
      for shopsProducts in boi.products as! [String: [Product]]
      {
        
      }
    }
    
    return ""
  }
}
