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
    
    //1
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
    
    
    // Shop managamenet funcitons
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
        }
    }
    
    
}
