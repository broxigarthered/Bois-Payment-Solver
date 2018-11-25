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

class BoiViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    weak var boi: BoiMO?
    
    @IBOutlet weak var shopProductsTableView: UITableView!
    @IBOutlet weak var boiNameLabel: UILabel!
    @IBOutlet weak var totalSumLabel: UILabel!
    
    private var totalSum: Decimal = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shopProductsTableView.delegate = self
        shopProductsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let b = boi {
            initBoisProperties(boi: b)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    
    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Custom methods
    
    private func shopNameForIndex(boi: BoiMO, index: Int) -> String{
        let dictionary = boi.products as! [String: [Product]]
        let name = Array(dictionary)[index].key
        return name
    }
    
    func setBoi(boi: BoiMO)  {
        self.boi = boi
    }
    
    private func productNameForIndex(boi: BoiMO, shopName: String, index: Int) -> Product?{
        if let dictionary = boi.products as? [String: [Product]]{
            return dictionary[shopName]![index]
        }
        
        return nil
    }
    
    private func initBoisProperties(boi: BoiMO){
        boiNameLabel.text = boi.name
    }
    
}

extension BoiViewController : UITableViewDelegate, UITableViewDataSource{
    // MARK: Tableview Data source methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = shopProductsTableView.dequeueReusableCell(withIdentifier: "BoiShopTableViewCell") as! BoiShopTableViewCell
        
        let shopName = shopNameForIndex(boi: boi!, index: indexPath.section)
        if let product = self.productNameForIndex(boi: boi!, shopName: shopName, index: indexPath.row){
            
            // get the product buyer
            print(product.buyer)
            cell.shopNameLabel.text = product.name
            cell.priceLabel.text = String(describing: product.price)
            totalSum += product.price
            totalSumLabel.text = String(describing: totalSum)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dictionary = boi?.products as! [String: [Product]]
        let arrayOfProducts = Array(dictionary)[section].value
        return arrayOfProducts.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return shopNameForIndex(boi: boi!, index: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (boi?.products as! [String: [Product]]).count
    }
}
