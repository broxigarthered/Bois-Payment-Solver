//
//  NewProductViewController.swift
//  Bois Payment Solver
//
//  Created by Adelina Dutskinova on 13.09.18.
//  Copyright © 2018 Adelina Dutskinova. All rights reserved.
//

import UIKit
import CoreData
import Foundation

protocol NewProductDelegate
{
    func addNewProductToShop(product :NSManagedObject)
}

class NewProductViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    var delegate: NewProductDelegate?
    
    var product: NSManagedObject?

    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productNameField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var boisTableView: UITableView!
    
    var boisPrice: [String: Double] = [:]
    var boiNames:[String] = ["Vasil", "Niki", "Alex", "Iliq", "Toni", "Mitko", "Simo"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boisTableView.delegate = self
        boisTableView.dataSource = self
        
        initBoisPrice()
        loadAllFieldsWithExistingInformation(product: self.product)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boisPrice.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = boisTableView.dequeueReusableCell(withIdentifier: "boisCell") as! BoisTRCell
        
        //let boiName = self.boiNames[indexPath.row]
        let boiName = Array(self.boisPrice.keys)[indexPath.row]
        cell.boiName.text = boiName
        if let boiMoney = self.boisPrice[boiName]{
            cell.boiMoney.text = String(boiMoney)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCellsCount = boisTableView.indexPathsForSelectedRows?.count
        let selectedBoi = tableView.cellForRow(at: indexPath) as! BoisTRCell
        selectedBoi.accessoryType = .checkmark
        let boiName = selectedBoi.boiName.text
        
        if let priceText = priceField.text{
            if let price = Double(priceText){
                let newPrice: Double = (price / Double(selectedCellsCount!)).rounded(toPlaces: 2)
                self.boisPrice[boiName!] = newPrice
                selectedBoi.boiMoney.text = String(newPrice)
                
                // for every selected cell, set it's price to the new price
                for boiPath in boisTableView.indexPathsForSelectedRows! {
                    let cell = tableView.cellForRow(at: boiPath) as! BoisTRCell
                    self.boisPrice[cell.boiName.text!] = newPrice
                    cell.boiMoney.text = String(newPrice)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let selectedBoi = tableView.cellForRow(at: indexPath) as! BoisTRCell
        selectedBoi.accessoryType = .none
        let selectedCellsCount = boisTableView.indexPathsForSelectedRows?.count
        
        if let priceText = priceField.text{
            if let price = Double(priceText){
                let newPrice: Double = (price / Double(selectedCellsCount!)).rounded(toPlaces: 2)
                
                for boiPath in boisTableView.indexPathsForSelectedRows! {
                    let cell = tableView.cellForRow(at: boiPath) as! BoisTRCell
                    self.boisPrice[cell.boiName.text!] = newPrice
                    cell.boiMoney.text = String(newPrice)
                }
                
                self.boisPrice[selectedBoi.boiName.text!] = 0
                selectedBoi.boiMoney.text = String(0)
            }
        }
        
        
    }
  
    func initBoisPrice() {
        self.boisPrice["Vasil"] = 0
        self.boisPrice["Niki"] = 0
        self.boisPrice["Alex"] = 0
        self.boisPrice["Iliq"] = 0
        self.boisPrice["Toni"] = 0
        self.boisPrice["Mitko"] = 0
        self.boisPrice["Simo"] = 0
    }
    
    
    @IBAction func saveInContext(_ sender: Any) {
        // if it is alredy apperant then, fix the new stuff
        // create the new entity and save it
        
//        if let currentProduct = self.product {
//            let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
//            let context = appDelegate.persistentContainer.viewContext
//            let entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
//
//
//            let newProduct = NSManagedObject(entity: entity!, insertInto: context)
//
//        }

            let context = CoreDataManager.sharedManager.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
            let newProduct = NSManagedObject(entity: entity!, insertInto: context)
            
            // set properties
            if let quantity = self.quantityField.text{
                if(quantity != ""){
                    newProduct.setValue(Decimal(string: quantity), forKey: "quantity")
                }
            }
            if let name = self.productNameField.text {
                if(name != ""){
                    newProduct.setValue(name, forKey: "name")
                    self.productNameLabel.text = name
                }
            }
            if let priceTextField = self.priceField.text{
                if let price = Decimal(string: priceTextField){
                    if(priceTextField != ""){
                      newProduct.setValue(price, forKey: "price")
                    }
                }
            }
            newProduct.setValue(self.boisPrice, forKey: "bois")
            
            // call the delegate, so we pass the product to the shop
            if let dl = delegate{
                dl.addNewProductToShop(product: newProduct)
            }
            
            do{
                try context.save()
            } catch {
                print("failed saving")
            }
            
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    

    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - Additional Methods
    
    func loadAllFieldsWithExistingInformation(product: NSManagedObject?){
        if let product = self.product{
            if let quantity = product.value(forKey: "quantity"){
                self.quantityField.text = String(describing: quantity)
            }
            if let name = product.value(forKey: "name"){
                self.productNameLabel.text = name as? String
                self.productNameField.text = name as? String
            }
            if let price = product.value(forKey: "price"){
                self.priceField.text = String(describing: price)
            }
            if let bois = product.value(forKey: "bois"){
                self.boisPrice = bois as! [String:Double]
            }
        }
    }
    
    func entityFoundation(object: NSManagedObject){
        // set current object to the given object
        self.product = object
        print(self.product?.value(forKey: "name"))
        
    }

}


// MARK: - Extensions
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
