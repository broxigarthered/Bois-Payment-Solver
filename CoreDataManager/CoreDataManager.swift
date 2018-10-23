//
//  CoreDataManager.swift
//  Bois Payment Solver
//
//  Created by Adelina Dutskinova on 06/10/2018.
//  Copyright © 2018 Adelina Dutskinova. All rights reserved.
//

import Foundation
import CoreData
import UIKit
class CoreDataManager {
  
  
  static let sharedManager = CoreDataManager()
  //2.
  private init() {} // Prevent clients from creating another instance.
  
  //3
  lazy var persistentContainer: NSPersistentContainer = {
    
    let container = NSPersistentContainer(name: "Bois_Payment_Solver")
    
    
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  //4
  func saveContext () {
    let context = CoreDataManager.sharedManager.persistentContainer.viewContext
    
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  //MARK: Shop managamenet funcitons
  func insertShop(shopName:String) -> Shop?{
    let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
    
    let entity = NSEntityDescription.entity(forEntityName: "Shop",
                                            in: managedContext)!
    let newShop = NSManagedObject(entity: entity,
                                  insertInto: managedContext)
    
    newShop.setValue(shopName, forKeyPath: "name")
    
    do {
      try managedContext.save()
      return newShop as? Shop
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
      return nil
    }
  }
  
  func loadShops() -> [Shop]? {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Shop")
    request.returnsObjectsAsFaults = false
    do {
      guard let result = try self.persistentContainer.viewContext.fetch(request) as? [Shop] else { return nil }
      return result
      
    } catch {
      print("Failed")
    }
    
    return nil
  }
  
  // MARK: - Products methods
  func insertNewProductToShop(shop: Shop, product: ProductMO){
    if !shop.mutableSetValue(forKey: "products").contains(product) {
      shop.mutableSetValue(forKey: "products").add(product)
      self.saveContext()
    }
  }
  
  func insertProduct(name: String, quantity: String, price: Decimal, boisPrice:[String:Double]) -> ProductMO? {
    let context = CoreDataManager.sharedManager.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
    let product = NSManagedObject(entity: entity!, insertInto: context)
    
    product.setValue(Decimal(string: quantity), forKey: "quantity")
    product.setValue(name, forKey: "name")
    product.setValue(price, forKey: "price")
    product.setValue(boisPrice, forKey: "bois")
    
    do {
      try context.save()
      return product as? ProductMO
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
      return nil
    }
  }
  
  func updateProduct(product: ProductMO, name: String, price: Decimal, quantity: String, boisPrice: [String:Double]) {
    product.setValue(Decimal(string: quantity), forKey: "quantity")
    product.setValue(name, forKey: "name")
    product.setValue(price, forKey: "price")
    product.setValue(boisPrice, forKey: "bois")
    self.saveContext()
  }
  
  func loadAllProducts() -> [ProductMO]? {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
    request.returnsObjectsAsFaults = false
    do {
      guard let result = try self.persistentContainer.viewContext.fetch(request) as? [ProductMO] else { return nil }
      return result
      
    } catch {
      print("Failed")
    }
    
    return nil
  }
  
  
  //MARK: Bois functions - insert/update/delete
  
  
  // MARK: General method for boi insertion and also inserting products in boi's shop's products list (as dictionary).
  // Creates new boi if it doesn't exists and manages the dictionary
  func updateBoiModel(boiName: String, productName: String, productPrice: Decimal, shopName: String) {
    let (boiExists, boiObject) = boiExistsInContext(boiName: boiName)
    
    let newProduct = Product(name: productName, price: productPrice, buyerName: shopName)
    
    if(!boiExists){
      let boi = saveNewBoiInContext(entityName: "Boi")
      boi.name = boiName
      
      if(boi.value(forKey: "products") == nil){
        boi.setValue([String: [Product]](), forKey: "products")
      }
      
      insertNewProductInBoi(boi: boi, newProduct: newProduct, shopName: shopName)
      printBoisShopsAndProducts(boi: boi)
    }
    else{ // update boi
      guard let boi = boiObject else {return}
      
      insertNewProductInBoi(boi: boi, newProduct: newProduct, shopName: shopName)
      printBoisShopsAndProducts(boi: boi)
    }
    
    self.saveContext()
  }
  
  private func saveNewBoiInContext(entityName: String) -> BoiMO {
    let context = self.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
    let boi = NSManagedObject(entity: entity!, insertInto: context) as! BoiMO
    return boi
  }
  
  private func insertNewProductInBoi(boi: BoiMO, newProduct: Product, shopName:String) {
    var shopProductsDictionary = boi.value(forKey: "products") as! [String: [Product]]
    
    if(shopProductsDictionary[shopName] == nil){
      shopProductsDictionary[shopName] = [Product]()
    }
    
    if(!(shopProductsDictionary[shopName]?.contains(newProduct))!){
      shopProductsDictionary[shopName]?.append(newProduct)
    }
    else {
      // set the new products price
      shopProductsDictionary[shopName]?.first(where: { (p: Product) -> Bool in
        p.name == newProduct.name
      })?.price = newProduct.price
    }
    
    // TODO: Might bug here and always add values instead of
    //addBoiMoneyTotalPriceOwed(boi: boi, price: newProduct.price)
    
    boi.setValue(shopProductsDictionary, forKey: "products")
  }
  
  private func addBoiMoneyTotalPriceOwed(boi: BoiMO, price: Decimal){
    if var currentTotalMoney = boi.totapPriceOwed?.decimalValue {
      currentTotalMoney = currentTotalMoney + price
      boi.totapPriceOwed = currentTotalMoney as NSDecimalNumber
      
    }
  }
  
  private func substractBoiMoneyTotalPriceOwed(boi: BoiMO, price: Decimal){
    if var currentTotalMoney = boi.totapPriceOwed?.decimalValue {
      currentTotalMoney = currentTotalMoney - price
      boi.totapPriceOwed = currentTotalMoney as NSDecimalNumber
      print(boi.totapPriceOwed)
    }
  }
  
  
  /* MARK: Removes product from specific shop in one boi.
   Calls additional private method, removeProductFromBoiDictionary.
   The method gets the [Product] and filters it so the specific product is removed.
   Then returns the dictionary as value copy with the removed product. After that in removeProductFromBoi we set the new dictionary.
   Save context is called after Add is called.
   */
  func removeProductFromBoi(productName: String, shopName: String, boiName: String) -> String {
    if let boi = self.getBoi(boiName: boiName){
      if let newProductsList = self.removeProductFromBoiDictionary(productName: productName, shopName: shopName, boi: boi) {
        
        boi.setValue(newProductsList, forKey: "products")
        return productName
      }
    }
    
    return "Nothing inserted"
  }
  
  private func removeProductFromBoiDictionary(productName: String, shopName: String, boi: BoiMO) -> [String: [Product]]?{
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
  
  /*
   TODO:
   1. Should create bois service layer to hand all of the methods for BoiMO
   2. Should create a method for removing a product in one's boy shop, upon deselecting a cell in the NewProductVC
   2.1 Check if the boi exists
   2.1.1 If the boi exists, get his value for products
   2.1.2 Check if the product exists, if it does, remove it
   2.1.3 Save context
   */
  
  // Method for calculating the total money owed by one boi
  func getBoiOwedMoney(boiName: String) -> String {
    if let boi = self.getBoi(boiName: boiName){
      for shopsProducts in boi.products as! [String: [Product]]
      {
        
      }
    }
    
    return ""
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
  private func boiExistsInContext(boiName: String) -> (Bool,BoiMO?){
    if let fetchedBoi = self.getBoi(boiName: boiName){
      return (true, fetchedBoi)
    }
    
    return (false, nil)
  }
  
  // Method for fetching all existing bois in the database
  func loadAllBois() -> [BoiMO]? {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Boi")
    request.returnsObjectsAsFaults = false
    do {
      guard let result = try self.persistentContainer.viewContext.fetch(request) as? [BoiMO] else { return nil }
      return result
      
    } catch {
      print("Failed")
    }
    
    return nil
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
}
