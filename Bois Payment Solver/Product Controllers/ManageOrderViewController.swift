//
//  ManageOrderViewController.swift
//  Bois Payment Solver
//
//  Created by Adelina Dutskinova on 12.09.18.
//  Copyright © 2018 Adelina Dutskinova. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class ManageOrderViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, NewProductDelegate {
    
    var shop : NSManagedObject?
    var products: [ProductMO] = []
    
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var shopSum: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAllProducts()
        
        // set the delegate and the datasource so we can modify the tableview from the view controller
        productTableView.delegate = self
        productTableView.dataSource = self
        
        self.shopName.text = self.shop?.value(forKey: "name") as! String
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Tableview data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // TODO:
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell") as! ProductCell
        
        if(indexPath.row == 0){
            cell.productName.isHidden = true
            cell.productPrice.isHidden = true
            cell.newProductLabel.isHidden = false
        } else {
            
            let currentProduct = self.products[indexPath.row-1]
            
            cell.productName.isHidden = false
            cell.productPrice.isHidden = false
            cell.newProductLabel.isHidden = true
            if let productName = currentProduct.value(forKey: "name"){
                cell.productName.text = productName as? String
            }
            
            if let price = currentProduct.value(forKey: "price"){
                cell.productPrice.text = String(describing: price)
                
                if let currentSum = Decimal(string: self.shopSum.text!){
                    if let cellPrice = Decimal(string: cell.productPrice.text!){
                        var value = currentSum + cellPrice
                        self.shopSum.text = String(describing: value)
                    }
                }
                
                
                
            }
        }
        
        return cell
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addNewProduct"){
            if let indexPath = productTableView.indexPathForSelectedRow {
                
                if let destinationController =  segue.destination as? NewProductViewController{
                    destinationController.delegate = self
                    
                    
                    if(indexPath.row != 0){
                        // give the destinationController the information of the product
                        // setProduct(product)
                        self.shop?.mutableSetValue(forKey: "products").remove(products[indexPath.row-1])
                        destinationController.entityFoundation(object: products[indexPath.row-1])
                        
                    }
                        // get it as a new product
                    else{
                        
                    }
                    
                    self.present(destinationController, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    // MARK: - IBActions
    @IBAction func backToPreviousController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Delegate
    func addNewProductToShop(product: NSManagedObject) {
        if let shop = self.shop as? Shop{
            if let product = product as? ProductMO{
                CoreDataManager.sharedManager.insertNewProductToShop(shop: shop, product: product)
                self.products.append(product)
                self.productTableView.reloadData()
            }
        }
    }
    
    // MARK: - Additional
    func setShopValue(value: Shop?){
        if let val = value{
            self.shop = value;
        }
    }
    
    func loadAllProducts(){
        if let s = self.shop?.mutableSetValue(forKey: "products") {
            self.products = Array(s.allObjects) as! [ProductMO]
        }
    }
}
