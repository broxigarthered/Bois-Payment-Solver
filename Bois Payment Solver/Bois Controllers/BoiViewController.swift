//
//  BoiViewController.swift
//  Bois Payment Solver
//
//  Created by Adelina Dutskinova on 12.09.18.
//  Copyright © 2018 Adelina Dutskinova. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class BoiViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
  
  weak var boi: BoiMO?
  
  @IBOutlet weak var shopProductsTableView: UITableView!
  @IBOutlet weak var boiNameLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    shopProductsTableView.delegate = self
    shopProductsTableView.dataSource = self
    
    if let b = boi {
        initBoisProperties(boi: b)
    }
    
    //var orders =  getOrders()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: Tableview Data source methods
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    
    //TODO: This isn't working
    let cell = shopProductsTableView.dequeueReusableCell(withIdentifier: "BoiShopTableViewCell") as! BoiShopTableViewCell
    
    // set the cell name
    cell.shopNameLabel.text = self.shopNameForIndex(boi: boi!, index: indexPath.row)
    
    // set the cell price
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // TODO: fix that shiet
    let dictionary = boi?.products as! [String: [Product]]
    let arrayOfProducts = Array(dictionary)[section].value
    return arrayOfProducts.count
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return (boi?.products as! [String: [Product]]).count
  }

  
  
  
  
//  func getOrders() -> [String: Decimal] {
//
//    var result: [String: Decimal] = [:]
//
//    for item in products {
//      let bois = item.value(forKey: "bois") as! [String: Decimal]
//      for boi in bois {
//        if(boi.key == self.boiName){
//          result[boi.key] = boi.value
//        }
//      }
//    }
//
//    return result
//  }
  
  
  // MARK: Custom methods
  
  private func shopNameForIndex(boi: BoiMO, index: Int) -> String{
    let dictionary = boi.products as! [String: [Product]]
    let name = Array(dictionary)[index].key
    return name
  }
  
  func setBoi(boi: BoiMO)  {
    self.boi = boi
  }
  
  private func initBoisProperties(boi: BoiMO){
    boiNameLabel.text = boi.name
  }
  
}
