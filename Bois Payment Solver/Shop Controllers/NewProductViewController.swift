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
  func addNewProductToShop(product :NSManagedObject, isEditingProduct: Bool)
}

class NewProductViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
  
  var delegate: NewProductDelegate?
  
  var product: NSManagedObject?
  var shopName: String = ""
  var shopPayer: String = ""
  
  @IBOutlet weak var productNameLabel: UILabel!
  @IBOutlet weak var productNameField: UITextField!
  @IBOutlet weak var priceField: UITextField!
  @IBOutlet weak var quantityField: UITextField!
  @IBOutlet weak var boisTableView: UITableView!
  
  var boisPrice: [String: Double] = [:]
  var boiNames:[String] = ["Vasil", "Niki", "Alex", "Iliq", "Toni", "Mitko", "Simo"]
  private var isEditingProduct: Bool = false
  
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
    
    let boiName = Array(self.boisPrice.keys)[indexPath.row]
    cell.boiName.text = boiName
    
    if let boiMoney = self.boisPrice[boiName]{
      cell.boiMoney.text = String(boiMoney)
      if(boiMoney != 0){
        cell.accessoryType = .checkmark
        // Selects the rows that are being used
        self.boisTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
      } else {
        cell.accessoryType = .none
      }
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    guard let selectedCellsCount = boisTableView.indexPathsForSelectedRows?.count else {return}
    let selectedBoi = tableView.cellForRow(at: indexPath) as! BoisTRCell
    selectedBoi.accessoryType = .checkmark
    let boiName = selectedBoi.boiName.text
    
    setPriceForCellSelection(cell: selectedBoi, selectedCellsCount: selectedCellsCount, boiName: boiName!)
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    
    let selectedBoi = tableView.cellForRow(at: indexPath) as! BoisTRCell
    let boiName = selectedBoi.boiName.text
    let productName = (self.product as? ProductMO)?.name
    
    selectedBoi.accessoryType = .none
    guard let selectedCellsCount = boisTableView.indexPathsForSelectedRows?.count else {return}
    setPriceForCellDeSelection(cell: selectedBoi, selectedCellsCount: selectedCellsCount, boiName: boiName!)
    
    // Call CoreDataManager -> removeProductFromBoi -> context will be saved upon pressing save
    // removeProductFromBoi will find the product in the Shop:List<Products> dictionary and remove it
    if let boi = boiName, let product = productName {
      let removedProduct = CoreDataManager.sharedManager.removeProductFromBoi(productName: product, shopName: shopName, boiName: boi)
      print(removedProduct)
      
      // TODO: change the price of the other left bois entities
    }
  }
  
  @IBAction func saveInContext(_ sender: Any) {
    let (name, quantity, price) = self.checkFieldsProperties()
    
    // check if the object is being in edited or not
    if(self.isEditingProduct){
      if let prod = self.product as? ProductMO{
        //print(boisPrice)
        CoreDataManager.sharedManager.updateProduct(product: prod, name: name, price: price, quantity: quantity, boisPrice: boisPrice)
        guard let del = delegate else { return }
        del.addNewProductToShop(product: prod, isEditingProduct: self.isEditingProduct)
      }
    }
    else {
      // set properties
      let newProduct = CoreDataManager.sharedManager.insertProduct(name: name, quantity: quantity, price: price, boisPrice: self.boisPrice, shopPayer: self.shopPayer)
      self.productNameLabel.text = name
      
      // call the delegate, so we pass the product to the shop and update the tableview
      guard let del = delegate, let product = newProduct else { return }
      del.addNewProductToShop(product: product, isEditingProduct: self.isEditingProduct)
    }
    
    //TODO: for every key-value in boisPrice, call CoreDataManager insertBoi (later on will create update method)
    for b in boisPrice where b.value != 0 {
      CoreDataManager.sharedManager.updateBoiModel(boiName: b.key, productName: name, productPrice: Decimal(b.value), shopName: self.shopName, shopBuyer: self.shopPayer)
    }
    
    
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func dismiss(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Navigation
  
  // MARK: - Additional Methods
  
  func initBoisPrice() {
    self.boisPrice["Vasil"] = 0
    self.boisPrice["Niki"] = 0
    self.boisPrice["Alex"] = 0
    self.boisPrice["Iliq"] = 0
    self.boisPrice["Toni"] = 0
    self.boisPrice["Mitko"] = 0
    self.boisPrice["Simo"] = 0
  }
  
  func checkFieldsProperties() -> (String, String, Decimal){
    guard let quantity = self.quantityField.text,
      let name = self.productNameField.text,
      let priceFieldText = self.priceField.text,
      let price = Decimal(string: priceFieldText),
      quantity != "", priceFieldText != "", name != "" else {return ("", "", 0)}
    return (name, quantity, price)
  }
  
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
  
  func entityFoundation(object: NSManagedObject, shopName: String){
    // set current object to the given object (product)
    self.product = object
    self.isEditingProduct = true
    self.shopName = shopName
  }
  
  func setPriceForCellDeSelection(cell: BoisTRCell, selectedCellsCount: Int, boiName: String)  {
    guard let priceText = priceField.text,
      let price = Double(priceText), price > 0
      else {return}
    
    let finalPrice = (price / Double(selectedCellsCount)).rounded(toPlaces: 2)
    self.boisPrice[boiName] = finalPrice
    cell.boiMoney.text = String(finalPrice)
    
    for boiPath in boisTableView.indexPathsForSelectedRows! {
      let cell = self.boisTableView.cellForRow(at: boiPath) as! BoisTRCell
      self.boisPrice[cell.boiName.text!] = finalPrice
      cell.boiMoney.text = String(finalPrice)
    }
    
    self.boisPrice[cell.boiName.text!] = 0
    cell.boiMoney.text = String(0)
  }
  
  func setPriceForCellSelection(cell: BoisTRCell, selectedCellsCount: Int, boiName: String)  {
    guard let priceText = priceField.text,
      let price = Double(priceText), price > 0
      else {return}
    
    let finalPrice = (price / Double(selectedCellsCount)).rounded(toPlaces: 2)
    self.boisPrice[boiName] = finalPrice
    cell.boiMoney.text = String(finalPrice)
    
    // for every selected cell, set it's price to the new price
    for boiPath in boisTableView.indexPathsForSelectedRows! {
      let cell = self.boisTableView.cellForRow(at: boiPath) as! BoisTRCell
      self.boisPrice[cell.boiName.text!] = finalPrice
      cell.boiMoney.text = String(finalPrice)
    }
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
