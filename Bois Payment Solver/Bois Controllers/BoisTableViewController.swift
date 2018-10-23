//
//  BoisTableViewController.swift
//  Bois Payment Solver
//
//  Created by Adelina Dutskinova on 12.09.18.
//  Copyright © 2018 Adelina Dutskinova. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class BoisTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  
  var boisPrice: [String: Decimal] = [:]
  var boiNames:[String] = ["Vasil", "Niki", "Alex", "Iliq", "Toni", "Mitko", "Simo"]
  var bois: [BoiMO] = []
  
  var shopList : [NSManagedObject] = []
  var products: [NSManagedObject] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //TODO: call the bois fetching, only when changes are made to the db, using observer pattern
  
    if let loadedBois = initBois() {
        self.bois = loadedBois
    } else {
      print("There are no bois in the db.")
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return bois.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BoiVCCell", for: indexPath) as! BoiVCCell
    
    cell.nameLabel.text = bois[indexPath.row].name
    
    //TODO: get money from db for certain boi
    // works but don't really need it, because of the whole fetching deal
//    if let money = bois[indexPath.row].totapPriceOwed {
//      cell.moneyLabel.text = String(describing: money)
//    }
    
    return cell
  }
  
  func initBois() -> [BoiMO]?{
    return CoreDataManager.sharedManager.loadAllBois()
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showBoiInfo" {
      if let destinationController =  segue.destination as? BoiViewController{
        
        if let safeIndexPath = self.tableView.indexPathForSelectedRow{
          let boiToTransfer = bois[safeIndexPath.row]
          destinationController.setBoi(boi: boiToTransfer)
        }
        
//        destinationController.products = self.products
//        let cell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! BoiVCCell
//        destinationController.boiName = cell.nameLabel.text!
        
      }
    }
    
  }
}
