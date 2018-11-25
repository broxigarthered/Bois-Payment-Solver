//
//  CoreDataManager.swift
//  Bois Payment Solver
//
//  Created by Adelina Dutskinova on 06/10/2018.
//  Copyright © 2018 Adelina Dutskinova. All rights reserved.
// Core Data Manager serves as handler for all CRUD requests in the context.

import Foundation
import CoreData
import UIKit
class CoreDataManager {
  
  
  static let sharedManager = CoreDataManager()
  
  // Private init, which gurantees there is only one instance of the class
  private init() {} // Prevent clients from creating another instance.
  
  // Initialization of persistent container
  lazy var persistentContainer: NSPersistentContainer = {
    
    let container = NSPersistentContainer(name: "Bois_Payment_Solver")
    
    
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  // Method for saving all new changes in the context.
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
  
  // Method for creating new shop in the DB, returns optional Shop upon successful creation.
  func insertShop(shopName:String, payerName: String) -> Shop?{
    let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
    
    let entity = NSEntityDescription.entity(forEntityName: "Shop",
                                            in: managedContext)!
    let newShop = NSManagedObject(entity: entity,
                                  insertInto: managedContext)
    
    newShop.setValue(shopName, forKeyPath: "name")
    newShop.setValue(payerName, forKey: "payers")
    
    do {
      try managedContext.save()
      return newShop as? Shop
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
      return nil
    }
  }
  
  // Method for loading all shops via fetch request.
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
  
  // MARK: - Products functions - insert/update/delete
  
  // Method for inserting existing product to one shop.
  func insertNewProductToShop(shop: Shop, product: ProductMO){
    if !shop.mutableSetValue(forKey: "products").contains(product) {
      shop.mutableSetValue(forKey: "products").add(product)
      self.saveContext()
    }
  }
  
  // Method for creating new product. Returns ProductMO as optionol upon successful creation.
  func insertProduct(name: String, quantity: String, price: Decimal, boisPrice:[String:Double], shopPayer: String) -> ProductMO? {
    let context = CoreDataManager.sharedManager.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
    let product = NSManagedObject(entity: entity!, insertInto: context)
    
    product.setValue(Decimal(string: quantity), forKey: "quantity")
    product.setValue(name, forKey: "name")
    product.setValue(price, forKey: "price")
    product.setValue(boisPrice, forKey: "bois")
    product.setValue(shopPayer, forKey: "payer")
    
    do {
      try context.save()
      return product as? ProductMO
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
      return nil
    }
  }
  
  // Method for updating the product properties
  func updateProduct(product: ProductMO, name: String, price: Decimal, quantity: String, boisPrice: [String:Double]) {
    product.setValue(Decimal(string: quantity), forKey: "quantity")
    product.setValue(name, forKey: "name")
    product.setValue(price, forKey: "price")
    product.setValue(boisPrice, forKey: "bois")
    self.saveContext()
  }
  
  // Method for fetching all existing projects from the context.
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
  func updateBoiModel(boiName: String, productName: String, productPrice: Decimal, shopName: String, shopBuyer: String) {
    let (boiExists, boiObject) = BoisServiceLayer.sharedManager.boiExistsInContext(boiName: boiName)
    
    let newProduct = Product(name: productName, price: productPrice, buyerName: shopName)
    
    if(!boiExists){
      let boi = saveNewBoiInContext(entityName: "Boi")
      boi.name = boiName
      
      if(boi.value(forKey: "products") == nil){
        boi.setValue([String: [Product]](), forKey: "products")
      }
      
      insertNewProductInBoi(boi: boi, newProduct: newProduct, shopName: shopName)
      // BoisServiceLayer.sharedManager.printBoisShopsAndProducts(boi: boi)
    }
    else{ // update boi
      guard let boi = boiObject else {return}
      
      insertNewProductInBoi(boi: boi, newProduct: newProduct, shopName: shopName)
      // BoisServiceLayer.sharedManager.printBoisShopsAndProducts(boi: boi)
    }
    
    self.saveContext()
  }
  
  // Private helper method for saving new boi in the context.
  private func saveNewBoiInContext(entityName: String) -> BoiMO {
    let context = self.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
    let boi = NSManagedObject(entity: entity!, insertInto: context) as! BoiMO
    return boi
  }
  
  // Private helper methods for inserting new product in one boi's shop.
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
      
      print(newProduct.price)
    }
    
    // TODO: Might bug here and always add values instead of
    //addBoiMoneyTotalPriceOwed(boi: boi, price: newProduct.price)
    
    boi.setValue(shopProductsDictionary, forKey: "products")
  }
  
  
  /* MARK: Removes product from specific shop in one boi.
   Calls additional private method, removeProductFromBoiDictionary.
   The method gets the [Product] and filters it so the specific product is removed.
   Then returns the dictionary as value copy with the removed product. After that in removeProductFromBoi we set the new dictionary.
   Save context is called after Add is called.
   */
  func removeProductFromBoi(productName: String, shopName: String, boiName: String) -> String {
    if let boi = BoisServiceLayer.sharedManager.getBoi(boiName: boiName){
      if let newProductsList = BoisServiceLayer.sharedManager.removeProductFromBoiDictionary(productName: productName, shopName: shopName, boi: boi) {
        
        boi.setValue(newProductsList, forKey: "products")
        return productName
      }
    }
    
    return "Nothing inserted"
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
}
