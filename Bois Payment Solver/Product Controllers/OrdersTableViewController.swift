//
//  OrdersTableViewController.swift
//  Bois Payment Solver
//
//  Created by Adelina Dutskinova on 12.09.18.
//  Copyright © 2018 Adelina Dutskinova. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class OrdersTableViewController: UITableViewController,  NSFetchedResultsControllerDelegate, UpdateShopListDelegate{
    
    var shopList : [Shop] = []
    var indexPathRow : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let shops = self.loadShopsFromDB(){
            self.shopList = shops
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderCell
        
        if(indexPath.row == 0){
            cell.orderName.text = "Create new order"
            cell.selectionStyle = .none
            
        } else {
            cell.orderName.text = self.shopList[indexPath.row-1].value(forKey: "name") as! String
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row != 0){
            indexPathRow = indexPath.row
            performSegue(withIdentifier: "shopInformation", sender: nil)
        } else {
            performSegue(withIdentifier: "createNewOrder", sender: nil)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.shopList.count + 1
        // 1 + every new order created
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "createNewOrder"){
            if let destinationController =  segue.destination as? NewShopViewController{
                destinationController.delegate = self
                self.present(destinationController, animated: true, completion: nil)
            }
        }
        else if(segue.identifier == "shopInformation"){
            if let destinationController = segue.destination as? ManageOrderViewController{
                if let indexPath = tableView.indexPathForSelectedRow{
                    destinationController.setShopValue(value: self.shopList[indexPath.row-1])
                    self.present(destinationController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    // MARK: Additional Methods
    
    func loadShopsFromDB() -> [Shop]? {
        if let shops = CoreDataManager.sharedManager.loadShops(){
            return shops
        }
        
        return nil
    }
    
    // MARK: Delegate
    func addNewShopToTableRow(shop: Shop?) {
        if let sh = shop{
            self.shopList.append(sh)
            self.tableView.reloadData()
        }
    }
    
}
